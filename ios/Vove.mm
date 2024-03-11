#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(VoveModule, NSObject)

RCT_EXTERN_METHOD(processIDMatching:(NSString)a withEnv:(NSString)sessionToken
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
