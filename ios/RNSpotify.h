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

// isInitialized
-(id)isInitialized;

-(id)isConnected;

-(void)isConnectedAsync:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

-(void)connect:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

// initialize(options)
-(void)initialize:(NSDictionary*)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

// Playback API
-(void)playUri:(NSString*)uri resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
-(void)queueUri: (NSString*)uri resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
-(void)resume:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
-(void)pause:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
-(void)skipToNext:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
-(void)skipToPrevious:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
-(void)seek: (NSInteger)uri resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

-(void)setShuffling: (BOOL)shuffling resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

-(void)setRepeatMode: (NSInteger)repeatMode resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

-(void)getPlayerState:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;

-(void)getRecommendedContentItems:(NSUInteger) typeVal resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
-(void)getChildrenOfItem:(NSDictionary*)item resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject;
@end
