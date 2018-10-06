
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

static RNSpotify *sharedInstance = nil;

@interface RNSpotify() <SPTSessionManagerDelegate>
{
    BOOL _initialized;
    NSDictionary* _options;
    
    NSMutableArray<RNSpotifyCompletion*>* _sessionManagerCallbacks;
    SPTSessionManager *_sessionManager;
    SPTAppRemote *_appRemote;
}
@end

@implementation RNSpotify

@synthesize bridge = _bridge;

#pragma mark Singleton Methods

+ (instancetype)sharedInstance {
    // Hopefully ReactNative can take care of allocating and initializing our instance
    // otherwise we'll need to check here
    return sharedInstance;
}

-(id)init
{
    // This is to hopefully maintain the singleton pattern within our React App.
    // Since ReactNative is the one allocating and initializing our instance,
    // we need to store the instance within the sharedInstance otherwise we'll
    // end up with a different one when calling shared instance statically
    if(sharedInstance == nil){
        if(self = [super init])
        {
            NSLog(@"RNSpotify Initialized");
            _initialized = NO;
            _sessionManagerCallbacks = [NSMutableArray array];
        }
        
        static dispatch_once_t once;
        dispatch_once(&once, ^
                      {
                          sharedInstance = self;
                      });
    }else{
        NSLog(@"Returning shared instance");
    }
    return sharedInstance;
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

#pragma mark URL handling

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)URL options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    // Not sure what we do if session manager is nil, perhaps store the parameters for when
    // we initialize?
    BOOL returnVal = NO;
    if(_sessionManager != nil){
        NSLog(@"Setting application openURL and options on session manager");
        returnVal = [_sessionManager application:application openURL:URL options:options];
        NSDictionary *params = [[SPTAppRemote alloc] authorizationParametersFromURL:URL];
        NSString *errorDescription = params[SPTAppRemoteErrorDescriptionKey];
        // If there was an error we should reject our SpotifyCompletion
        if(errorDescription){
//            [self rejectCompletions:_sessionManagerCallbacks error:[RNSpotifyError errorWithNSError:[SPTError errorWithCode:SPTAuthorizationFailedErrorCode description: errorDescription]]];
            returnVal = NO;
        }
    }
    if(returnVal){
//        [self resolveCompletions:_sessionManagerCallbacks result:nil];
    }
    return returnVal;
}


#pragma mark - SPTSessionManagerDelegate

- (void)addCompletion:(NSMutableArray<RNSpotifyCompletion*>*)callbackArray completion:(RNSpotifyCompletion*)callback{
    [callbackArray addObject:callback];
}

- (NSArray<RNSpotifyCompletion*>*)popCompletionCallbacks:(NSMutableArray<RNSpotifyCompletion*>*)callbackArray{
    NSArray<RNSpotifyCompletion*>* callbacks = [NSArray arrayWithArray:callbackArray];
    [callbackArray removeAllObjects];
    return callbacks;
}

- (void)rejectCompletions:(NSMutableArray<RNSpotifyCompletion*>*)callbacks error:(RNSpotifyError*) error{
    NSArray<RNSpotifyCompletion*>* completions = [self popCompletionCallbacks:callbacks];
    for(RNSpotifyCompletion* completion in completions)
    {
        [completion reject:error];
    }
}

- (void)resolveCompletions:(NSMutableArray<RNSpotifyCompletion*>*)callbacks result:(id) result{
    NSArray<RNSpotifyCompletion*>* completions = [self popCompletionCallbacks:callbacks];
    for(RNSpotifyCompletion* completion in completions)
    {
        [completion resolve:result];
    }
}


- (void)sessionManager:(SPTSessionManager *)manager didInitiateSession:(SPTSession *)session
{
    [self resolveCompletions:_sessionManagerCallbacks result:session];
    NSLog(@"Session Initiated");
//    [self presentAlertControllerWithTitle:@"Authorization Succeeded"
//                                  message:session.description
//                              buttonTitle:@"Nice"];
}

- (void)sessionManager:(SPTSessionManager *)manager didFailWithError:(NSError *)error
{
    [self rejectCompletions:_sessionManagerCallbacks error:[RNSpotifyError errorWithNSError:error]];
    NSLog(@"Session Manager Failed");
//    [self presentAlertControllerWithTitle:@"Authorization Failed"
//                                  message:error.description
//                              buttonTitle:@"Bummer"];
}

- (void)sessionManager:(SPTSessionManager *)manager didRenewSession:(SPTSession *)session
{
    [self resolveCompletions:_sessionManagerCallbacks result:session];
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

    // store the options
    _options = options;
    
    SPTConfiguration* configuration = [SPTConfiguration configurationWithClientID:options[@"clientID"] redirectURL:[NSURL URLWithString:options[@"redirectURL"]]];
    
    // Add swap and refresh urls to config if present
    if(options[@"tokenSwapURL"] != nil){
        configuration.tokenSwapURL = [NSURL URLWithString: options[@"tokenSwapURL"]];
    }
    
    if(options[@"tokenRefreshURL"] != nil){
        configuration.tokenRefreshURL = [NSURL URLWithString: options[@"tokenRefreshURL"]];
    }
 
    // Default Scope
    SPTScope scope = SPTUserFollowReadScope | SPTAppRemoteControlScope;
    if(options[@"scope"] != nil){
        scope = (int)options[@"scope"];
    }
    
    // Allocate our _sessionManager
    _sessionManager = [SPTSessionManager sessionManagerWithConfiguration:configuration delegate:self];
    

    [self addCompletion:_sessionManagerCallbacks completion:[RNSpotifyCompletion                                                       onResolve:^(SPTSession *session){
        self->_appRemote = [[SPTAppRemote alloc] initWithConfiguration:configuration logLevel:SPTAppRemoteLogLevelDebug];
        self->_appRemote.connectionParameters.accessToken = session.accessToken;
        [self->_appRemote connect];
        resolve(@YES);
    } onReject:^(RNSpotifyError *error) {
        [error reject:reject];
    }]];
    
    
    
    
    if (@available(iOS 11, *)) {
        // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
        [_sessionManager initiateSessionWithScope:scope options:SPTDefaultAuthorizationOption];
    } else {
        // todo: figure out the view controller for this
        // Use this on iOS versions < 11 to use SFSafariViewController
//        [self.sessionManager initiateSessionWithScope:scope options:SPTDefaultAuthorizationOption presentingViewController:self];
    }
    
    // done initializing
    _initialized = YES;

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

RCT_EXPORT_METHOD(skipToNextAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    [_appRemote.playerAPI skipToNext:^(id  _Nullable result, NSError * _Nullable error) {
        if(error != nil){
            [[RNSpotifyError errorWithNSError:error] reject:reject];
        }
        resolve(result);
    }];
//    [[RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.NotImplemented] reject:reject];
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

