
#import "RNSpotify.h"
#import <AVFoundation/AVFoundation.h>
#import <React/RCTConvert.h>
//#import <SpotifyiOS/SpotifyiOS.h>
//#import <SpotifyAuthentication/SpotifyAuthentication.h>
//#import <SpotifyMetadata/SpotifyMetadata.h>
//#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyiOS.h>
//#import "RNSpotifyAuthController.h"
//#import "RNSpotifyProgressView.h"
#import "RNSpotifyConvert.h"
//#import "RNSpotifyCompletion.h"
//#import "HelperMacros.h"
#import "RNSpotifyError.h"
#import "RNSpotifyCompletion.h"
#define SPOTIFY_API_BASE_URL @"https://api.spotify.com/"
#define SPOTIFY_API_URL(endpoint) [NSURL URLWithString:NSString_concat(SPOTIFY_API_BASE_URL, endpoint)]


// Static Singleton instance
static RNSpotify *sharedInstance = nil;

@interface RNSpotify() <SPTSessionManagerDelegate,SPTAppRemoteDelegate>
{
    BOOL _initialized;
    BOOL _isInitializing;
    NSDictionary* _options;
    
    NSMutableArray<RNSpotifyCompletion*>* _sessionManagerCallbacks;
    NSMutableArray<RNSpotifyCompletion*>* _appRemoteCallbacks;
    
    SPTConfiguration *_apiConfiguration;
    SPTSessionManager *_sessionManager;
    SPTAppRemote *_appRemote;
}
- (void)initializeSessionManager:(NSDictionary*)options completionCallback:(RNSpotifyCompletion*)completion;
- (void)initializeAppRemote:(SPTSession*)session completionCallback:(RNSpotifyCompletion*)completion;
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
            _appRemoteCallbacks = [NSMutableArray array];
            _apiConfiguration = nil;
            _sessionManager = nil;
            _appRemote = nil;
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

+ (NSArray<RNSpotifyCompletion*>*)popCompletionCallbacks:(NSMutableArray<RNSpotifyCompletion*>*)callbackArray{
    NSArray<RNSpotifyCompletion*>* callbacks = [NSArray arrayWithArray:callbackArray];
    [callbackArray removeAllObjects];
    return callbacks;
}

+ (void)rejectCompletions:(NSMutableArray<RNSpotifyCompletion*>*)callbacks error:(RNSpotifyError*) error{
    NSArray<RNSpotifyCompletion*>* completions = [RNSpotify popCompletionCallbacks:callbacks];
    for(RNSpotifyCompletion* completion in completions)
    {
        [completion reject:error];
    }
}

+ (void)resolveCompletions:(NSMutableArray<RNSpotifyCompletion*>*)callbacks result:(id) result{
    NSArray<RNSpotifyCompletion*>* completions = [RNSpotify popCompletionCallbacks:callbacks];
    for(RNSpotifyCompletion* completion in completions)
    {
        [completion resolve:result];
    }
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

- (void)sessionManager:(SPTSessionManager *)manager didInitiateSession:(SPTSession *)session
{
    [RNSpotify resolveCompletions:_sessionManagerCallbacks result:session];
    NSLog(@"Session Initiated");
//    [self presentAlertControllerWithTitle:@"Authorization Succeeded"
//                                  message:session.description
//                              buttonTitle:@"Nice"];
}

- (void)sessionManager:(SPTSessionManager *)manager didFailWithError:(NSError *)error
{
    [RNSpotify rejectCompletions:_sessionManagerCallbacks error:[RNSpotifyError errorWithNSError:error]];
    NSLog(@"Session Manager Failed");
//    [self presentAlertControllerWithTitle:@"Authorization Failed"
//                                  message:error.description
//                              buttonTitle:@"Bummer"];
}

- (void)sessionManager:(SPTSessionManager *)manager didRenewSession:(SPTSession *)session
{
    [RNSpotify resolveCompletions:_sessionManagerCallbacks result:session];
    NSLog(@"Session Renewed");
//    [self presentAlertControllerWithTitle:@"Session Renewed"
//                                  message:session.description
//                              buttonTitle:@"Sweet"];
}

#pragma mark - SPTAppRemoteDelegate implementation

- (void)appRemote:(nonnull SPTAppRemote *)appRemote didDisconnectWithError:(nullable NSError *)error {
    [RNSpotify rejectCompletions:_appRemoteCallbacks error:[RNSpotifyError errorWithNSError:error]];
    NSLog(@"App Remote disconnected");
}

- (void)appRemote:(nonnull SPTAppRemote *)appRemote didFailConnectionAttemptWithError:(nullable NSError *)error {
    [RNSpotify rejectCompletions:_appRemoteCallbacks error:[RNSpotifyError errorWithNSError:error]];
    NSLog(@"App Failed To Connect");
}

- (void)appRemoteDidEstablishConnection:(nonnull SPTAppRemote *)connectedRemote {
    [RNSpotify resolveCompletions:_appRemoteCallbacks result:_appRemote];
    NSLog(@"App Remote Connection Initiated");
}

#pragma mark - React Native functions

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initialize:(NSDictionary*)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
    if(_isInitializing){
        [RNSpotifyErrorCode.IsInitializing reject:reject];
        return;
    }
    if(_initialized)
    {
        resolve(@YES);
        return;
    }
    _isInitializing = YES;

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
    
    [self initializeSessionManager:options completionCallback:[RNSpotifyCompletion onResolve:^(SPTSession* session) {
        // Session Manager has succesfully been setup
        [self initializeAppRemote:session completionCallback:[RNSpotifyCompletion onResolve:^(SPTAppRemote* remote) {
            // at this point our app remote has been connected resolve our init task
            self->_isInitializing = NO;
            self->_initialized = YES;
            resolve(@YES);
        } onReject:^(RNSpotifyError *error) {
            [error reject:reject];
        }]];
    } onReject:^(RNSpotifyError *error) {
        [error reject:reject];
    }]];
}

- (void)initializeSessionManager:(NSDictionary*)options completionCallback:(RNSpotifyCompletion*)completion{
    // Create our configuration object
    _apiConfiguration = [SPTConfiguration configurationWithClientID:options[@"clientID"] redirectURL:[NSURL URLWithString:options[@"redirectURL"]]];
    // Add swap and refresh urls to config if present
    if(options[@"tokenSwapURL"] != nil){
        _apiConfiguration.tokenSwapURL = [NSURL URLWithString: options[@"tokenSwapURL"]];
    }
    
    if(options[@"tokenRefreshURL"] != nil){
        _apiConfiguration.tokenRefreshURL = [NSURL URLWithString: options[@"tokenRefreshURL"]];
    }
    
    // Default Scope
    SPTScope scope = SPTAppRemoteControlScope | SPTUserFollowReadScope;
    if(options[@"scope"] != nil){
        scope = [RCTConvert NSUInteger:options[@"scope"]];
    }
    
    // Allocate our _sessionManager using our configuration
    _sessionManager = [SPTSessionManager sessionManagerWithConfiguration:_apiConfiguration delegate:self];
    
    // Add our completion callback
    [_sessionManagerCallbacks addObject:completion];
    
    // Initialize the auth flow
    if (@available(iOS 11, *)) {
        // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
        [_sessionManager initiateSessionWithScope:scope options:SPTDefaultAuthorizationOption];
    } else {
        // todo: figure out the view controller for this
        // Use this on iOS versions < 11 to use SFSafariViewController
        [_sessionManager initiateSessionWithScope:scope
                                          options:SPTDefaultAuthorizationOption
                         presentingViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    }
}

- (void)initializeAppRemote:(SPTSession*)session completionCallback:(RNSpotifyCompletion*)completion{
    _appRemote = [[SPTAppRemote alloc] initWithConfiguration:_apiConfiguration logLevel:SPTAppRemoteLogLevelInfo];
    _appRemote.connectionParameters.accessToken = session.accessToken;
    _appRemote.delegate = self;
    // Add our callback before we connect
    [_appRemoteCallbacks addObject:completion];
    RCTExecuteOnMainQueue(^{
        [self->_appRemote connect];
    });
}

+(void (^)(id _Nullable, NSError * _Nullable))defaultSpotifyRemoteCallback:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject{
    return ^(id  _Nullable result, NSError * _Nullable error) {
        if(error != nil){
            [[RNSpotifyError errorWithNSError:error] reject:reject];
        }else{
            resolve([NSNull null]);
        }
    };
}


RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(isInitialized){
    if(!_initialized){
        return @NO;
    }else{
        return @YES;
    }
}

RCT_EXPORT_METHOD(playUri:(NSString*)uri resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->_appRemote.playerAPI play:uri callback:[RNSpotify defaultSpotifyRemoteCallback:resolve reject:reject]];
    });
}

RCT_EXPORT_METHOD(queueUri:(NSString*)uri resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    if(![[uri lowercaseString] hasPrefix:@"spotify:track:"]){
        [[RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.InvalidParameter message:@"Can only queue Spotify track uri's (i.e. spotify:track:<id> )"] reject:reject];
        return;
    }
    RCTExecuteOnMainQueue(^{
        [self->_appRemote.playerAPI enqueueTrackUri:uri callback:[RNSpotify defaultSpotifyRemoteCallback:resolve reject:reject]];
    });
}

RCT_EXPORT_METHOD(resume:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    RCTExecuteOnMainQueue(^{
        [self->_appRemote.playerAPI resume:[RNSpotify defaultSpotifyRemoteCallback:resolve reject:reject]];
    });
}

RCT_EXPORT_METHOD(pause:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    RCTExecuteOnMainQueue(^{
        [self->_appRemote.playerAPI pause:[RNSpotify defaultSpotifyRemoteCallback:resolve reject:reject]];
    });
}

RCT_EXPORT_METHOD(skipToNext:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    RCTExecuteOnMainQueue(^{
        [self->_appRemote.playerAPI skipToNext:[RNSpotify defaultSpotifyRemoteCallback:resolve reject:reject]];
    });
}

RCT_EXPORT_METHOD(skipToPrevious:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    RCTExecuteOnMainQueue(^{
        [self->_appRemote.playerAPI skipToPrevious:[RNSpotify defaultSpotifyRemoteCallback:resolve reject:reject]];
    });
}

RCT_EXPORT_METHOD(seek:(NSInteger)position resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    RCTExecuteOnMainQueue(^{
        [self->_appRemote.playerAPI seekToPosition:position callback:[RNSpotify defaultSpotifyRemoteCallback:resolve reject:reject]];
    });
}


RCT_EXPORT_METHOD(setShuffling:(BOOL)shuffling resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    RCTExecuteOnMainQueue(^{
        [self->_appRemote.playerAPI setShuffle:shuffling callback:[RNSpotify defaultSpotifyRemoteCallback:resolve reject:reject]];
    });
}

RCT_EXPORT_METHOD(setRepeatMode: (NSInteger)repeatMode resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    RCTExecuteOnMainQueue(^{
        [self->_appRemote.playerAPI setRepeatMode:repeatMode callback:[RNSpotify defaultSpotifyRemoteCallback:resolve reject:reject]];
    });
}


RCT_EXPORT_METHOD(getPlayerState:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
    RCTExecuteOnMainQueue(^{
        [self->_appRemote.playerAPI getPlayerState:^(id _Nullable result, NSError * _Nullable error) {
            if(error != nil){
                [[RNSpotifyError errorWithNSError:error] reject:reject];
            }else{
                if([result conformsToProtocol:@protocol(SPTAppRemotePlayerState)]){
                    resolve([RNSpotifyConvert SPTAppRemotePlayerState:result]);
                }else{
                    [[RNSpotifyError errorWithCodeObj:RNSpotifyErrorCode.BadResponse message:@"Couldn't parse returned player state"] reject:reject];
                }
            }
        }];
    });
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

