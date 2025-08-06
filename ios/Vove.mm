#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(VoveModule, NSObject)

RCT_EXTERN_METHOD(start:(NSDictionary *)config
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(initialize:(NSDictionary *)config
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setMaxAttemptsListenerActive:(nonnull NSNumber *) active)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
