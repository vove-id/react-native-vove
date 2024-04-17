#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(VoveModule, NSObject)

RCT_EXTERN_METHOD(processIDMatching:(NSDictionary *)config
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
