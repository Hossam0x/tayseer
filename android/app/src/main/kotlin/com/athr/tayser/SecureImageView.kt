package com.athr.tayser

import android.content.Context
import android.view.SurfaceView
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class SecureImagePlatformView(context: Context) : PlatformView {
    private val frameLayout = FrameLayout(context)
    private val surfaceView = SurfaceView(context).apply {
        // ✅ SurfaceView.setSecure() — الـ OS بيجعل هذا الـ layer أسود في الـ screenshot
        setSecure(true)
        layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
    }

    init {
        frameLayout.addView(surfaceView)
    }

    override fun getView(): View = frameLayout
    override fun dispose() {}
}

class SecureImageFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        return SecureImagePlatformView(context)
    }
}
