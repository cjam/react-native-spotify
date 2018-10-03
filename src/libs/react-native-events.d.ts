declare module 'react-native-events'{
    interface RNEventsStatic{
        register(module:any):void;
        conform(module:any):void;
    }

    const static :RNEventsStatic;
    export default static;
}