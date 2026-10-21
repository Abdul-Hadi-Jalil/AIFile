package com.example.aifile

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aifile/pdf")
        channel.setMethodCallHandler { call, result ->
            if (call.method == "getInitialPdf") {
                try {
                    result.success(pdfPath(intent))
                } catch (e: Exception) {
                    result.error("PDF_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        try {
            pdfPath(intent)?.let { channel.invokeMethod("openPdf", it) }
        } catch (e: Exception) {
            channel.invokeMethod("pdfError", e.message)
        }
    }

    private fun pdfPath(intent: Intent?): String? {
        val uri: Uri = when (intent?.action) {
            Intent.ACTION_VIEW -> intent.data
            Intent.ACTION_SEND -> {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
            }
            else -> null
        } ?: return null
        if (uri.scheme == "file") return uri.path

        // The Flutter viewer needs a local path for content URIs.
        val file = File.createTempFile("shared_", ".pdf", cacheDir)
        val input = contentResolver.openInputStream(uri)
            ?: throw IllegalStateException("Cannot read this PDF")
        input.use { source -> file.outputStream().use { source.copyTo(it) } }
        return file.absolutePath
    }
}
