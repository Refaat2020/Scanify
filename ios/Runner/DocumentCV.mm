#import "DocumentCV.h"
#import <opencv2/core.hpp>
#import <opencv2/imgcodecs.hpp>
#import <opencv2/imgproc.hpp>

@implementation DocumentCV

+ (NSData *)processDocument:(NSData *)imageData {
    std::vector<uchar> buf((uchar *)imageData.bytes, (uchar *)imageData.bytes + imageData.length);
    cv::Mat src = cv::imdecode(buf, cv::IMREAD_COLOR);
    if (src.empty()) return nil;

    std::vector<cv::Point2f> corners = [self findDocumentCorners:src];
    cv::Mat warped = [self warpPerspective:src corners:corners];
    cv::Mat enhanced = [self enhanceDocument:warped];

    std::vector<uchar> outBuf;
    cv::imencode(".jpg", enhanced, outBuf, {cv::IMWRITE_JPEG_QUALITY, 95});
    return [NSData dataWithBytes:outBuf.data() length:outBuf.size()];
}

+ (NSArray<NSNumber *> *)detectCorners:(NSData *)imageData {
    std::vector<uchar> buf((uchar *)imageData.bytes, (uchar *)imageData.bytes + imageData.length);
    cv::Mat src = cv::imdecode(buf, cv::IMREAD_COLOR);
    if (src.empty()) return nil;

    std::vector<cv::Point2f> corners = [self findDocumentCorners:src];
    if (corners.size() != 4) return nil;

    NSMutableArray *result = [NSMutableArray array];
    for (auto &p : corners) {
        [result addObject:@(p.x)];
        [result addObject:@(p.y)];
    }
    return result;
}

+ (NSData *)perspectiveTransform:(NSData *)imageData corners:(NSArray<NSNumber *> *)rawCorners {
    std::vector<uchar> buf((uchar *)imageData.bytes, (uchar *)imageData.bytes + imageData.length);
    cv::Mat src = cv::imdecode(buf, cv::IMREAD_COLOR);
    if (src.empty()) return nil;

    std::vector<cv::Point2f> corners;
    for (int i = 0; i < 8; i += 2) {
        corners.push_back(cv::Point2f(rawCorners[i].floatValue, rawCorners[i+1].floatValue));
    }

    cv::Mat warped = [self warpPerspective:src corners:corners];
    std::vector<uchar> outBuf;
    cv::imencode(".jpg", warped, outBuf, {cv::IMWRITE_JPEG_QUALITY, 95});
    return [NSData dataWithBytes:outBuf.data() length:outBuf.size()];
}

// ── Corner detection ─────────────────────────────────────────────────────────

+ (std::vector<cv::Point2f>)findDocumentCorners:(cv::Mat &)src {
    // Check if already a clean document
    if ([self isAlreadyCroppedDocument:src]) {
        NSLog(@"OpenCV: already cropped document — using full frame");
        double m = 10.0;
        return { {(float)m, (float)m},
                 {(float)(src.cols - m), (float)m},
                 {(float)(src.cols - m), (float)(src.rows - m)},
                 {(float)m, (float)(src.rows - m)} };
    }

    cv::Mat gray;
    cv::cvtColor(src, gray, cv::COLOR_BGR2GRAY);

    auto result = [self tryCannyMultiScale:gray src:src];
    if (!result.empty()) return result;

    result = [self tryAdaptiveThreshold:gray src:src];
    if (!result.empty()) return result;

    result = [self tryMorphologicalApproach:gray src:src];
    if (!result.empty()) return result;

    // Full image fallback
    NSLog(@"OpenCV: all strategies failed — using full image");
    double m = 10.0;
    return { {(float)m, (float)m},
             {(float)(src.cols - m), (float)m},
             {(float)(src.cols - m), (float)(src.rows - m)},
             {(float)m, (float)(src.rows - m)} };
}

+ (BOOL)isAlreadyCroppedDocument:(cv::Mat &)src {
    cv::Mat gray;
    cv::cvtColor(src, gray, cv::COLOR_BGR2GRAY);

    int w = src.cols, h = src.rows;
    float aspectRatio = (float)std::max(w, h) / std::min(w, h);
    if (aspectRatio < 1.2f || aspectRatio > 1.5f) return NO;

    int thickness = std::max((int)(std::min(w, h) * 0.08), 15);

    auto medianOf = [](cv::Mat region) -> double {
        cv::Mat cont = region.clone();
        std::vector<uchar> data(cont.begin<uchar>(), cont.end<uchar>());
        std::sort(data.begin(), data.end());
        return data[data.size() / 2];
    };

    std::vector<double> medians = {
        medianOf(gray(cv::Rect(0, 0, w, thickness))),
        medianOf(gray(cv::Rect(0, h - thickness, w, thickness))),
        medianOf(gray(cv::Rect(0, 0, thickness, h))),
        medianOf(gray(cv::Rect(w - thickness, 0, thickness, h)))
    };

    int brightBorders = 0;
    for (double m : medians) if (m > 180) brightBorders++;

    NSLog(@"OpenCV isAlreadyCropped: brightBorders=%d aspect=%.2f", brightBorders, aspectRatio);
    return brightBorders >= 3;
}

// ── Strategy 1: Multi-scale Canny ───────────────────────────────────────────

+ (std::vector<cv::Point2f>)tryCannyMultiScale:(cv::Mat &)gray src:(cv::Mat &)src {
    double srcArea = src.cols * (double)src.rows;

    struct Candidate {
        std::vector<cv::Point2f> pts;
        double rectScore, aspectScore, area;
    };
    std::vector<Candidate> allCandidates;

    std::vector<double> blurSizes = {3, 5, 9};
    std::vector<std::pair<double,double>> thresholds = {{20,60},{40,120},{75,200}};

    for (double blurSize : blurSizes) {
        for (auto &[low, high] : thresholds) {
            cv::Mat blurred, edges;
            cv::GaussianBlur(gray, blurred, cv::Size(blurSize, blurSize), 0);
            cv::Canny(blurred, edges, low, high);

            cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5, 5));
            cv::dilate(edges, edges, kernel);

            std::vector<std::vector<cv::Point>> contours;
            cv::findContours(edges, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

            // Sort by area descending, take top 8
            std::sort(contours.begin(), contours.end(), [](auto &a, auto &b) {
                return cv::contourArea(a) > cv::contourArea(b);
            });
            if (contours.size() > 8) contours.resize(8);

            for (auto &contour : contours) {
                double area = cv::contourArea(contour) / srcArea;
                if (area < 0.02 || area > 0.95) continue;

                auto quad = [self approxToQuad:contour src:src];
                if (quad.size() != 4) continue;

                double rectScore = [self rectangularityScore:quad];
                if (rectScore > 80.0 || rectScore < 1.0) continue;

                // Compute dimensions
                double w = (cv::norm(quad[1] - quad[0]) + cv::norm(quad[2] - quad[3])) / 2.0;
                double h = (cv::norm(quad[3] - quad[0]) + cv::norm(quad[2] - quad[1])) / 2.0;
                if (w / src.cols < 0.20 || h / src.rows < 0.20) continue;

                if ([self isSkinDominated:src quad:quad]) continue;

                double aspect = std::max(w, h) / std::min(w, h);
                std::vector<double> knownRatios = {1.586, 1.95, 1.414, 1.5, 1.333, 2.0};
                double aspectScore = 999;
                for (double r : knownRatios) aspectScore = std::min(aspectScore, std::abs(aspect - r));

                auto expanded = [self expandQuad:quad src:src expandPx:30.0];
                allCandidates.push_back({expanded, rectScore, aspectScore, area});
            }
        }
    }

    if (allCandidates.empty()) return {};

    // Filter good aspect matches
    std::vector<Candidate> pool;
    for (auto &c : allCandidates) if (c.aspectScore < 0.3) pool.push_back(c);
    if (pool.empty()) pool = allCandidates;

    // Pick lowest combined score
    auto best = std::min_element(pool.begin(), pool.end(), [](auto &a, auto &b) {
        return (a.rectScore * 0.5 + a.aspectScore * 100.0) < (b.rectScore * 0.5 + b.aspectScore * 100.0);
    });

    NSLog(@"OpenCV Strategy1: rectScore=%.1f aspectScore=%.3f area=%.3f",
          best->rectScore, best->aspectScore, best->area);
    return best->pts;
}

// ── Strategy 2: Adaptive threshold ──────────────────────────────────────────

+ (std::vector<cv::Point2f>)tryAdaptiveThreshold:(cv::Mat &)gray src:(cv::Mat &)src {
    double srcArea = src.cols * (double)src.rows;
    cv::Mat thresh, edges;

    cv::adaptiveThreshold(gray, thresh, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 21, 5);
    cv::bitwise_not(thresh, thresh);

    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(7, 7));
    cv::morphologyEx(thresh, thresh, cv::MORPH_CLOSE, kernel);
    cv::Canny(thresh, edges, 10, 50);

    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(edges, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
    if (contours.empty()) return {};

    auto largest = std::max_element(contours.begin(), contours.end(),
        [](auto &a, auto &b){ return cv::contourArea(a) < cv::contourArea(b); });
    if (cv::contourArea(*largest) / srcArea < 0.02) return {};

    auto quad = [self approxToQuad:*largest src:src];
    if (quad.size() != 4) return {};

    double score = [self rectangularityScore:quad];
    NSLog(@"OpenCV Strategy2 score=%.1f", score);
    if (score >= 88.0) return {};
    if ([self isSkinDominated:src quad:quad]) return {};

    return [self expandQuad:quad src:src expandPx:30.0];
}

// ── Strategy 3: Morphological ────────────────────────────────────────────────

+ (std::vector<cv::Point2f>)tryMorphologicalApproach:(cv::Mat &)gray src:(cv::Mat &)src {
    double srcArea = src.cols * (double)src.rows;
    cv::Mat closed, edges;

    cv::Mat closeKernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(15, 15));
    cv::morphologyEx(gray, closed, cv::MORPH_CLOSE, closeKernel);
    cv::Canny(closed, edges, 10, 50);

    cv::Mat dilKernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(7, 7));
    cv::dilate(edges, edges, dilKernel);

    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(edges, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
    if (contours.empty()) return {};

    std::sort(contours.begin(), contours.end(), [](auto &a, auto &b){
        return cv::contourArea(a) > cv::contourArea(b);
    });
    if (contours.size() > 5) contours.resize(5);

    std::vector<double> knownRatios = {1.586, 1.95, 1.414, 1.5, 1.333, 2.0};

    struct Candidate { std::vector<cv::Point2f> pts; double rectScore, aspectScore; };
    std::vector<Candidate> candidates;

    for (auto &contour : contours) {
        if (cv::contourArea(contour) / srcArea < 0.02) continue;
        auto quad = [self approxToQuad:contour src:src];
        if (quad.size() != 4) continue;

        double score = [self rectangularityScore:quad];
        if (score >= 88.0) continue;
        if ([self isSkinDominated:src quad:quad]) continue;

        double w = (cv::norm(quad[1]-quad[0]) + cv::norm(quad[2]-quad[3])) / 2.0;
        double h = (cv::norm(quad[3]-quad[0]) + cv::norm(quad[2]-quad[1])) / 2.0;
        double aspect = std::max(w, h) / std::min(w, h);
        double aspectScore = 999;
        for (double r : knownRatios) aspectScore = std::min(aspectScore, std::abs(aspect - r));

        candidates.push_back({[self expandQuad:quad src:src expandPx:30.0], score, aspectScore});
    }

    if (candidates.empty()) return {};

    auto best = std::min_element(candidates.begin(), candidates.end(), [](auto &a, auto &b){
        return a.aspectScore < b.aspectScore;
    });

    NSLog(@"OpenCV Strategy3 score=%.1f aspectScore=%.3f", best->rectScore, best->aspectScore);
    return best->aspectScore < 0.5 ? best->pts : std::vector<cv::Point2f>{};
}

// ── Quad helpers ─────────────────────────────────────────────────────────────

+ (std::vector<cv::Point2f>)approxToQuad:(std::vector<cv::Point> &)contour src:(cv::Mat &)src {
    std::vector<int> hullIdx;
    cv::convexHull(contour, hullIdx);

    std::vector<cv::Point2f> hullPts;
    for (int i : hullIdx) hullPts.push_back(cv::Point2f(contour[i].x, contour[i].y));

    double peri = cv::arcLength(hullPts, true);

    std::vector<cv::Point2f> bestQuad;
    double bestScore = DBL_MAX;

    for (double eps : {0.02, 0.03, 0.04, 0.05, 0.06, 0.08, 0.10}) {
        std::vector<cv::Point2f> approx;
        cv::approxPolyDP(hullPts, approx, eps * peri, true);
        if (approx.size() == 4) {
            std::vector<cv::Point2f> ordered = [self orderPoints:approx];
            double score = [self rectangularityScore:ordered];
            if (score < bestScore) { bestScore = score; bestQuad = ordered; }
        }
    }

    if (!bestQuad.empty()) return bestQuad;

    // Bounding rect fallback — only if document-like aspect
    cv::Rect rect = cv::boundingRect(contour);
    float aspect = (float)std::max(rect.width, rect.height) / std::min(rect.width, rect.height);
    std::vector<double> knownRatios = {1.586, 1.95, 1.414, 1.5, 1.333, 2.0};
    double aspectScore = 999;
    for (double r : knownRatios) aspectScore = std::min(aspectScore, std::abs(aspect - r));
    if (aspectScore > 0.5) return {};

    return [self orderPoints:{
        {(float)rect.x, (float)rect.y},
        {(float)(rect.x + rect.width), (float)rect.y},
        {(float)(rect.x + rect.width), (float)(rect.y + rect.height)},
        {(float)rect.x, (float)(rect.y + rect.height)}
    }];
}

+ (std::vector<cv::Point2f>)orderPoints:(std::vector<cv::Point2f>)pts {
    std::sort(pts.begin(), pts.end(), [](auto &a, auto &b){ return (a.x+a.y) < (b.x+b.y); });
    cv::Point2f tl = pts[0], br = pts[3];
    cv::Point2f tr = pts[1].y < pts[2].y ? pts[1] : pts[2];
    cv::Point2f bl = pts[1].y < pts[2].y ? pts[2] : pts[1];
    return {tl, tr, br, bl};
}

+ (double)rectangularityScore:(std::vector<cv::Point2f> &)pts {
    double total = 0;
    for (int i = 0; i < 4; i++) {
        cv::Point2f a = pts[(i+3)%4], b = pts[i], c = pts[(i+1)%4];
        cv::Point2f v1 = a - b, v2 = c - b;
        double dot = v1.x*v2.x + v1.y*v2.y;
        double mag = cv::norm(v1) * cv::norm(v2);
        if (mag == 0) return DBL_MAX;
        double angle = std::acos(std::max(-1.0, std::min(1.0, dot/mag))) * 180.0 / M_PI;
        total += std::abs(angle - 90.0);
    }
    return total;
}

+ (std::vector<cv::Point2f>)expandQuad:(std::vector<cv::Point2f>)pts src:(cv::Mat &)src expandPx:(double)expandPx {
    double cx = 0, cy = 0;
    for (auto &p : pts) { cx += p.x; cy += p.y; }
    cx /= 4; cy /= 4;

    std::vector<cv::Point2f> result;
    for (auto &pt : pts) {
        double dx = pt.x - cx, dy = pt.y - cy;
        double length = std::sqrt(dx*dx + dy*dy);
        if (length == 0) { result.push_back(pt); continue; }

        bool isLeft = pt.x < cx;
        double expand = isLeft ? expandPx * 2.5 : expandPx;
        double scale = (length + expand) / length;

        result.push_back({
            (float)std::max(0.0, std::min((double)src.cols-1, cx + dx*scale)),
            (float)std::max(0.0, std::min((double)src.rows-1, cy + dy*scale))
        });
    }
    return result;
}

+ (BOOL)isSkinDominated:(cv::Mat &)src quad:(std::vector<cv::Point2f> &)quad {
    auto lerp = [](cv::Point2f a, cv::Point2f b, double t) {
        return cv::Point2f(a.x + (b.x-a.x)*t, a.y + (b.y-a.y)*t);
    };
    double s = 0.20;
    cv::Point2f tl=quad[0], tr=quad[1], br=quad[2], bl=quad[3];
    std::vector<cv::Point> inner = {
        lerp(lerp(tl,tr,s), lerp(bl,br,s), s),
        lerp(lerp(tr,tl,s), lerp(br,bl,s), s),
        lerp(lerp(br,bl,s), lerp(tr,tl,s), s),
        lerp(lerp(bl,br,s), lerp(tl,tr,s), s)
    };

    cv::Mat mask = cv::Mat::zeros(src.rows, src.cols, CV_8UC1);
    std::vector<std::vector<cv::Point>> pts = {inner};
    cv::fillPoly(mask, pts, cv::Scalar(255));

    cv::Mat hsv, skinMask1, skinMask2, skinMask, quadOnly;
    cv::cvtColor(src, hsv, cv::COLOR_BGR2HSV);
    cv::inRange(hsv, cv::Scalar(0,50,120), cv::Scalar(15,150,255), skinMask1);
    cv::inRange(hsv, cv::Scalar(0,80,80),  cv::Scalar(20,200,200), skinMask2);
    cv::bitwise_or(skinMask1, skinMask2, skinMask);
    cv::bitwise_and(skinMask, mask, quadOnly);

    double skinRatio = (double)cv::countNonZero(quadOnly) / cv::countNonZero(mask);
    NSLog(@"OpenCV skinRatio=%.2f", skinRatio);
    return skinRatio > 0.75;
}

// ── Warp & enhance ───────────────────────────────────────────────────────────

+ (cv::Mat)warpPerspective:(cv::Mat &)src corners:(std::vector<cv::Point2f>)corners {
    cv::Point2f tl=corners[0], tr=corners[1], br=corners[2], bl=corners[3];

    double wA = cv::norm(br-bl), wB = cv::norm(tr-tl);
    int maxW = (int)std::max(wA, wB);
    double hA = cv::norm(tr-br), hB = cv::norm(tl-bl);
    int maxH = (int)std::max(hA, hB);

    std::vector<cv::Point2f> dst = {
        {0,0}, {(float)(maxW-1),0},
        {(float)(maxW-1),(float)(maxH-1)}, {0,(float)(maxH-1)}
    };

    cv::Mat M = cv::getPerspectiveTransform(corners, dst);
    cv::Mat warped;
    cv::warpPerspective(src, warped, M, cv::Size(maxW, maxH));

    // Auto-rotate to landscape
    if (warped.rows > warped.cols) {
        cv::Mat rotated;
        cv::rotate(warped, rotated, cv::ROTATE_90_CLOCKWISE);
        warped = rotated;
    }

    // Correct to ID card aspect ratio if close
    double currentRatio = (double)warped.cols / warped.rows;
    if (std::abs(currentRatio - 1.586) < 0.4) {
        int targetH = (int)(warped.cols / 1.586);
        cv::Mat corrected;
        cv::resize(warped, corrected, cv::Size(warped.cols, targetH));
        NSLog(@"OpenCV aspect corrected: %.3f → 1.586", currentRatio);
        return corrected;
    }
    return warped;
}

+ (cv::Mat)enhanceDocument:(cv::Mat &)src {
    double aspect = (double)std::max(src.cols, src.rows) / std::min(src.cols, src.rows);
    if (aspect >= 1.3 && aspect <= 2.2) {
        // Card — sharpen, preserve color
        cv::Mat blurred, result;
        cv::GaussianBlur(src, blurred, cv::Size(0,0), 3);
        cv::addWeighted(src, 1.5, blurred, -0.5, 0, result);
        return result;
    } else {
        // Document — grayscale + adaptive threshold
        cv::Mat gray, enhanced;
        cv::cvtColor(src, gray, cv::COLOR_BGR2GRAY);
        cv::adaptiveThreshold(gray, enhanced, 255,
            cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 11, 10);
        return enhanced;
    }
}

@end
