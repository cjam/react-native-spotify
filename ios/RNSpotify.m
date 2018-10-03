
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

#define SPOTIFY_API_BASE_URL @"https://api.spotify.com/"
#define SPOTIFY_API_URL(endpoint) [NSURL URLWithString:NSString_concat(SPOTIFY_API_BASE_URL, endpoint)]

@interface RNSpotify()
{
    BOOL _initialized;
}

@end

@implementation RNSpotify

@synthesize bridge = _bridge;

-(id)init
{
    if(self = [super init])
    {
        _initialized = NO;
    }
    return self;
}

#pragma mark - React Native functions

RCT_EXPORT_MODULE()

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(test)
{
    NSLog(@"ayy lmao");
    return [NSNull null];
}

@end

