package invalid.placeholder.mfw_app

import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Issue file storage for MOD-06 (CODING_STANDARDS.md section 8.2):
        // app-specific internal storage that Auto Backup leaves out, and the
        // free space before a download (RS FR-STATE-004).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "mfw/storage")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "issueDirectory" -> {
                        val dir = File(noBackupFilesDir, "issues")
                        if (dir.isDirectory || dir.mkdirs()) {
                            result.success(dir.absolutePath)
                        } else {
                            result.error("storage", null, null)
                        }
                    }
                    "freeBytes" -> {
                        val path = call.arguments as? String ?: noBackupFilesDir.absolutePath
                        try {
                            result.success(StatFs(path).availableBytes)
                        } catch (error: IllegalArgumentException) {
                            result.error("storage", null, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
