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
  Production = 'production',
  Sandbox = 'sandbox',
}

export const enum VoveStatus {
  Canceled = 'canceled', // user canceled flow
  Pending = 'pending', // pending more validations
  Success = 'success', // success
}
export const enum VoveLocale {
  EN = 'EN',
  FR = 'FR',
  AR = 'AR',
  AR_MA = 'AR_MA',
}
type VoveStartConfig = {
  environment: VoveEnvironment;
  sessionToken: string;
  enableVocalGuidance?: boolean;
  locale?: VoveLocale;
};
type VoveInitializeConfig = {
  environment: VoveEnvironment;
  publicKey: string;
};

export function start(config: VoveStartConfig): Promise<VoveStatus> {
  return Vove.start(config);
}
export function initialize(config: VoveInitializeConfig): Promise<void> {
  return Vove.initialize(config);
}
