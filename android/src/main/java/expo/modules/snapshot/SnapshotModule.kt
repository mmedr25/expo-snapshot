package expo.modules.snapshot

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import android.app.Activity
import android.graphics.Bitmap
import android.os.Handler
import android.os.Looper
import android.util.Base64
import android.view.PixelCopy
import android.view.Window
import expo.modules.kotlin.Promise
import java.io.ByteArrayOutputStream
import android.util.Log


class SnapshotModule : Module() {
  private var cachedBitmap: Bitmap? = null
  private var cachedWidth = 0
  private var cachedHeight = 0

  override fun definition() = ModuleDefinition {
    Name("SnapshotModule")

    AsyncFunction("captureScreen") { options: Map<String, Any?>, promise: Promise ->
      val activity = appContext.currentActivity ?: run {
        promise.reject("E_NO_ACTIVITY", "No current activity", null)
        return@AsyncFunction
      }

      // Parse options
      val format = (options["format"] as? String)?.lowercase() ?: "png"
      val quality = ((options["quality"] as? Number)?.toInt() ?: if (format == "png") 100 else 90)
        .coerceIn(0, 100)

      val bitmapFormat = when (format) {
        "jpg", "jpeg" -> Bitmap.CompressFormat.JPEG
        else -> Bitmap.CompressFormat.PNG
      }

      val window: Window = activity.window
      val view = window.decorView
      val width = view.width
      val height = view.height

      if (width == 0 || height == 0) {
        promise.reject("E_INVALID_SIZE", "View has zero width or height", null)
      }

      view.post {
        val bitmap = getOrCreateBitmap(width, height)

        try {
          PixelCopy.request(window, bitmap, { copyResult ->
            if (copyResult == PixelCopy.SUCCESS) {
              ByteArrayOutputStream().use { outputStream ->
                bitmap.compress(bitmapFormat, quality, outputStream)
                val base64 = Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
                promise.resolve(base64)
              }
            } else {
              promise.reject("E_PIXEL_COPY_FAILED", "PixelCopy failed with code $copyResult", null)
            }
          }, Handler(Looper.getMainLooper()))
        } catch (e: Exception) {
          promise.reject("E_SNAPSHOT_FAILED", "Failed to take snapshot: ${e.message}", e)
        }
      }
    }
  }

  private fun getOrCreateBitmap(width: Int, height: Int): Bitmap {
    if (cachedBitmap == null || cachedWidth != width || cachedHeight != height) {
      cachedBitmap?.recycle()
      cachedBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
      cachedWidth = width
      cachedHeight = height
    }
    return cachedBitmap!!
  }

}