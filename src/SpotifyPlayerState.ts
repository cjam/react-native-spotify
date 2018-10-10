import  PlaybackOptions from './PlaybackOptions';
import  PlaybackRestrictions from './PlaybackRestrictions';
import Track from './SpotifyApiTrack';

export default interface SpotifyPlayerState {
    track: Track;
    playbackPosition: any;
    playbackSpeed: any;
    paused: boolean;
    playbackRestrictions: PlaybackRestrictions;
    playbackOptions: PlaybackOptions;
}

