import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-vove' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const Vove = NativeModules.VoveModule
  ? NativeModules.VoveModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export enum VoveEnvironment {
  production = 'production',
  sandbox = 'sandbox',
}
export function processIDMatching(
  env: VoveEnvironment,
  sessionToken: string
): Promise<number> {
  return Vove.processIDMatching(env, sessionToken);
}
