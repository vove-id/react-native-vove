import VoveSDK

@objc(VoveModule)
class VoveModule: NSObject {
    @objc(start:withResolver:withRejecter:)
    func start(config: NSDictionary, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        guard let sessionToken = config["sessionToken"] as? String else {
              let error = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: "Invalid parameters"])
              reject("error", "Invalid parameters", error)
              return
          }
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
          Vove.start(sessionToken: sessionToken) { verificationResult in
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
  @objc(initialize:withResolver:withRejecter:)
      func initialize(config: NSDictionary, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        guard let environment = config["environment"] as? String,
                  let publicKey = config["publicKey"] as? String else {
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

          DispatchQueue.main.async {
              Vove.initialize(publicKey: publicKey, environment: voveEnv) { result in
                  switch(result) {
                  case .success:
                      resolve("success")
                      break
                  case .failure:
                      let error = NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: "Initialization failed"])
                      reject("failure", "Initialization failed", error)
                      break
                  }
              }
          }
        }
}
