package com.athr.tayser

import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.util.Log
import com.paymob.paymob_sdk.PaymobSdk
import com.paymob.paymob_sdk.ui.PaymobSdkListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity : FlutterActivity(), MethodCallHandler, PaymobSdkListener {

    private val CHANNEL = "paymob_sdk_flutter"
    private var SDKResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "payWithPaymob") {
            SDKResult = result
            callNativeSDK(call)
        } else {
            result.notImplemented()
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    private fun callNativeSDK(call: MethodCall) {
        val publicKey = call.argument<String>("publicKey")
        val clientSecret = call.argument<String>("clientSecret")
        val appName = call.argument<String>("appName")
        val saveCardDefault = call.argument<Boolean>("saveCardDefault") ?: false
        val showSaveCard = call.argument<Boolean>("showSaveCard") ?: true

        var buttonBackgroundColor: Int? = null
        var buttonTextColor: Int? = null

        val buttonBackgroundColorData = call.argument<Number>("buttonBackgroundColor")?.toInt() ?: 0
        val buttonTextColorData = call.argument<Number>("buttonTextColor")?.toInt() ?: 0

        if (buttonTextColorData != null) {
            buttonTextColor = Color.argb(
                (buttonTextColorData shr 24) and 0xFF,
                (buttonTextColorData shr 16) and 0xFF,
                (buttonTextColorData shr 8) and 0xFF,
                buttonTextColorData and 0xFF
            )
        }

        if (buttonBackgroundColorData != null) {
            buttonBackgroundColor = Color.argb(
                (buttonBackgroundColorData shr 24) and 0xFF,
                (buttonBackgroundColorData shr 16) and 0xFF,
                (buttonBackgroundColorData shr 8) and 0xFF,
                buttonBackgroundColorData and 0xFF
            )
        }

        Log.d("PaymobSDK", "🔄 Starting payment...")

        try {
            val paymobsdk = PaymobSdk.Builder(
                context = this@MainActivity,
                clientSecret = clientSecret.toString(),
                publicKey = publicKey.toString(),
                paymobSdkListener = this,
            )
                .setButtonBackgroundColor(buttonBackgroundColor ?: Color.BLACK)
                .setButtonTextColor(buttonTextColor ?: Color.WHITE)
                .setAppName(appName)
                .showSaveCard(showSaveCard)
                .saveCardByDefault(saveCardDefault)
                .build()

            paymobsdk.start()
        } catch (e: Exception) {
            Log.e("PaymobSDK", "🔴 Error: ${e.message}")
            SDKResult?.error("SDK_ERROR", e.message, e.stackTraceToString())
            SDKResult = null
        }
    }

    override fun onSuccess(payResponse: HashMap<String, String?>) {
        Log.d("PaymobSDK", "🟢 Success!")
        SDKResult?.success("Successfull")
        SDKResult = null
    }

    override fun onFailure(msg: String?) {
        Log.d("PaymobSDK", "🔴 Rejected!")
        SDKResult?.success("Rejected")
        SDKResult = null
    }

    override fun onPending() {
        Log.d("PaymobSDK", "🟡 Pending!")
        SDKResult?.success("Pending")
        SDKResult = null
    }
}