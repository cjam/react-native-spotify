enum SpotifyApiScope {
    
    /**
     * Read access to user’s private playlists.
     */
    SPTPlaylistReadPrivateScope = 1 << 0,
    /**
     * Include collaborative playlists when requesting a user’s playlists.
     */
    SPTPlaylistReadCollaborativeScope = 1 << 1,
    /**
     * Write access to a user’s public playlists.
     */
    SPTPlaylistModifyPublicScope = 1 << 2,
    /**
     * Write access to a user’s private playlists.
     */
    SPTPlaylistModifyPrivateScope = 1 << 3,
    /**
     * Read access to the list of artists and other users that the user follows.
     */
    SPTUserFollowReadScope = 1 << 4,
    /**
     * Write/delete access to the list of artists and other users that the user follows.
     */
    SPTUserFollowModifyScope = 1 << 5,
    /**
     * Read access to a user’s “Your Music” library.
     */
    SPTUserLibraryReadScope = 1 << 6,
    /**
     * Write/delete access to a user’s “Your Music” library.
     */
    SPTUserLibraryModifyScope = 1 << 7,
    /**
     * Read access to the user’s birthdate.
     */
    SPTUserReadBirthDateScope = 1 << 8,
    /**
     * Read access to user’s email address.
     */
    SPTUserReadEmailScope = 1 << 9,
    /**
     * Read access to user’s subscription details (type of user account).
     */
    SPTUserReadPrivateScope = 1 << 10,
    /**
     * Read access to a user’s top artists and tracks.
     */
    SPTUserTopReadScope = 1 << 11,
    /**
     * Upload user generated content images
     */
    SPTUGCImageUploadScope = 1 << 12,
    /**
     * Control playback of a Spotify track.
     */
    SPTStreamingScope = 1 << 13,
    /**
     * Use App Remote to control playback in the Spotify app
     */
    SPTAppRemoteControlScope = 1 << 14,
    /**
     * Read access to a user’s player state.
     */
    SPTUserReadPlaybackStateScope = 1 << 15,
    /**
     * Write access to a user’s playback state
     */
    SPTUserModifyPlaybackStateScope = 1 << 16,
    /**
     * Read access to a user’s currently playing track
     */
    SPTUserReadCurrentlyPlayingScope = 1 << 17,
    /**
     * Read access to a user’s currently playing track
     */
    SPTUserReadRecentlyPlayedScope = 1 << 18,
}

export default SpotifyApiScope;