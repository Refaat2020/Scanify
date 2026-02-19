package com.code.way.task.code_way_task

import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.opencv.android.OpenCVLoader
import org.opencv.android.Utils
import org.opencv.core.*
import org.opencv.imgproc.Imgproc
import java.io.ByteArrayOutputStream
import android.graphics.Bitmap
import org.opencv.core.CvType

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.code/document_processor"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        OpenCVLoader.initLocal()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "processDocument" -> {
                        val imageBytes = call.argument<ByteArray>("imageBytes")!!
                        try {
                            val processed = processDocument(imageBytes)
                            result.success(processed)
                        } catch (e: Exception) {
                            result.error("PROCESSING_ERROR", e.message, null)
                        }
                    }
                    "detectCorners" -> {
                        val imageBytes = call.argument<ByteArray>("imageBytes")!!
                        try {
                            val corners = detectDocumentCorners(imageBytes)
                            result.success(corners)
                        } catch (e: Exception) {
                            result.error("DETECTION_ERROR", e.message, null)
                        }
                    }
                    "perspectiveTransform" -> {
                        val imageBytes = call.argument<ByteArray>("imageBytes")!!
                        val corners = call.argument<List<Double>>("corners")!!
                        try {
                            val transformed = applyPerspectiveTransform(imageBytes, corners)
                            result.success(transformed)
                        } catch (e: Exception) {
                            result.error("TRANSFORM_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun processDocument(imageBytes: ByteArray): ByteArray {
        val src = bytesToMat(imageBytes)
        val corners = findDocumentCorners(src) ?: return matToBytes(src)
        val warped = warpPerspective(src, corners)
        val enhanced = enhanceDocument(warped)
        return matToBytes(enhanced)
    }

    private fun detectDocumentCorners(imageBytes: ByteArray): List<Double>? {
        val src = bytesToMat(imageBytes)
        val corners = findDocumentCorners(src) ?: return null
        return corners.flatMap { listOf(it.x, it.y) }
    }

    private fun findDocumentCorners(src: Mat): List<Point>? {
        // ✅ Check if image is already a clean flat document
        // If the content fills >80% of frame with white/light background → skip detection
        if (isAlreadyCroppedDocument(src)) {
            android.util.Log.d("OpenCV", "✅ Image is already a clean document — using full frame")
            val m = 10.0
            return listOf(
                Point(m, m),
                Point(src.width() - m, m),
                Point(src.width() - m, src.height() - m),
                Point(m, src.height() - m),
            )
        }

        val gray = Mat()
        Imgproc.cvtColor(src, gray, Imgproc.COLOR_BGR2GRAY)

        return tryCannyMultiScale(gray, src)
            ?: tryAdaptiveThreshold(gray, src)
            ?: tryMorphologicalApproach(gray, src)
            ?: run {
                android.util.Log.d("OpenCV", "❌ all strategies failed — using full image")
                val m = 10.0
                listOf(
                    Point(m, m),
                    Point(src.width() - m, m),
                    Point(src.width() - m, src.height() - m),
                    Point(m, src.height() - m),
                )
            }
    }

    /// Returns true if the image is already a clean flat document scan.
/// Detects this by checking if the borders are predominantly white/light.
    private fun isAlreadyCroppedDocument(src: Mat): Boolean {
        return try {
            val gray = Mat()
            Imgproc.cvtColor(src, gray, Imgproc.COLOR_BGR2GRAY)

            val w = src.width()
            val h = src.height()
            val aspectRatio = maxOf(w, h).toDouble() / minOf(w, h).toDouble()

            if (aspectRatio !in 1.2..1.5) {
                android.util.Log.d("OpenCV", "isAlreadyCropped: false — aspectRatio=$aspectRatio")
                return false
            }

            val borderThickness = (minOf(w, h) * 0.08).toInt().coerceAtLeast(15)
            val medians = listOf(
                medianBrightness(gray.submat(0, borderThickness, 0, w)),
                medianBrightness(gray.submat(h - borderThickness, h, 0, w)),
                medianBrightness(gray.submat(0, h, 0, borderThickness)),
                medianBrightness(gray.submat(0, h, w - borderThickness, w))
            )
            val brightBorders = medians.count { it > 180 }
            android.util.Log.d("OpenCV", "isAlreadyCropped: medians=$medians brightBorders=$brightBorders")
            brightBorders >= 3
        } catch (e: Exception) {
            android.util.Log.d("OpenCV", "isAlreadyCropped crashed: ${e.message} — defaulting to false")
            false
        }
    }

    private fun medianBrightness(mat: Mat): Double {
        val continuous = mat.clone()
        // ✅ Use toList via get() instead of reshape — avoids continuity issues
        val totalPixels = continuous.rows() * continuous.cols()
        val data = ByteArray(totalPixels)
        // Read row by row safely
        val values = mutableListOf<Int>()
        for (row in 0 until continuous.rows()) {
            val rowData = ByteArray(continuous.cols())
            continuous.get(row, 0, rowData)
            rowData.forEach { values.add(it.toInt() and 0xFF) }
        }
        values.sort()
        return values[values.size / 2].toDouble()
    }
// ── Strategy 1: Multi-scale Canny — finds small cards on large backgrounds ──

    private fun tryCannyMultiScale(gray: Mat, src: Mat): List<Point>? {
        val srcArea = src.width() * src.height().toDouble()

        data class QuadCandidate(
            val pts: List<Point>,
            val score: Double,
            val aspectScore: Double,
            val area: Double
        )
        val allCandidates = mutableListOf<QuadCandidate>()

        for (blurSize in listOf(3.0, 5.0, 9.0)) {
            for ((low, high) in listOf(20.0 to 60.0, 40.0 to 120.0, 75.0 to 200.0)) {
                val blurred = Mat()
                val edges = Mat()
                Imgproc.GaussianBlur(gray, blurred, Size(blurSize, blurSize), 0.0)
                Imgproc.Canny(blurred, edges, low, high)

                val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(5.0, 5.0))
                Imgproc.dilate(edges, edges, kernel)

                val contours = mutableListOf<MatOfPoint>()
                Imgproc.findContours(edges, contours, Mat(), Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE)

                val candidates = contours
                    .filter { Imgproc.contourArea(it) / srcArea in 0.02..0.95 }
                    .sortedByDescending { Imgproc.contourArea(it) }

                for (candidate in candidates.take(8)) {
                    val quad = approxToQuad(candidate, src) ?: continue
                    val rectScore = rectangularityScore(quad)
                    if (rectScore > 80.0) continue

                    val (tl, tr, br, bl) = quad
                    val width = (Math.sqrt(Math.pow(tr.x - tl.x, 2.0) + Math.pow(tr.y - tl.y, 2.0)) +
                            Math.sqrt(Math.pow(br.x - bl.x, 2.0) + Math.pow(br.y - bl.y, 2.0))) / 2.0
                    val height = (Math.sqrt(Math.pow(bl.x - tl.x, 2.0) + Math.pow(bl.y - tl.y, 2.0)) +
                            Math.sqrt(Math.pow(br.x - tr.x, 2.0) + Math.pow(br.y - tr.y, 2.0))) / 2.0

                    // ✅ Reject quads that are too small relative to the image
                    // The document must cover at least 20% of width AND 20% of height
                    val widthRatio = width / src.width()
                    val heightRatio = height / src.height()
                    if (widthRatio < 0.20 || heightRatio < 0.20) {
                        android.util.Log.d("OpenCV", "Rejected: too small widthRatio=$widthRatio heightRatio=$heightRatio")
                        continue
                    }

                    val aspectRatio = maxOf(width, height) / minOf(width, height)
                    val knownRatios = listOf(1.586, 1.95, 1.414, 1.5, 1.333, 2.0)
                    val aspectScore = knownRatios.minOf { Math.abs(aspectRatio - it) }
                    val area = Imgproc.contourArea(candidate) / srcArea

                    android.util.Log.d("OpenCV",
                        "blur=$blurSize canny=$low/$high area=$area " +
                                "rectScore=$rectScore aspectRatio=$aspectRatio aspectScore=$aspectScore " +
                                "widthRatio=$widthRatio heightRatio=$heightRatio")

                    allCandidates.add(QuadCandidate(quad, rectScore, aspectScore, area))
                }
            }
        }

        if (allCandidates.isEmpty()) return null

        // Among good aspect matches, prefer the LARGEST area (whole card over internal elements)
        val goodAspect = allCandidates.filter { it.aspectScore < 0.3 }
        val pool = if (goodAspect.isNotEmpty()) goodAspect else allCandidates

        val best = pool.maxByOrNull { it.area }!! // ✅ largest area wins among good candidates
        android.util.Log.d("OpenCV",
            "✅ Best quad rectScore=${best.score} aspectScore=${best.aspectScore} area=${best.area}")
        return best.pts
    }

// ── Strategy 2: Adaptive threshold — handles uneven lighting on cards ────────

    private fun tryAdaptiveThreshold(gray: Mat, src: Mat): List<Point>? {
        val srcArea = src.width() * src.height().toDouble()
        val thresh = Mat()
        val edges = Mat()

        Imgproc.adaptiveThreshold(
            gray, thresh, 255.0,
            Imgproc.ADAPTIVE_THRESH_GAUSSIAN_C,
            Imgproc.THRESH_BINARY, 21, 5.0
        )
        // Invert so card appears as white blob on dark background
        Core.bitwise_not(thresh, thresh)

        val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(7.0, 7.0))
        Imgproc.morphologyEx(thresh, thresh, Imgproc.MORPH_CLOSE, kernel)
        Imgproc.Canny(thresh, edges, 10.0, 50.0)

        val contours = mutableListOf<MatOfPoint>()
        Imgproc.findContours(edges, contours, Mat(), Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE)

        val candidate = contours
            .filter { Imgproc.contourArea(it) / srcArea in 0.02..0.95 }
            .maxByOrNull { Imgproc.contourArea(it) } ?: return null

        val quad = approxToQuad(candidate, src) ?: return null
        val score = rectangularityScore(quad)
        android.util.Log.d("OpenCV", "Strategy 2 score=$score")
        return if (score < 80.0) quad else null
    }

// ── Strategy 3: Morphological closing ────────────────────────────────────────

    private fun tryMorphologicalApproach(gray: Mat, src: Mat): List<Point>? {
        val srcArea = src.width() * src.height().toDouble()
        val closed = Mat()
        val edges = Mat()

        val closeKernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(15.0, 15.0))
        Imgproc.morphologyEx(gray, closed, Imgproc.MORPH_CLOSE, closeKernel)
        Imgproc.Canny(closed, edges, 10.0, 50.0)

        val dilKernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(7.0, 7.0))
        Imgproc.dilate(edges, edges, dilKernel)

        val contours = mutableListOf<MatOfPoint>()
        Imgproc.findContours(edges, contours, Mat(), Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE)

        val candidate = contours
            .filter { Imgproc.contourArea(it) / srcArea in 0.02..0.95 }
            .maxByOrNull { Imgproc.contourArea(it) } ?: return null

        val quad = approxToQuad(candidate, src) ?: return null
        val score = rectangularityScore(quad)
        android.util.Log.d("OpenCV", "Strategy 3 score=$score")
        return if (score < 80.0) quad else null
    }

    private fun findBestQuad(edges: Mat, src: Mat): List<Point>? {
        val contours = mutableListOf<MatOfPoint>()
        Imgproc.findContours(edges, contours, Mat(), Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE)

        val srcArea = src.width() * src.height().toDouble()

        val candidate = contours
            .filter { contour ->
                val area = Imgproc.contourArea(contour)
                val ratio = area / srcArea
                if (ratio < 0.10) return@filter false

                // Reject if contour area fills less than 50% of its own bounding rect
                // (means it's an irregular blob, not a document shape)
                val rect = Imgproc.boundingRect(contour)
                val rectArea = rect.width * rect.height.toDouble()
                val solidity = area / rectArea
                android.util.Log.d("OpenCV", "ratio=$ratio solidity=$solidity")
                solidity > 0.5
            }
            .maxByOrNull { Imgproc.contourArea(it) }
            ?: return null

        return approxToQuad(candidate, src)
    }

    private fun approxToQuad(contour: MatOfPoint, src: Mat): List<Point>? {
        val hullIdx = MatOfInt()
        Imgproc.convexHull(contour, hullIdx)

        val hullPoints = hullIdx.toArray().map { idx -> contour.toArray()[idx] }
        val hullMat = MatOfPoint2f(*hullPoints.toTypedArray())
        val peri = Imgproc.arcLength(hullMat, true)

        var bestQuad: List<Point>? = null
        var bestScore = Double.MAX_VALUE

        for (epsilon in listOf(0.02, 0.03, 0.04, 0.05, 0.06, 0.08, 0.10)) {
            val approx = MatOfPoint2f()
            Imgproc.approxPolyDP(hullMat, approx, epsilon * peri, true)
            val pts = approx.toArray().toList()

            if (pts.size == 4) {
                // Score = how close to a perfect rectangle (lower = better)
                val score = rectangularityScore(pts)
                android.util.Log.d("OpenCV", "epsilon=$epsilon pts=4 score=$score")
                if (score < bestScore) {
                    bestScore = score
                    bestQuad = orderPoints(pts)
                }
            }
        }

        if (bestQuad != null) {
            android.util.Log.d("OpenCV", "best quad score=$bestScore")
            return bestQuad
        }

        // Fallback to bounding rect
        val rect = Imgproc.boundingRect(MatOfPoint(*hullPoints.toTypedArray()))
        return orderPoints(listOf(
            Point(rect.x.toDouble(), rect.y.toDouble()),
            Point((rect.x + rect.width).toDouble(), rect.y.toDouble()),
            Point((rect.x + rect.width).toDouble(), (rect.y + rect.height).toDouble()),
            Point(rect.x.toDouble(), (rect.y + rect.height).toDouble()),
        ))
    }

    /// Scores how rectangular a quad is.
/// Measures deviation of all 4 angles from 90°.
/// Perfect rectangle = 0.0
    private fun rectangularityScore(pts: List<Point>): Double {
        var totalDeviation = 0.0
        for (i in pts.indices) {
            val a = pts[(i + 3) % 4]  // previous point
            val b = pts[i]              // current point
            val c = pts[(i + 1) % 4]  // next point

            // Vectors from b→a and b→c
            val v1x = a.x - b.x; val v1y = a.y - b.y
            val v2x = c.x - b.x; val v2y = c.y - b.y

            val dot = v1x * v2x + v1y * v2y
            val mag1 = Math.sqrt(v1x * v1x + v1y * v1y)
            val mag2 = Math.sqrt(v2x * v2x + v2y * v2y)

            if (mag1 == 0.0 || mag2 == 0.0) return Double.MAX_VALUE

            val cosAngle = (dot / (mag1 * mag2)).coerceIn(-1.0, 1.0)
            val angleDeg = Math.toDegrees(Math.acos(cosAngle))
            totalDeviation += Math.abs(angleDeg - 90.0)
        }
        return totalDeviation // 0.0 = perfect rectangle
    }

    private fun orderPoints(pts: List<Point>): List<Point> {
        // Sort by x+y sum: TL has smallest, BR has largest
        val sortedBySum = pts.sortedBy { it.x + it.y }
        val tl = sortedBySum.first()
        val br = sortedBySum.last()

        // Of the remaining two: TR has smaller y, BL has larger y
        val remaining = sortedBySum.drop(1).dropLast(1)
        val tr = remaining.minByOrNull { it.y }!!
        val bl = remaining.maxByOrNull { it.y }!!

        return listOf(tl, tr, br, bl)
    }

    private fun applyPerspectiveTransform(imageBytes: ByteArray, rawCorners: List<Double>): ByteArray {
        val src = bytesToMat(imageBytes)
        val corners = (rawCorners.indices step 2).map { i ->
            Point(rawCorners[i], rawCorners[i + 1])
        }
        val warped = warpPerspective(src, corners)
        return matToBytes(warped)
    }

    private fun warpPerspective(src: Mat, corners: List<Point>): Mat {
        val (tl, tr, br, bl) = corners

        val widthA = Math.sqrt(Math.pow(br.x - bl.x, 2.0) + Math.pow(br.y - bl.y, 2.0))
        val widthB = Math.sqrt(Math.pow(tr.x - tl.x, 2.0) + Math.pow(tr.y - tl.y, 2.0))
        val maxWidth = maxOf(widthA, widthB).toInt()

        val heightA = Math.sqrt(Math.pow(tr.x - br.x, 2.0) + Math.pow(tr.y - br.y, 2.0))
        val heightB = Math.sqrt(Math.pow(tl.x - bl.x, 2.0) + Math.pow(tl.y - bl.y, 2.0))
        val maxHeight = maxOf(heightA, heightB).toInt()

        val srcMat = MatOfPoint2f(tl, tr, br, bl)
        val dstMat = MatOfPoint2f(
            Point(0.0, 0.0),
            Point(maxWidth - 1.0, 0.0),
            Point(maxWidth - 1.0, maxHeight - 1.0),
            Point(0.0, maxHeight - 1.0),
        )

        val M = Imgproc.getPerspectiveTransform(srcMat, dstMat)
        val warped = Mat()
        Imgproc.warpPerspective(src, warped, M, Size(maxWidth.toDouble(), maxHeight.toDouble()))

        // ✅ Auto-rotate so the longer dimension is always the width (landscape)
        return if (warped.height() > warped.width()) {
            val rotated = Mat()
            Core.rotate(warped, rotated, Core.ROTATE_90_CLOCKWISE)
            rotated
        } else {
            warped
        }
    }

    private fun enhanceDocument(src: Mat): Mat {
        val aspectRatio = maxOf(src.width(), src.height()).toDouble() / minOf(src.width(), src.height())
        return if (aspectRatio in 1.3..2.2) enhanceCard(src) else enhanceTextDocument(src)
    }

    private fun enhanceCard(src: Mat): Mat {
        val bgr = Mat()
        when (src.channels()) {
            1 -> Imgproc.cvtColor(src, bgr, Imgproc.COLOR_GRAY2BGR)
            4 -> Imgproc.cvtColor(src, bgr, Imgproc.COLOR_RGBA2BGR)
            else -> src.copyTo(bgr)
        }
        val blurred = Mat()
        val result = Mat()
        Imgproc.GaussianBlur(bgr, blurred, Size(0.0, 0.0), 3.0)
        Core.addWeighted(bgr, 1.5, blurred, -0.5, 0.0, result)
        return result
    }

    private fun enhanceTextDocument(src: Mat): Mat {
        val gray = Mat()
        val enhanced = Mat()
        when (src.channels()) {
            1 -> src.copyTo(gray)
            else -> Imgproc.cvtColor(src, gray, Imgproc.COLOR_BGR2GRAY)
        }
        Imgproc.adaptiveThreshold(
            gray, enhanced, 255.0,
            Imgproc.ADAPTIVE_THRESH_GAUSSIAN_C,
            Imgproc.THRESH_BINARY, 11, 10.0
        )
        return enhanced
    }

    private fun matToBytes(mat: Mat): ByteArray {
        val displayMat = Mat()
        when (mat.channels()) {
            1 -> Imgproc.cvtColor(mat, displayMat, Imgproc.COLOR_GRAY2RGBA)
            3 -> Imgproc.cvtColor(mat, displayMat, Imgproc.COLOR_BGR2RGBA)
            4 -> mat.copyTo(displayMat)
            else -> mat.copyTo(displayMat)
        }
        val bitmap = Bitmap.createBitmap(displayMat.cols(), displayMat.rows(), Bitmap.Config.ARGB_8888)
        Utils.matToBitmap(displayMat, bitmap)
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 95, stream)
        return stream.toByteArray()
    }
    private fun bytesToMat(bytes: ByteArray): Mat {
        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
            ?: throw IllegalArgumentException("Failed to decode bitmap, bytes size: ${bytes.size}")

        // Ensure ARGB_8888 format — copy only if needed
        val argbBitmap = if (bitmap.config == Bitmap.Config.ARGB_8888) {
            bitmap
        } else {
            bitmap.copy(Bitmap.Config.ARGB_8888, false)
                ?: throw IllegalArgumentException("Failed to convert bitmap to ARGB_8888, config: ${bitmap.config}")
        }

        android.util.Log.d("OpenCV", "bitmap config: ${argbBitmap.config} size: ${argbBitmap.width}x${argbBitmap.height}")

        val rgbaMat = Mat(argbBitmap.height, argbBitmap.width, CvType.CV_8UC4)
        Utils.bitmapToMat(argbBitmap, rgbaMat)

        android.util.Log.d("OpenCV", "rgbaMat type: ${rgbaMat.type()} channels: ${rgbaMat.channels()}")

        val bgrMat = Mat()
        Imgproc.cvtColor(rgbaMat, bgrMat, Imgproc.COLOR_RGBA2BGR)

        android.util.Log.d("OpenCV", "bgrMat type: ${bgrMat.type()} channels: ${bgrMat.channels()}")

        return bgrMat
    }

}