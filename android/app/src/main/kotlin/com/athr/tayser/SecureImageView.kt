package com.athr.tayser

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Rect
import android.graphics.drawable.Drawable
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.View
import android.widget.FrameLayout
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.CustomTarget
import com.bumptech.glide.request.transition.Transition
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class SecureImagePlatformView(
    private val context: Context,
    private val args: Map<*, *>?,
    private val messenger: io.flutter.plugin.common.BinaryMessenger,
    private val id: Int,
) : PlatformView {

    private val frameLayout = FrameLayout(context)
    private val surfaceView = SurfaceView(context)

    private var currentBitmap: Bitmap? = null
    private var isSurfaceReady = false

    private val channel = MethodChannel(messenger, "secure_image_view_$id")

    init {
        surfaceView.apply {
            setSecure(true)
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }

        frameLayout.addView(surfaceView)

        surfaceView.holder.addCallback(object : SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                isSurfaceReady = true
                // ✅ لو الصورة اتحملت قبل ما الـ surface يكون ready، ارسمها دلوقتي
                currentBitmap?.let { drawBitmap(it) }
            }

            override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
                // ✅ لما الـ size يتغير، أعد الرسم
                currentBitmap?.let { drawBitmap(it) }
            }

            override fun surfaceDestroyed(holder: SurfaceHolder) {
                isSurfaceReady = false
            }
        })

        // ✅ حمّل الصورة من الـ args
        val url = args?.get("url") as? String
        if (!url.isNullOrEmpty()) {
            loadImage(url)
        }

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "setUrl" -> {
                    val newUrl = call.argument<String>("url")
                    if (!newUrl.isNullOrEmpty()) loadImage(newUrl)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun loadImage(url: String) {
        Glide.with(context)
            .asBitmap()
            .load(url)
            .into(object : CustomTarget<Bitmap>() {
                override fun onResourceReady(
                    resource: Bitmap,
                    transition: Transition<in Bitmap>?
                ) {
                    currentBitmap = resource
                    if (isSurfaceReady) {
                        drawBitmap(resource)
                    }
                    // لو surface مش ready، هيتعمل في surfaceCreated
                }

                override fun onLoadCleared(placeholder: Drawable?) {
                    currentBitmap = null
                }
            })
    }

    private fun drawBitmap(bitmap: Bitmap) {
        val holder = surfaceView.holder
        if (!holder.surface.isValid) return

        var canvas: Canvas? = null
        try {
            canvas = holder.lockCanvas()
            if (canvas != null) {
                val src = Rect(0, 0, bitmap.width, bitmap.height)
                val dst = Rect(0, 0, canvas.width, canvas.height)
                canvas.drawBitmap(bitmap, src, dst, null)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            if (canvas != null) {
                try {
                    holder.unlockCanvasAndPost(canvas)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    override fun getView(): View = frameLayout

    override fun dispose() {
        channel.setMethodCallHandler(null)
        currentBitmap = null
        isSurfaceReady = false
    }
}

class SecureImageFactory(
    private val messenger: io.flutter.plugin.common.BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        return SecureImagePlatformView(context, args as? Map<*, *>, messenger, id)
    }
}
