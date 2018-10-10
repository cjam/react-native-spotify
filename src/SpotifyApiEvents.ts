import SpotifyPlayerState from './SpotifyPlayerState';

export default interface SpotifyApiEvents {
    "playerStateChanged": SpotifyPlayerState,
}