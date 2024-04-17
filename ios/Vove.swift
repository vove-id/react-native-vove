import VoveSDK

@objc(VoveModule)
class VoveModule: NSObject {
    @objc(processIDMatching:withResolver:withRejecter:)
    func processIDMatching(config: NSDictionary, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
      guard let environment = config["environment"] as? String,
                let sessionToken = config["sessionToken"] as? String else {
              let error = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: "Invalid parameters"])
              reject("error", "Invalid parameters", error)
              return
          }
      let voveEnv: VoveEnvironment = {
          switch environment {
              case "sandbox":
                  return .sandbox
              case "production":
                  return .production
              default:
                  fatalError("Unknown environment")
              }
          }()
        if let locale = config["locale"] as? String {
            let voveLocal: VoveLocale = {
                switch locale {
                case "AR":
                    return .ar
                case "AR_MA":
                    return .arMA
                case "FR":
                    return .fr
                default:
                    return .en
                }
            }()
            Vove.setLocal(local: voveLocal)
        }
        if let enableVocalGuidance = config["enableVocalGuidance"] as? Bool {
            Vove.setVocalGuidanceEnabled(enableVocalGuidance)
        }
      DispatchQueue.main.async {
          Vove.processIDMatching(environment: voveEnv, sessionToken: sessionToken) { verificationResult in
              switch (verificationResult) {
              case .failure:
                  let error = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: "Verification failed"])
                  reject("failure", "Verification failed", error)
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
