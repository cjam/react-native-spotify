import SpotifyApiConfig from './SpotifyApiConfig';
import SpotifyApiEvents from './SpotifyApiEvents';
import SpotifyPlayerState from './SpotifyPlayerState';
import SpotifyRepeatMode from './SpotifyRepeatMode';
import SpotifyContentType from './SpotifyContentType';
import SpotifyContentItem from './SpotifyContentItem';

export interface SpotifyEventEmitter{
    on<K extends keyof SpotifyApiEvents>(name:K,listener:(v:SpotifyApiEvents[K])=>void) : this;
    addListener<K extends keyof SpotifyApiEvents>(event: K, listener: (v:SpotifyApiEvents[K])=>void): this;
    once<K extends keyof SpotifyApiEvents>(event: K, listener: (v:SpotifyApiEvents[K])=>void): this;
    prependListener<K extends keyof SpotifyApiEvents>(event: K, listener: (v:SpotifyApiEvents[K])=>void): this;
    prependOnceListener<K extends keyof SpotifyApiEvents>(event: K, listener: (v:SpotifyApiEvents[K])=>void): this;
    removeListener<K extends keyof SpotifyApiEvents>(event: K, listener: (v:SpotifyApiEvents[K])=>void): this;
    off<K extends keyof SpotifyApiEvents>(event: K, listener: (v:SpotifyApiEvents[K])=>void): this;
    removeAllListeners<K extends keyof SpotifyApiEvents>(event?:K): this;
    setMaxListeners(n: number): this;
    getMaxListeners(): number;
    listeners<K extends keyof SpotifyApiEvents>(event: K): (v:SpotifyApiEvents[K])=>void[];
    rawListeners<K extends keyof SpotifyApiEvents>(event: K): (v:SpotifyApiEvents[K])=>void[];
    emit<K extends keyof SpotifyApiEvents>(event: K, args: SpotifyApiEvents[K]): boolean;
    eventNames<K extends keyof SpotifyApiEvents>(): Array<K>;
    listenerCount<K extends keyof SpotifyApiEvents>(type: K): number;
}

export interface SpotifyNativeApi extends SpotifyEventEmitter {
    isInitialized(): boolean;
    isConnected():boolean;
    initialize(config: SpotifyApiConfig): Promise<void>;
    
    /**
     * Play a track, album, playlist or artist via spotifyUri
     * Example: spotify:track:<id>, spotify:album:<id>, spotify:playlist:<id>, spotify:artist:<id>
     * @param {string} spotifyUri
     * @returns {Promise<void>}
     * @memberof SpotifyNativeApi
     */
    playUri(spotifyUri:string):Promise<void>;
    
    /**
     * Queues the track given by spotifyUri in Spotify
     * example: spotify:track:<id>
     * @param {string} spotifyUri
     * @returns {Promise<void>}
     * @memberof SpotifyNativeApi
     */
    queueUri(spotifyUri:string):Promise<void>;
    
    seek(positionMs:number):Promise<void>;
    resume(): Promise<void>;
    pause(): Promise<void>;
    skipToNext(): Promise<void>;
    skipToPrevious(): Promise<void>;
    setShuffling(shuffling:boolean):Promise<void>;
    setRepeatMode(mode:SpotifyRepeatMode):Promise<void>;
    getPlayerState():Promise<SpotifyPlayerState>;
    getRecommendedContentItems(type:SpotifyContentType):Promise<SpotifyContentItem[]>;
    getChildrenOfItem(item:Pick<SpotifyContentItem,'uri'|'id'>):Promise<SpotifyContentItem[]>;
}

interface SpotifyJSApi {

    /**
     * @deprecated Please use *resume* and *pause* instead
     * @param {boolean} playing
     * @returns {Promise<void>}
     * @memberof SpotifyJSApi
     */
    setPlaying(playing: boolean): Promise<void>;
}

export default interface SpotifyApi extends SpotifyJSApi, SpotifyNativeApi {

}