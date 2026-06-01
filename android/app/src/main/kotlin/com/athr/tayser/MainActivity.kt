package com.athr.tayser

import android.content.Intent
import android.database.ContentObserver
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val SCREENSHOT_EVENT_CHANNEL = "com.athr.tayser/screenshot_events"
    private val SECURE_CHANNEL = "com.athr.tayser/secure_window"

    private var eventSink: EventChannel.EventSink? = null
    private var contentObserver: ContentObserver? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ✅ Register SecureImageView platform view
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "secure_image_view",
            SecureImageFactory(flutterEngine.dartExecutor.binaryMessenger)
        )

        // ✅ FLAG_SECURE channel — لحماية شاشة الزواج من الـ screenshot
        // ⚠️ ملاحظة: FLAG_SECURE يمنع ExoPlayer من عرض الفيديو على بعض الأجهزة
        // لذلك يجب تفعيله فقط في الشاشات التي تحتاجه وليس بشكل عام
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableSecure" -> {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    "disableSecure" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

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

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
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
}
