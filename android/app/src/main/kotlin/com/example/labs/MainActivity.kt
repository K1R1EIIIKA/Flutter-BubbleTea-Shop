package com.example.labs

import android.content.Intent
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.webkit.WebView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val instance = Integer.toHexString(System.identityHashCode(this))
    private var catalogChannel: CatalogChannel? = null
    private var newsChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        catalogChannel = CatalogChannel(this, messenger)
        newsChannel = MethodChannel(messenger, "bubble_tea/news").apply {
            setMethodCallHandler { call, result ->
                if (call.method == "canUseWebView") {
                    result.success(canUseNewsWebView())
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        catalogChannel?.close()
        catalogChannel = null
        newsChannel?.setMethodCallHandler(null)
        newsChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun canUseNewsWebView(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        val provider = WebView.getCurrentWebViewPackage() ?: return false

        // This x86_64 build crashes in Chromium before a WebView can report an error.
        return !(provider.packageName == "com.google.android.webview" &&
            provider.versionName == "158.0.8127.46" &&
            Build.SUPPORTED_ABIS.firstOrNull() == "x86_64")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        log("onCreate restored=${savedInstanceState != null}")
        super.onCreate(savedInstanceState)
        CatalogRefreshWorker.schedule(applicationContext)
    }

    override fun onStart() {
        super.onStart()
        log("onStart")
    }

    override fun onResume() {
        super.onResume()
        log("onResume")
    }

    override fun onPause() {
        log("onPause")
        super.onPause()
    }

    override fun onStop() {
        log("onStop")
        super.onStop()
    }

    override fun onDestroy() {
        log("onDestroy finishing=$isFinishing")
        super.onDestroy()
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        log("onSaveInstanceState")
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        log("onConfigurationChanged orientation=${newConfig.orientation}")
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (catalogChannel?.onActivityResult(requestCode, resultCode, data) != true) {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    private fun log(event: String) = Log.i("BubbleTeaLifecycle", "$instance $event")
}
