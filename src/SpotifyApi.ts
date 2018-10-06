import SpotifyApiConfig from './SpotifyApiConfig';

export default interface SpotifyApi {
    test():void;

    isInitialized():boolean;
    initializeAsync(config:SpotifyApiConfig):Promise<void>;
    resume():Promise<void>;
    pause():Promise<void>;
    skipToNext():Promise<void>;
    skipToPrevious():Promise<void>;
}