package com.vove

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.UiThreadUtil.runOnUiThread
import com.facebook.react.bridge.Arguments
import com.voveid.sdk.Vove
import com.voveid.sdk.VoveEnvironment
import com.voveid.sdk.VoveLocale
import com.voveid.sdk.model.VerificationResult


class VoveModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  fun start(params: ReadableMap, promise: Promise) {
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
    val showUI = !params.hasKey("showUI") || params.getBoolean("showUI")
    val currentActivity = currentActivity
    Vove.setLocale(currentActivity!!, locale)
    Vove.setEnableVocalGuidance(isVocalGuidanceEnabled)
    currentActivity?.let {
      Vove.start(
        it,
        sessionToken,
        showUI,
      ) { verificationResult: VerificationResult, action: String? ->
        runOnUiThread {
          when (verificationResult) {
            VerificationResult.SUCCESS ->
              promise.resolve(createResult("success"))
            VerificationResult.FAILURE ->
              promise.resolve(createResult("failure"))
            VerificationResult.PENDING ->
              promise.resolve(createResult("pending"))
            VerificationResult.CANCELLED ->
              promise.resolve(createResult("cancelled"))
            VerificationResult.MAX_ATTEMPTS_REACHED ->
              promise.resolve(createResult("max-attempts", action))
          }
        }
      }
    }
  }

  @ReactMethod
  fun initialize(params: ReadableMap, promise: Promise) {
    val sessionToken = params.getString("publicKey")?.let { it } ?: ""
    var environment: VoveEnvironment = VoveEnvironment.SANDBOX
    try {
      environment = determineEnvironment(params.getString("environment")!!)
    } catch (e: IllegalArgumentException) {
      e.printStackTrace()
    }
    val currentActivity = currentActivity
    currentActivity?.let {
      Vove.initialize(
        it,
        environment,
        sessionToken
      ) { isInitialized: Boolean ->
        if (isInitialized) {
          promise.resolve("success")
        } else {
          promise.reject("failure", "Initialization failed")
        }
      }
    }
  }

  private fun createResult(status: String, action: String? = null): com.facebook.react.bridge.WritableMap {
    val result = Arguments.createMap()
    result.putString("status", status)
    if (action != null) {
      result.putString("action", action)
    }
    return result
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
