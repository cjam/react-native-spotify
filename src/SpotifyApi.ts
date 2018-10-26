import SpotifyApiConfig from './SpotifyApiConfig';
import SpotifyApiEvents from './SpotifyApiEvents';
import SpotifyPlayerState from './SpotifyPlayerState';
import SpotifyRepeatMode from './SpotifyRepeatMode';
import SpotifyContentType from './SpotifyContentType';
import SpotifyContentItem from './SpotifyContentItem';
import TypedEventEmitter from './TypedEventEmitter';

/**
 * SpotifyNative Event Emitter, emitting events of type {@link SpotifyApiEvents}
 *
 * @export
 * @interface SpotifyEventEmitter
 */
interface SpotifyEventEmitter extends TypedEventEmitter<SpotifyApiEvents>{

}

/**
 * The interface exposed by the React Native Module
 *
 * @export
 * @interface SpotifyNativeApi
 */
export interface SpotifyNativeApi {
    isInitialized(): boolean;
    isConnected(): boolean;


    /**
     * Asynchronous call to get whether or not the Spotify Remote is connected
     *
     * @returns {Promise<boolean>}
     * @memberof SpotifyNativeApi
     */
    isConnectedAsync():Promise<boolean>;

    initialize(config: SpotifyApiConfig): Promise<void>;

    connect():Promise<void>;

    /**
     * Play a track, album, playlist or artist via spotifyUri
     * Example: spotify:track:<id>, spotify:album:<id>, spotify:playlist:<id>, spotify:artist:<id>
     * @param {string} spotifyUri
     * @returns {Promise<void>}
     * @memberof SpotifyNativeApi
     */
    playUri(spotifyUri: string): Promise<void>;

    /**
     * Queues the track given by spotifyUri in Spotify
     * example: spotify:track:<id>
     * @param {string} spotifyUri
     * @returns {Promise<void>}
     * @memberof SpotifyNativeApi
     */
    queueUri(spotifyUri: string): Promise<void>;

    seek(positionMs: number): Promise<void>;
    resume(): Promise<void>;
    pause(): Promise<void>;
    skipToNext(): Promise<void>;
    skipToPrevious(): Promise<void>;
    setShuffling(shuffling: boolean): Promise<void>;
    setRepeatMode(mode: SpotifyRepeatMode): Promise<void>;
    getPlayerState(): Promise<SpotifyPlayerState>;
    getRecommendedContentItems(type: SpotifyContentType): Promise<SpotifyContentItem[]>;
    getChildrenOfItem(item: Pick<SpotifyContentItem, 'uri' | 'id'>): Promise<SpotifyContentItem[]>;
}

/**
 * Supplemental Javascript Interface
 *
 * @interface SpotifyJSApi
 */
interface SpotifyJSApi {

    /**
     * @deprecated Please use *resume* and *pause* instead
     * @param {boolean} playing
     * @returns {Promise<void>}
     * @memberof SpotifyJSApi
     */
    setPlaying(playing: boolean): Promise<void>;
}

export default interface SpotifyApi extends SpotifyJSApi, SpotifyNativeApi, SpotifyEventEmitter {

}