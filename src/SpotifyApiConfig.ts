import SpotifyScope from './SpotifyApiScope';

export default interface SpotifyApiConfig {
    clientID:string;
    redirectURL:string;
    tokenSwapURL?:string;
    tokenRefreshURL?:string;
    playURI?:string;
    scope?:SpotifyScope;
}