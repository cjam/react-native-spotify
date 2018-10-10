
#import <React/RCTConvert.h>
#import "RNSpotifyConvert.h"

@implementation RNSpotifyConvert

+(id)ID:(id)obj
{
    if(obj == nil)
    {
        return [NSNull null];
    }
    return obj;
}

+(id)RNSpotifyError:(RNSpotifyError*)error
{
    if(error==nil)
    {
        return [NSNull null];
    }
    return error.reactObject;
}

+(id)NSError:(NSError*)error
{
    if(error==nil)
    {
        return [NSNull null];
    }
    return [self RNSpotifyError:[RNSpotifyError errorWithNSError:error]];
}

+(id)SPTAppRemotePlayerState:(NSObject<SPTAppRemotePlayerState>*) state{
    if(state == nil)
    {
        return [NSNull null];
    }
    return @{
        @"track": [RNSpotifyConvert SPTAppRemoteTrack:state.track],
        @"playbackPosition": [NSNumber numberWithInteger:state.playbackPosition],
        @"playbackSpeed": [NSNumber numberWithFloat:state.playbackSpeed],
        @"paused": [NSNumber numberWithBool:state.isPaused],
        @"playbackRestrictions": [RNSpotifyConvert SPTAppRemotePlaybackRestrictions:state.playbackRestrictions],
        @"playbackOptions": [RNSpotifyConvert SPTAppRemotePlaybackOptions:state.playbackOptions]
    };
}

+(id)SPTAppRemotePlaybackRestrictions:(NSObject<SPTAppRemotePlaybackRestrictions>*) restrictions{
    if(restrictions == nil){
        return [NSNull null];
    }
    
    return @{
         @"canSkipNext": [NSNumber numberWithBool:restrictions.canSkipNext],
         @"canSkipPrevious": [NSNumber numberWithBool:restrictions.canSkipPrevious],
         @"canRepeatTrack": [NSNumber numberWithBool:restrictions.canRepeatTrack],
         @"canRepeatContext": [NSNumber numberWithBool:restrictions.canRepeatContext],
         @"canToggleShuffle": [NSNumber numberWithBool:restrictions.canToggleShuffle],
     };
}

+(id)SPTAppRemotePlaybackOptions:(NSObject<SPTAppRemotePlaybackOptions>*) options{
    if(options == nil){
        return [NSNull null];
    }
    return @{
      @"isShuffling": [NSNumber numberWithBool:options.isShuffling],
      @"repeatMode": [NSNumber numberWithUnsignedInteger:options.repeatMode],
    };
}


+(id)SPTAppRemoteTrack:(NSObject<SPTAppRemoteTrack>*) track{
    if(track == nil){
        return [NSNull null];
    }
    return @{
             @"name": track.name,
             @"uri":track.URI,
             @"duration":[NSNumber numberWithUnsignedInteger:track.duration],
             @"artist":[RNSpotifyConvert SPTAppRemoteArtist:track.artist],
             @"album":[RNSpotifyConvert SPTAppRemoteAlbum:track.album]
    };
}

+(id)SPTAppRemoteArtist:(NSObject<SPTAppRemoteArtist>*) artist{
    if(artist == nil){
        return [NSNull null];
    }
    return @{
             @"name":artist.name,
             @"uri":artist.URI
    };
}

+(id)SPTAppRemoteAlbum:(NSObject<SPTAppRemoteAlbum>*) album{
    if(album == nil){
        return [NSNull null];
    }
    return @{
             @"name":album.name,
             @"uri":album.URI
    };
}





//+(id)SPTPlaybackState:(SPTPlaybackState*)state
//{
//    if(state == nil)
//    {
//        return [NSNull null];
//    }
//    return @{
//        @"playing":[NSNumber numberWithBool:state.isPlaying],
//        @"repeating":[NSNumber numberWithBool:state.isRepeating],
//        @"shuffling":[NSNumber numberWithBool:state.isShuffling],
//        @"activeDevice":[NSNumber numberWithBool:state.isActiveDevice],
//        @"position":@(state.position)
//    };
//}
//
//+(id)SPTPlaybackTrack:(SPTPlaybackTrack*)track
//{
//    if(track == nil)
//    {
//        return [NSNull null];
//    }
//    return @{
//        @"name":[[self class] ID:track.name],
//        @"uri":[[self class] ID:track.uri],
//        @"contextName":[[self class] ID:track.playbackSourceName],
//        @"contextUri":[[self class] ID:track.playbackSourceUri],
//        @"artistName":[[self class] ID:track.artistName],
//        @"artistUri":[[self class] ID:track.artistUri],
//        @"albumName":[[self class] ID:track.albumName],
//        @"albumUri":[[self class] ID:track.albumUri],
//        @"albumCoverArtURL":[[self class] ID:track.albumCoverArtURL],
//        @"duration":@(track.duration),
//        @"indexInContext":@(track.indexInContext)
//    };
//}
//
//+(id)SPTPlaybackMetadata:(SPTPlaybackMetadata*)metadata
//{
//    if(metadata == nil)
//    {
//        return [NSNull null];
//    }
//    return @{
//        @"prevTrack":[[self class] SPTPlaybackTrack:metadata.prevTrack],
//        @"currentTrack":[[self class] SPTPlaybackTrack:metadata.currentTrack],
//        @"nextTrack":[[self class] SPTPlaybackTrack:metadata.nextTrack]
//    };
//}
//
//+(id)SPTAuth:(SPTAuth*)auth
//{
//    if(auth == nil)
//    {
//        return [NSNull null];
//    }
//    SPTSession* session = auth.session;
//    if(session == nil)
//    {
//        return [NSNull null];
//    }
//    return @{
//        @"accessToken": [RNSpotifyConvert ID:session.accessToken],
//        @"refreshToken": [RNSpotifyConvert ID:session.encryptedRefreshToken],
//        @"expireTime": session.expirationDate ? [NSNumber numberWithLongLong:((long long)session.expirationDate.timeIntervalSince1970*1000)] : [NSNull null]
//    };
//}

@end
