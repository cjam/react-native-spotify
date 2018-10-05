
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

//test()
-(id)test;

// isInitialized
-(id)isInitialized;

// initialize(options)
-(void)initializeAsync:(NSDictionary*)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

// getUserAsync
-(void)getUserAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

-(void)skipToNextAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

// loginAsync
//-(void)loginAsync(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

@end
