
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

@end
