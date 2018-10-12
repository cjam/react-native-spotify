import React, { Component } from 'react';
import {
    ActivityIndicator,
    Alert,
    StyleSheet,
    Text,
    TouchableHighlight,
    View,
    FlatList,
    SectionList
} from 'react-native';
import { NavigationActions, StackActions } from 'react-navigation';
import Spotify, { SpotifyApiConfig, SpotifyApiScope, SpotifyPlayerState, SpotifyRepeatMode, SpotifyContentType } from 'rn-spotify-sdk';

export default class InitialScreen extends Component<any, any> {
    static navigationOptions = {
        header: null
    };

    constructor(props: any, context: any) {
        super(props, context);

        this.state = { spotifyInitialized: false };
        this.onPlayerStateChanged.bind(this);
    }

    goToPlayer() {
        const navAction = StackActions.reset({
            index: 0,
            actions: [
                NavigationActions.navigate({ routeName: 'player' })
            ]
        });
        this.props.navigation.dispatch(navAction);
    }

    async componentDidMount() {

        const isInitialized = true;
        // const isInitialized = await Spotify.isInitializedAsync();
        // const user = await Spotify.getUserAsync();
        // console.log("Spotify user",user);   
        // initialize Spotify if it hasn't been initialized yet
        // if (!isInitialized) {
        // initialize spotify
        // var spotifyOptions = {
        //     "clientID": "43f0dc5090214050991c5c6342b54ed5",
        //     "sessionUserDefaultsKey": "SpotifySession",
        //     "redirectURL": "longitunes://auth",
        //     "scopes": ["user-read-private", "playlist-read", "playlist-read-private", "streaming"]
        // };
        const spotifyConfig: SpotifyApiConfig = {
            clientID: "a927da604ff84ecba2ca505fb49827c1",
            redirectURL: "longitunes://spotify-login-callback",
            tokenRefreshURL: "http://192.168.0.11:3000/refresh",
            tokenSwapURL: "http://192.168.0.11:3000/swap",
            scope: SpotifyApiScope.AppRemoteControlScope | SpotifyApiScope.UserFollowReadScope
        }
        try {
            // navigator.geolocation.watchPosition((location)=>{
            //     console.log(location);
            // },(err)=>{
            //     console.error(err);
            // },{enableHighAccuracy:true});
            navigator.geolocation.getCurrentPosition((location)=>{
                console.log(location);
            },(err)=>{
                console.error(err);
            });

            await Spotify.initialize(spotifyConfig);
            Spotify.on("remoteConnected",()=>{
                console.log('connected');
            }).on('remoteDisconnected',()=>{
                console.log('disconnected');
            });

            console.log('Initialized');
            // const loggedIn = await Spotify.initialize(spotifyOptions)
            // update UI state
            this.setState({ spotifyInitialized: true });
            // handle initialization
            // if (loggedIn) {
            //     this.goToPlayer();
            // }
        } catch (error) {
            Alert.alert("Error", error.message);
        };
        // }
        // else {
        //     // // update UI state
        //     // this.setState((state: any) => {
        //     //     state.spotifyInitialized = true;
        //     //     return state;
        //     // });
        //     // // handle logged in
        //     // const isLoggedIn = await Spotify.isLoggedInAsync();
        //     // if(isLoggedIn){
        //     //     this.goToPlayer();
        //     // }
        // }
    }

    onPlayerStateChanged(playerState: SpotifyPlayerState) {
        navigator.geolocation.getCurrentPosition(location=>{
            console.log(location,playerState);
        },err=>{
            console.error(err);
        });
    }

    render() {
        if (!this.state.spotifyInitialized) {
            return (
                <View style={styles.container}>
                    <ActivityIndicator animating={true} style={styles.loadIndicator}>
                    </ActivityIndicator>
                    <Text style={styles.loadMessage}>
                        Loading...
					</Text>
                </View>
            );
        }
        else {
            async function tryPromise(promise: Promise<any>) {
                try {
                    await promise;
                } catch (e) {
                    Alert.alert("Error", e.message);
                }
            }
            interface Action {
                key: string;
                action: () => void;
            }
            interface ActionSection {
                title: string;
                data: Action[];
            }
            const sections: ActionSection[] = [
                {
                    title: "Content API",
                    data: [
                        {
                            key: "Get Default Items", action: async () => {
                                const result = await Spotify.getRecommendedContentItems(SpotifyContentType.Default);
                                console.log(result)
                            }
                        },
                        {
                            key: "Get Fitness Items", action: async () => {
                                const result = await Spotify.getRecommendedContentItems(SpotifyContentType.Fitness);
                                console.log(result)
                            }
                        },
                        {
                            key: "Get Navigation Items", action: async () => {
                                const result = await Spotify.getRecommendedContentItems(SpotifyContentType.Navigation);
                                console.log(result)
                            }
                        },
                        {
                            key: "Fetch Children for Recently Played", action: async () => {
                                const result = await Spotify.getChildrenOfItem({uri:'spotify:recently-played',id:'spotify:recently-played'});
                                console.log(result)
                            }
                        },
                    ]
                },
                {
                    title: "Play",
                    data: [
                        { key: "Play Track", action: async () => await tryPromise(Spotify.playUri("spotify:track:7s1upm7yr7ZjrzXMwHawtG")) },
                        { key: "Play Playlist", action: async () => await tryPromise(Spotify.playUri("spotify:playlist:3ak9pOzSeNJEGg8H5fhFUm")) },
                        { key: "Play Album", action: async () => await tryPromise(Spotify.playUri("spotify:album:1f7ctORquPgU8g7R2teLP8")) },
                        { key: "Play Artist", action: async () => await tryPromise(Spotify.playUri("spotify:artist:23fqKkggKUBHNkbKtXEls4")) }
                    ]
                },
                {
                    title: "Queue",
                    data: [
                        { key: "Queue Track", action: async () => await tryPromise(Spotify.queueUri("spotify:track:7s1upm7yr7ZjrzXMwHawtG")) },
                        { key: "Queue Playlist", action: async () => await tryPromise(Spotify.queueUri("spotify:playlist:3ak9pOzSeNJEGg8H5fhFUm")) },
                        { key: "Queue Album", action: async () => await tryPromise(Spotify.queueUri("spotify:album:1f7ctORquPgU8g7R2teLP8")) },
                        { key: "Queue Artist", action: async () => await tryPromise(Spotify.queueUri("spotify:artist:23fqKkggKUBHNkbKtXEls4")) },
                    ]
                },
                {
                    title: "Playback",
                    data: [
                        { key: "Pause", action: async () => await tryPromise(Spotify.pause()) },
                        { key: "Resume", action: async () => await tryPromise(Spotify.resume()) },
                        { key: "Next", action: async () => await tryPromise(Spotify.skipToNext()) },
                        { key: "Previous", action: async () => await tryPromise(Spotify.skipToPrevious()) },
                        { key: "Seek to 10s", action: async () => await tryPromise(Spotify.seek(10 * 1000)) },
                    ]
                },
                {
                    title: "Playback Modes",
                    data: [
                        { key: "Shuffle On", action: async () => await tryPromise(Spotify.setShuffling(true)) },
                        { key: "Shuffle Off", action: async () => await tryPromise(Spotify.setShuffling(false)) },
                        { key: "Repeat Off", action: async () => await tryPromise(Spotify.setRepeatMode(SpotifyRepeatMode.Off)) },
                        { key: "Repeat Track", action: async () => await tryPromise(Spotify.setRepeatMode(SpotifyRepeatMode.Track)) },
                        { key: "Repeat Context", action: async () => await tryPromise(Spotify.setRepeatMode(SpotifyRepeatMode.Context)) },
                    ]
                },
                {
                    title: "Other",
                    data: [
                        {
                            key: "Get Playback State", action: async () => {
                                try {
                                    const playerState: SpotifyPlayerState = await Spotify.getPlayerState();
                                    console.log(playerState);
                                    Alert.alert(`
                                    isPlaying:${!playerState.paused},
                                    trackName:${playerState.track.name},
                                    isShuffling:${playerState.playbackOptions.isShuffling},
                                    repeatMode:${playerState.playbackOptions.repeatMode}
                                `)
                                } catch (err) {
                                    Alert.alert(err.message);
                                }
                            }
                        },
                        {
                            key: "Subscribe to PlayerState", action: async () => {
                                try {
                                    Spotify.on("playerStateChanged", this.onPlayerStateChanged);
                                } catch (err) {
                                    Alert.alert(err.message);
                                }
                            }
                        },
                        {
                            key: "Unsubscribe to PlayerState", action: async () => {
                                try {
                                    Spotify.removeListener("playerStateChanged", this.onPlayerStateChanged);
                                } catch (err) {
                                    Alert.alert(err.message);
                                }
                            }
                        }
                    ]
                }
            ]

            return (
                <View style={styles.container}>
                    <Text style={styles.greeting}>
                        We're connected to Spotify!
					</Text>
                    <SectionList
                        sections={sections}
                        renderSectionHeader={({ section }) => <Text style={styles.sectionHeader}>{section.title}</Text>}
                        renderItem={({ item: { action, key } }) => {
                            return (
                                <TouchableHighlight key={key} onPress={action} style={styles.spotifyLoginButton}>
                                    <Text style={styles.spotifyLoginButtonText}>{key}</Text>
                                </TouchableHighlight>
                            )
                        }}>
                    </SectionList>
                </View>
            );
        }
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },

    loadIndicator: {
        //
    },
    loadMessage: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    sectionHeader: {
        paddingTop: 2,
        paddingLeft: 10,
        paddingRight: 10,
        paddingBottom: 2,
        fontSize: 14,
        fontWeight: 'bold',
        backgroundColor: 'rgba(247,247,247,1.0)',
    },
    spotifyLoginButton: {
        justifyContent: 'center',
        borderRadius: 18,
        backgroundColor: 'green',
        overflow: 'hidden',
        width: 200,
        height: 40,
        margin: 5,
    },
    spotifyLoginButtonText: {
        fontSize: 20,
        textAlign: 'center',
        color: 'white',
    },

    greeting: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
});
