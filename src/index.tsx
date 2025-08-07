import {
  NativeModules,
  Platform,
  NativeEventEmitter,
  type EmitterSubscription,
} from 'react-native';

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

const eventEmitter = new NativeEventEmitter(Vove);

export enum VoveEnvironment {
  Production = 'production',
  Sandbox = 'sandbox',
}

export const enum VoveStatus {
  Canceled = 'canceled', // user canceled flow
  Pending = 'pending', // pending more validations
  Success = 'success', // success
  MaxAttempts = 'max_attempts', // max attempts reached
}
export const enum VoveLocale {
  EN = 'EN',
  FR = 'FR',
  DE = 'DE',
  AR = 'AR',
  AR_MA = 'AR_MA',
}
type VoveStartConfig = {
  environment: VoveEnvironment;
  sessionToken: string;
  enableVocalGuidance?: boolean;
  locale?: VoveLocale;
  showUI?: boolean;
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
let onMaxAttemptsListener: EmitterSubscription;

// Event listener for max attempts callback
export function addMaxAttemptsListener(callback: () => void): void {
  onMaxAttemptsListener = eventEmitter.addListener(
    'onMaxAttemptsCallToAction',
    callback
  );

  // Notify native code that listener is active
  Vove.setMaxAttemptsListenerActive(Platform.OS === 'ios' ? 1 : true);
}

export function removeMaxAttemptsListener(): void {
  onMaxAttemptsListener?.remove();
  Vove.setMaxAttemptsListenerActive(Platform.OS === 'ios' ? 0 : false);
}
