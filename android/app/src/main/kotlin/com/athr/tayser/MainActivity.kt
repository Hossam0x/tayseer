package com.athr.tayser

import android.content.Intent
import android.database.ContentObserver
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.util.Log
import android.view.WindowManager
import com.paymob.paymob_sdk.PaymobSdk
import com.paymob.paymob_sdk.ui.PaymobSdkListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity : FlutterActivity(), MethodCallHandler, PaymobSdkListener {

    private val CHANNEL = "paymob_sdk_flutter"
    private val SCREENSHOT_EVENT_CHANNEL = "com.athr.tayser/screenshot_events"
    private var SDKResult: MethodChannel.Result? = null

    private var eventSink: EventChannel.EventSink? = null
    private var contentObserver: ContentObserver? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(this)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SCREENSHOT_EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    startWatchingScreenshots()
                }
                override fun onCancel(arguments: Any?) {
                    stopWatchingScreenshots()
                    eventSink = null
                }
            })
    }

    private fun startWatchingScreenshots() {
        contentObserver = object : ContentObserver(handler) {
            override fun onChange(selfChange: Boolean, uri: Uri?) {
                super.onChange(selfChange, uri)
                uri?.let {
                    val path = it.toString().lowercase()
                    if (path.contains("screenshot") || path.contains("screenshots")) {
                        eventSink?.success(true)
                        handler.postDelayed({ eventSink?.success(false) }, 1500)
                    }
                }
            }
        }
        contentResolver.registerContentObserver(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            true,
            contentObserver!!
        )
    }

    private fun stopWatchingScreenshots() {
        contentObserver?.let { contentResolver.unregisterContentObserver(it) }
        contentObserver = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "payWithPaymob" -> {
                SDKResult = result
                callNativeSDK(call)
            }
            "setSecure" -> {
                val enable = call.argument<Boolean>("enable") ?: false
                if (enable) {
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    )
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(null)
            }
            else -> result.notImplemented()
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
