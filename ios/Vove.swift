import VoveSDK

@objc(VoveModule)
class VoveModule: NSObject {
  @objc(processIDMatching:withB:withResolver:withRejecter:)
  func processIDMatching(env: String, sessionToken: String, resolve: @escaping RCTPromiseResolveBlock,reject: @escaping RCTPromiseRejectBlock) -> Void {
      
      Vove.processIDMatching(sessionToken: sessionToken) { verificationResult in
          switch (verificationResult) {
          case .failure: resolve("failed")
              break
          case .pending: resolve("pending")
              break
          case .success: resolve("success")
              break
//          case .canceled: resolve("canceled")
//              break
          case .none:
              resolve("canceled")
          case .some(_):
              resolve("canceled")
          }
      }
  }
}
