package com.vove

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.UiThreadUtil.runOnUiThread
import com.voveid.sdk.VerificationResult
import com.voveid.sdk.Vove
import com.voveid.sdk.VoveEnvironment
import com.voveid.sdk.VoveLocale



class VoveModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  fun processIDMatching(params: ReadableMap, promise: Promise) {
    val sessionToken = params.getString("sessionToken")?.let { it } ?: ""
    var environment: VoveEnvironment = VoveEnvironment.SANDBOX
    try {
      environment = determineEnvironment(params.getString("environment")!!)
    } catch (e: IllegalArgumentException) {
      e.printStackTrace()
    }
    val locale: VoveLocale =
      params.getString("locale")
        ?.let { VoveLocale.valueOf(it) } ?: VoveLocale.EN
    val isVocalGuidanceEnabled = params.hasKey("enableVocalGuidance") && params.getBoolean("enableVocalGuidance")
    val currentActivity = currentActivity
    Vove.setLocale(currentActivity!!, locale)
    Vove.setEnableVocalGuidance(isVocalGuidanceEnabled)
    currentActivity?.let {
      Vove.start(
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
