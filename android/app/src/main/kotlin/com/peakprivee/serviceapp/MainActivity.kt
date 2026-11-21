package com.peakprivee.serviceapp

import android.graphics.Rect
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Screen areas where Android's edge back-swipe is switched off, so a
        // control sitting at the edge (the draggable orb) gets the touch
        // instead. Rects come as [left, top, right, bottom] in physical px.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app/gesture_exclusion")
            .setMethodCallHandler { call, result ->
                if (call.method != "setRects") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val raw = call.arguments as? List<*> ?: emptyList<Any>()
                    val rects = raw.mapNotNull { r ->
                        val v = (r as? List<*>)?.map { (it as Number).toInt() } ?: return@mapNotNull null
                        if (v.size == 4) Rect(v[0], v[1], v[2], v[3]) else null
                    }
                    window.decorView.systemGestureExclusionRects = rects
                }
                result.success(null)
            }
    }
}
