import VoveSDK

@objc(VoveModule)
class VoveModule: NSObject {
  @objc(processIDMatching:withSessionToken:withResolver:withRejecter:)
  func processIDMatching(env: String, sessionToken: String, resolve: @escaping RCTPromiseResolveBlock,reject: @escaping RCTPromiseRejectBlock) -> Void {
      let voveEnv: VoveEnvironment = {
              switch env {
              case "sandbox":
                  return .sandbox
              case "production":
                  return .production
              default:
                  fatalError("Unknown environment")
              }
          }()
      DispatchQueue.main.async {
          Vove.processIDMatching(environment: voveEnv, sessionToken: sessionToken) { verificationResult in
              switch (verificationResult) {
              case .failure:
                  let error = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: "Verification failed"])
                  reject("failed", "Verification failed", error)
                  break
              case .pending: resolve("pending")
                  break
              case .success: resolve("success")
                  break
              case .canceled: resolve("canceled")
                  break
              case .none:
                  resolve("canceled")
              case .some(_):
                  resolve("canceled")
              }
          }
      }

  }
}
