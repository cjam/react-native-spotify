
import { NativeModules, Alert } from 'react-native';
import RNEvents from 'react-native-events';
import { default as SpotifyApi } from './SpotifyApi';
export { default as SpotifyApi} from './SpotifyApi';
export { default as SpotifyApiConfig } from './SpotifyApiConfig'
export { default as SpotifyApiScope } from './SpotifyApiScope';
export { default as SpotifyRepeatMode } from './SpotifyRepeatMode'
export { default as SpotifyPlayerState } from './SpotifyPlayerState';
export { default as Track } from './SpotifyApiTrack';
export { default as Artist } from './SpotifyApiArtist';
export { default as Album } from './SpotifyApiAlbum';
export { default as SpotifyContentType } from './SpotifyContentType';
export { default as SpotifyContentItem } from './SpotifyContentItem';

const SpotifyNative = NativeModules.RNSpotify as SpotifyApi;

SpotifyNative.setPlaying = (playing: boolean) => {
    // todo: Will want to likely check the state of playing somewhere?
    // Perhaps this can be done in native land so that we don't need to
    // worry about it here
    return playing ? SpotifyNative.resume() : SpotifyNative.pause();
}

RNEvents.register(SpotifyNative);
RNEvents.conform(SpotifyNative);

// The events produced by the eventEmitter implementation around 
// when new event listeners are added and removed
const metaEvents = {
    newListener: 'newListener',
    removeListener: 'removeListener'
};

// Want to ignore the metaEvents when sending our subscription events
const ignoredEvents = Object.keys(metaEvents);

(SpotifyNative as any).on(metaEvents.newListener, (type: string) => {
    if (ignoredEvents.indexOf(type) === -1) {
        const listenerCount = SpotifyNative.listenerCount(type as any);
        // If this is the first listener, send an eventSubscribed event
        if (listenerCount == 0) {
            RNEvents.emitNativeEvent(SpotifyNative, "eventSubscribed", type);
        }
    }
}).on(metaEvents.removeListener, (type: string) => {
    if (ignoredEvents.indexOf(type) === -1) {
        const listenerCount = SpotifyNative.listenerCount(type as any);
        if (listenerCount == 0) {
            RNEvents.emitNativeEvent(SpotifyNative, "eventUnsubscribed", type);
        }
    }
});



// const sendRequest = Spotify.sendRequest;

// Spotify.getMe = () => {
// 	return sendRequest('v1/me', 'GET', null, false);
// };

// Spotify.getMyPlaylists = (options) => {
// 	var body = Object.assign({}, options);
// 	return sendRequest('v1/me/playlists', 'GET', body, false);
// }

// Spotify.getMyTracks = (options) => {
// 	var body = Object.assign({}, options);
// 	return sendRequest('v1/me/tracks', 'GET', body, false);
// }

// Spotify.search = (query, types, options) => {
// 	if(!(types instanceof Array))
// 	{
// 		return Promise.reject(new Error("types must be an array"));
// 	}

// 	var body = Object.assign({}, options);
// 	body['q'] = query;
// 	body['type'] = types.join(',');

// 	return sendRequest('v1/search', 'GET', body, false);
// }

// Spotify.getPlaylistTracks = (userId, playlistId, options) => {
// 	var body = Object.assign({}, options);
// 	return sendRequest(`v1/users/${userId}/playlists/${playlistId}/tracks`, 'GET', body, false);
// }



// Spotify.getAlbum = (albumID, options) => {
// 	if(albumID == null)
// 	{
// 		return Promise.reject(new Error("albumID cannot be null"));
// 	}

// 	return sendRequest('v1/albums/'+albumID, 'GET', options, false);
// }

// Spotify.getAlbums = (albumIDs, options) => {
// 	if(!(albumIDs instanceof Array))
// 	{
// 		return Promise.reject(new Error("albumIDs must be an array"));
// 	}

// 	var body = Object.assign({}, options);
// 	body['ids'] = albumIDs.join(',');

// 	return sendRequest('v1/albums', 'GET', body, false);
// }

// Spotify.getAlbumTracks = (albumID, options) => {
// 	if(albumID == null)
// 	{
// 		return Promise.reject(new Error("albumID cannot be null"));
// 	}

// 	return sendRequest('v1/albums/'+albumID+'/tracks', 'GET', options, false);
// }



// Spotify.getArtist = (artistID, options) => {
// 	if(artistID == null)
// 	{
// 		return Promise.reject(new Error("artistID cannot be null"));
// 	}

// 	return sendRequest('v1/artists/'+artistID, 'GET', options, false);
// }

// Spotify.getArtists = (artistIDs, options) => {
// 	if(!(artistIDs instanceof Array))
// 	{
// 		return Promise.reject(new Error("artistIDs must be an array"));
// 	}

// 	var body = Object.assign({}, options);
// 	body['ids'] = artistIDs.join(',');

// 	return sendRequest('v1/artists', 'GET', body, false);
// }

// Spotify.getArtistAlbums = (artistID, options) => {
// 	if(artistID == null)
// 	{
// 		return Promise.reject(new Error("artistID cannot be null"));
// 	}

// 	return sendRequest('v1/artists/'+artistID+'/albums', 'GET', options, false);
// }

// Spotify.getArtistTopTracks = (artistID, country, options) => {
// 	if(artistID == null)
// 	{
// 		return Promise.reject(new Error("artistID cannot be null"));
// 	}
// 	else if(country == null)
// 	{
// 		return Promise.reject(new Error("country cannot be null"));
// 	}

// 	var body = Object.assign({}, options);
// 	body['country'] = country;

// 	return sendRequest('v1/artists/'+artistID+'/top-tracks', 'GET', body, false);
// }

// Spotify.getArtistRelatedArtists = (artistID, options) => {
// 	if(artistID == null)
// 	{
// 		return Promise.reject(new Error("artistID cannot be null"));
// 	}

// 	return sendRequest('v1/artists/'+artistID+'/related-artists', 'GET', options, false);
// }



// Spotify.getTrack = (trackID, options) => {
// 	if(trackID == null)
// 	{
// 		return Promise.reject(new Error("trackID cannot be null"));
// 	}

// 	return sendRequest('v1/tracks/'+trackID, 'GET', options, false);
// }

// Spotify.getTracks = (trackIDs, options) => {
// 	if(!(trackIDs instanceof Array))
// 	{
// 		return Promise.reject(new Error("trackIDs must be an array"));
// 	}

// 	var body = Object.assign({}, options);
// 	body['ids'] = trackIDs.join(',');

// 	return sendRequest('v1/tracks', 'GET', body, false);
// }

// Spotify.getTrackAudioAnalysis = (trackID, options) => {
// 	if(trackID == null)
// 	{
// 		return Promise.reject(new Error("trackID cannot be null"));
// 	}

// 	return sendRequest('v1/audio-analysis/'+trackID, 'GET', options, false);
// }

// Spotify.getTrackAudioFeatures = (trackID, options) => {
// 	if(trackID == null)
// 	{
// 		return Promise.reject(new Error("trackID cannot be null"));
// 	}

// 	return sendRequest('v1/audio-features/'+trackID, 'GET', options, false);
// }

// Spotify.getTracksAudioFeatures = (trackIDs, options) => {
// 	if(!(trackIDs instanceof Array))
// 	{
// 		return Promise.reject(new Error("trackIDs must be an array"));
// 	}

// 	var body = Object.assign({}, options);
// 	body['ids'] = trackIDs.join(',');

// 	return sendRequest('v1/audio-features', 'GET', body, false);
// }

export default SpotifyNative;
