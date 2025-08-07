import VoveSDK
import React

@objc(VoveModule)
class VoveModule: RCTEventEmitter {
    
    override func supportedEvents() -> [String]! {
        return ["onMaxAttemptsCallToAction"]
    }
    
    private var hasMaxAttemptsListener = false
    
    @objc(setMaxAttemptsListenerActive:)
    func setMaxAttemptsListenerActive(active: NSNumber) {
      hasMaxAttemptsListener = active.boolValue
    }
        
    private func sendEvent(name: String, body: Any?) {
        // Send event to React Native
        self.sendEvent(withName: name, body: body)
    }
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
                case "DE":
                    return .de
                default:
                    return .en
                }
            }()
            Vove.setLocal(local: voveLocal)
        }
        if let enableVocalGuidance = config["enableVocalGuidance"] as? Bool {
            Vove.setVocalGuidanceEnabled(enableVocalGuidance)
        }
      
        let showUI = (config["showUI"] as? Bool) ?? true
        
        let handleVerificationResult = { (verificationResult: VoveSDK.VerificationResult?) in
            switch (verificationResult) {
            case .success:
                resolve("success")
            case .failure:
                resolve("failure")
            case .pending:
                resolve("pending")
            case .canceled:
                resolve("cancelled")
            case .maxAttempts:
                resolve("max-attempts")
              break
            case .none:
              break
            case .some(_):
              break
            }
        }
      
        DispatchQueue.main.async {
            print("hasMaxAttemptsListener: \(self.hasMaxAttemptsListener)")
            // Check if we have max attempts listener active
            if self.hasMaxAttemptsListener {
                Vove.start(sessionToken: sessionToken, showUI: showUI, completion: handleVerificationResult, maxAttemptsActionCallback: {
                    handleVerificationResult(VoveSDK.VerificationResult.maxAttempts)    
                    self.sendEvent(name: "onMaxAttemptsCallToAction", body: nil)
                })
            } else {
                Vove.start(sessionToken: sessionToken, showUI: showUI, completion: handleVerificationResult)
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
