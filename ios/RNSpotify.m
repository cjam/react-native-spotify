
#import "RNSpotify.h"
#import <AVFoundation/AVFoundation.h>
//#import <SpotifyiOS/SpotifyiOS.h>
//#import <SpotifyAuthentication/SpotifyAuthentication.h>
//#import <SpotifyMetadata/SpotifyMetadata.h>
//#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyiOS.h>
//#import "RNSpotifyAuthController.h"
//#import "RNSpotifyProgressView.h"
//#import "RNSpotifyConvert.h"
//#import "RNSpotifyCompletion.h"
//#import "HelperMacros.h"
#import "RNSpotifyError.h"
#import "RNSpotifyCompletion.h"
#define SPOTIFY_API_BASE_URL @"https://api.spotify.com/"
#define SPOTIFY_API_URL(endpoint) [NSURL URLWithString:NSString_concat(SPOTIFY_API_BASE_URL, endpoint)]

@interface RNSpotify() <SPTSessionManagerDelegate>
{
    BOOL _initialized;
    NSDictionary* _options;
    SPTSessionManager* _sessionManager;
    SPTAppRemote* _appRemote;
    
    NSMutableArray<RNSpotifyCompletion*>* _sessionManagerCallbacks;
}

@end

@implementation RNSpotify

@synthesize bridge = _bridge;

-(id)init
{
    if(self = [super init])
    {
        _initialized = NO;
        _sessionManagerCallbacks = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Utilities

+(id)reactSafeArg:(id)arg
{
    if(arg==nil)
    {
        return [NSNull null];
    }
    return arg;
}

+(NSMutableDictionary*)mutableDictFromDict:(NSDictionary*)dict
{
    if(dict==nil)
    {
        return [NSMutableDictionary dictionary];
    }
    return dict.mutableCopy;
}

#pragma mark - SPTSessionManagerDelegate

- (NSArray<RNSpotifyCompletion*>*)popCompletionCallbacks:(NSMutableArray<RNSpotifyCompletion*>*)callbackArray{
    NSArray<RNSpotifyCompletion*>* callbacks = [NSArray arrayWithArray:callbackArray];
    [callbackArray removeAllObjects];
    return callbacks;
}

- (void)sessionManager:(SPTSessionManager *)manager didInitiateSession:(SPTSession *)session
{
    NSArray<RNSpotifyCompletion*>* sessionCallbacks = [self popCompletionCallbacks:_sessionManagerCallbacks];
    for(RNSpotifyCompletion* completion in sessionCallbacks)
    {
        [completion resolve:session];
    }
    NSLog(@"Session Initiated");
//    [self presentAlertControllerWithTitle:@"Authorization Succeeded"
//                                  message:session.description
//                              buttonTitle:@"Nice"];
}

- (void)sessionManager:(SPTSessionManager *)manager didFailWithError:(NSError *)error
{
    NSArray<RNSpotifyCompletion*>* sessionCallbacks = [self popCompletionCallbacks:_sessionManagerCallbacks];
    for(RNSpotifyCompletion* completion in sessionCallbacks)
    {
        [completion reject:[RNSpotifyError errorWithNSError:error]];
    }
    NSLog(@"Session Manager Failed");
//    [self presentAlertControllerWithTitle:@"Authorization Failed"
//                                  message:error.description
//                              buttonTitle:@"Bummer"];
}

- (void)sessionManager:(SPTSessionManager *)manager didRenewSession:(SPTSession *)session
{
    NSArray<RNSpotifyCompletion*>* sessionCallbacks = [self popCompletionCallbacks:_sessionManagerCallbacks];
    for(RNSpotifyCompletion* completion in sessionCallbacks)
    {
        [completion resolve:session];
    }
    NSLog(@"Session Renewed");
//    [self presentAlertControllerWithTitle:@"Session Renewed"
//                                  message:session.description
//                              buttonTitle:@"Sweet"];
}

#pragma mark - React Native functions

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initializeAsync:(NSDictionary*)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"Initializing things...");
    if(_initialized)
    {
        [RNSpotifyErrorCode.AlreadyInitialized reject:reject];
        return;
    }

    // ensure options is not null or missing fields
    if(options == nil)
    {
        [[RNSpotifyError nullParameterErrorForName:@"options"] reject:reject];
        return;
    }
    else if(options[@"clientID"] == nil)
    {
        [[RNSpotifyError missingOptionErrorForName:@"clientID"] reject:reject];
        return;
    }else if(options[@"redirectURL"] == nil)
    {
        [[RNSpotifyError missingOptionErrorForName:@"redirectURL"] reject:reject];
        return;
    }

    // load default options
    _options = options;
    
    SPTConfiguration* configuration = [SPTConfiguration configurationWithClientID:options[@"clientID"] redirectURL:[NSURL URLWithString:options[@"redirectURL"]]];
    
    // Initialize through AppRemote
    _appRemote = [[SPTAppRemote alloc] initWithConfiguration:configuration logLevel:SPTAppRemoteLogLevelDebug];
    
    BOOL spotifyInstalled = [_appRemote authorizeAndPlayURI:@"spotify:track:69bp2EbF7Q2rqc5N3ylezZ"];
    
    if(spotifyInstalled){
        NSLog(@"Spotify Installed");
    }else{
        NSLog(@"Spotify Not Installed");
    }
    
    [_appRemote connect];
    if(_appRemote.isConnected){
        resolve(@YES);
    }else{
        [[RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.NotInitialized message:@"Not Connected"] reject:reject];
    }
    
    if(options[@"tokenSwapURL"] != nil){
        configuration.tokenSwapURL = [NSURL URLWithString: options[@"tokenSwapUrl"]];
    }
    if(options[@"tokenRefreshURL"] != nil){
        configuration.tokenRefreshURL = [NSURL URLWithString: options[@"tokenRefreshURL"]];
    }

    _sessionManager = [SPTSessionManager sessionManagerWithConfiguration:configuration delegate:self];

    
    // load iOS-specific options
    NSDictionary* iosOptions = options[@"ios"];
    if(iosOptions == nil)
    {
        iosOptions = @{};
    }
//    _audioSessionCategory = iosOptions[@"audioSessionCategory"];
//    if(_audioSessionCategory == nil)
//    {
//        _audioSessionCategory = AVAudioSessionCategoryPlayback;
//    }

    // done initializing
    _initialized = YES;

//    // call callback
//    NSNumber* loggedIn = [self isLoggedIn];
//    resolve(loggedIn);
//    if(loggedIn.boolValue)
//    {
//        [self sendEvent:@"login" args:@[]];
//    }
//
//    [self logBackInIfNeeded:[RNSpotifyCompletion<NSNumber*> onReject:^(RNSpotifyError* error) {
//        // failure
//    } onResolve:^(NSNumber* loggedIn) {
//        // success
//        if(loggedIn.boolValue)
//        {
//            // initialize player
//            [self initializePlayerIfNeeded:[RNSpotifyCompletion onComplete:^(id unused, RNSpotifyError* unusedError) {
//                // done
//            }]];
//        }
//    }] waitForDefinitiveResponse:YES];
    resolve(@YES);
}


RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(isInitialized){
    if(!_initialized){
        return @NO;
    }else{
        return @YES;
    }
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(test)
{
    NSLog(@"ayy lmao");
    return [NSNull null];
}

RCT_EXPORT_METHOD(getUserAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    NSLog(@"GETTING USER");
    resolve(
            @{
              @"firstName":@"Colter"
            }
    );
}

RCT_EXPORT_METHOD(skipToNext:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    [_appRemote.playerAPI skipToNext:^(id  _Nullable result, NSError * _Nullable error) {
        if(error != nil){
            [[RNSpotifyError errorWithNSError:error] reject:reject];
        }
        resolve(result);
    }];
}

RCT_EXPORT_METHOD(loginAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    
}

+(BOOL)requiresMainQueueSetup
{
   return NO;
}

#pragma mark - RNEventConformer Implementation

RCT_EXPORT_METHOD(__registerAsJSEventEmitter:(int)moduleId)
{
    [RNEventEmitter registerEventEmitterModule:self withID:moduleId bridge:_bridge];
}

-(void)sendEvent:(NSString*)event args:(NSArray*)args
{
    [RNEventEmitter emitEvent:event withParams:args module:self bridge:_bridge];
}

@end

