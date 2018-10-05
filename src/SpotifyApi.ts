import SpotifyApiConfig from './SpotifyApiConfig';

export default interface SpotifyApi {
    test():void;

    isInitialized():boolean;
    initializeAsync(config:SpotifyApiConfig):Promise<void>;
    skipToNextAsync():Promise<void>;
}