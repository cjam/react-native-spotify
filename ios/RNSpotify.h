#import <UIKit/UIKit.h>
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#if __has_include("RNEventEmitter.h")
#import "RNEventEmitter.h"
#else
#import <RNEventEmitter/RNEventEmitter.h>
#endif

@interface RNSpotify : NSObject <RCTBridgeModule, RNEventConformer>

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)URL options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

+(instancetype)sharedInstance;

//test()
-(id)test;

// isInitialized
-(id)isInitialized;

// initialize(options)
-(void)initializeAsync:(NSDictionary*)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

// getUserAsync
-(void)getUserAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

//-(void)play:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
//-(void)playItem:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
-(void)resume:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
-(void)pause:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
-(void)skipToNext:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
-(void)skipToPrevious:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;


// loginAsync
//-(void)loginAsync(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

@end
