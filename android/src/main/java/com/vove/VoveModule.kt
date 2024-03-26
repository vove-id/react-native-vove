package com.vove

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.UiThreadUtil.runOnUiThread
import com.voveid.sdk.VerificationResult
import com.voveid.sdk.Vove
import com.voveid.sdk.VoveEnvironment


class VoveModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  fun processIDMatching(env: String, sessionToken: String, promise: Promise) {
    val environment = determineEnvironment(env)
    val currentActivity = currentActivity
    currentActivity?.let {
      Vove.processIDMatching(
        it,
        environment,
        sessionToken
      ) { verificationResult: VerificationResult ->
        runOnUiThread {
          when (verificationResult) {
            VerificationResult.SUCCESS -> {
              promise.resolve("success")
            }

            VerificationResult.FAILURE -> {
              promise.reject("failure", "Verification failed")
            }

            VerificationResult.PENDING -> {
              promise.resolve("pending")
            }

            VerificationResult.CANCELLED -> {
              promise.resolve("cancelled")
            }
          }
        }
      }
    }
  }

  fun determineEnvironment(env: String): VoveEnvironment {
    return when (env) {
      "sandbox" -> VoveEnvironment.SANDBOX
      "production" -> VoveEnvironment.PRODUCTION
      else -> throw IllegalArgumentException("Unknown environment")
    }
  }
  companion object {
    const val NAME = "VoveModule"
  }
}
