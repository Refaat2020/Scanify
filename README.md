# Scanify

A production-ready Flutter image processing app built with **Feature-first Clean Architecture** and **GetX** state management. Features **native OpenCV document scanning** on Android, ML Kit face detection, OCR text extraction, and batch processing.

---

## 📋 Features

### Core Features
- **Home Screen** — History list with face/document type badges, swipe-to-delete, pull-to-refresh
- **Face Processing** — ML Kit face detection → crop → B&W filter → composite image
- **Document Scanning** — **Native OpenCV on Android** with multi-strategy edge detection, perspective correction, and enhancement
- **Result Screen** — Interactive before/after slider comparison for faces, PDF viewer for documents
- **History Detail** — Full-screen zoomable image viewer, metadata display, share/delete/OCR actions

### Bonus Features
- **OCR Text Extraction** — ML Kit text recognition with search highlighting, copy, and share
- **Batch Processing** — Multi-image selection with queue-based processing and live progress tracking
- **Unknown Content Handling** — Dialog prompt when neither faces nor text detected, user can choose pipeline manually
- **Performance Optimized** — All heavy image processing runs in background isolates via `compute()`

---

## 🏗️ Architecture

```
lib/
├── core/                          # Shared infrastructure
│   ├── constants/                 # App constants (storage dirs, processing steps)
│   ├── enums/                     # ProcessingType enum
│   ├── error/                     # Failures (domain) + Exceptions (data)
│   ├── extensions/                # BuildContext, String extensions
│   ├── routes/                    # GetX route definitions + bindings
│   ├── theme/                     # AppTheme with Codeway brand colors
│   ├── usecases/                  # Base UseCase<Type, Params> class
│   ├── utils/                     # DateFormatter, FileHelper, FileSizeFormatter
│   └── widgets/                   # AppButton, AppCard, ErrorView, GradientText, etc.
│
├── features/                      # Feature modules (feature-first structure)
│   ├── home/
│   │   ├── domain/               # Pure entities, abstract repositories, use cases
│   │   ├── data/                 # Hive models, datasource impls, repository impls
│   │   └── presentation/         # GetX controllers, bindings, pages, widgets
│   │
│   ├── processing/
│   │   ├── domain/
│   │   ├── data/
│   │   │   ├── datasources/     # ML Kit integration
│   │   │   ├── processors/      # FaceProcessor, DocumentProcessor (calls native)
│   │   │   └── models/          # Output models, FaceRect
│   │   └── presentation/
│   │
│   ├── result/
│   ├── history_detail/
│   ├── ocr/
│   └── batch/
│
└── main.dart
```

### Android Native (Kotlin + OpenCV)
```
android/app/src/main/kotlin/com/code/way/task/code_way_task/
└── MainActivity.kt                # Native OpenCV document scanner
```

### Layer Responsibilities

**Domain Layer** (pure Dart, zero framework dependencies)
- Entities: Plain immutable classes with Equatable
- Repositories: Abstract contracts (interfaces)
- Use Cases: Single-responsibility business logic

**Data Layer**
- Models: Hive annotated classes with `fromEntity`/`toEntity` mappers
- DataSources: Abstract contracts + implementations (Hive, ML Kit, image processing)
- Processors: Algorithm implementations (face compositing, document scanning)
- Repositories: Catch exceptions → return `Either<Failure, T>`

**Presentation Layer**
- Controllers: GetxController with reactive state (`Rx`, `.obs`)
- Bindings: Lazy DI wiring with `Get.lazyPut`
- Pages: `GetView<Controller>` with `Obx` rebuilds
- Widgets: Reusable UI components

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter 3.x |
| State Management | GetX 4.6.6 |
| Local Storage | Hive 2.2.3 |
| ML Kit | google_mlkit_face_detection, google_mlkit_text_recognition |
| Image Processing | image 4.1.7 (with `compute()` for isolates) |
| **Document Scanning** | **Native OpenCV 4.x (Android)** |
| PDF Generation | pdf 3.10.8 |
| Architecture | Clean Architecture + Either (dartz) |
| Routing | GetX named routes with bindings |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥3.0.0
- Dart ≥3.0.0
- Android Studio / Xcode for platform builds
- **Android NDK** (for OpenCV native code)

### Installation

1. **Clone or download the project**
   ```bash
   cd Scanify
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📱 Platform Configuration

### Android
- **Min SDK**: 21
- **Native OpenCV**: 4.x (bundled in APK)
- **Permissions**: Camera, Storage (READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE)
- **FileProvider** configured for sharing processed files
- **Method Channel**: `com.code/document_processor` for native OpenCV calls

All permissions are declared in `android/app/src/main/AndroidManifest.xml`.

### iOS
- **Min version**: 12.0
- **Permissions**: Camera, Photo Library (read + write), Microphone (required by camera framework)
- **Document Processing**: Falls back to Dart implementation (no OpenCV)

All permissions are declared in `ios/Runner/Info.plist` with usage descriptions.

---

## 🎨 Key Design Decisions

### 1. Feature-first over Layer-first
Each feature (`home`, `processing`, `result`) is self-contained with its own domain/data/presentation layers. Easier to navigate, test, and scale.

### 2. GetX Reactive State
- Controllers use `.obs` for reactive primitives
- UI rebuilds via `Obx(() => ...)` wrappers
- Bindings handle lazy DI — instances created only when route is accessed

### 3. Either Pattern (dartz)
All repository methods return `Either<Failure, T>` for explicit error handling:
```dart
final result = await repository.getHistory();
result.fold(
  (failure) => showError(failure.message),
  (items) => displayList(items),
);
```

### 4. Processor Abstraction Pattern
Heavy algorithms are extracted into dedicated processor classes:
- **FaceProcessor**: Face compositing with grayscale filter
- **DocumentProcessor**: Platform-aware (native OpenCV on Android, Dart fallback on iOS)

Benefits:
- ✅ Testable in isolation
- ✅ Swappable implementations
- ✅ Clean separation of concerns
- ✅ Enables A/B testing different algorithms

### 5. Native OpenCV Document Scanner (Android Only)

**Why Native?**
- 40-60x faster than pure Dart implementations
- Production-grade edge detection with 3 fallback strategies
- Handles complex backgrounds, uneven lighting, and hand occlusion
- Automatic aspect ratio correction for standard ID cards

**Architecture:**
```dart
// Dart side
DocumentProcessor (abstract)
    ↓
DocumentProcessorImpl
    ↓ (Platform.isAndroid)
MethodChannel('com.code/document_processor')
    ↓
// Kotlin side
MainActivity.kt → OpenCV native processing
```

**Processing Pipeline:**
1. **Pre-check**: Detects if image is already a clean scan (skips detection)
2. **Strategy 1**: Multi-scale Canny edge detection (9 parameter combinations)
3. **Strategy 2**: Adaptive threshold for uneven lighting
4. **Strategy 3**: Morphological closing as final fallback
5. **Skin rejection**: Filters out hand-held selfie photos
6. **Quad expansion**: Compensates for hand/finger occlusion (2.5x on left side)
7. **Perspective transform**: Warps quadrilateral to rectangle
8. **Auto-rotation**: Makes longer side the width
9. **Aspect correction**: Resizes to exact ID card ratio (1.586:1) when close
10. **Enhancement**: Card sharpening OR document binarization based on aspect ratio

**Fallback Behavior:**
- iOS: Uses pure Dart implementation (grayscale + contrast + adaptive crop)
- Android: If native fails, falls back to Dart implementation
- If no quad detected: Returns full frame with margin

### 6. Compute for Heavy Work
All CPU-intensive operations (`img.grayscale`, `img.compositeImage`, `pdf.save()`) run in background isolates via `compute()` to keep UI smooth.

### 7. ML Kit Already Optimized
`FaceDetector.processImage()` and `TextRecognizer.processImage()` run on native threads — no `compute()` needed.

---

## 📦 Project Structure

**Total files**: 92+ Dart files + 1 Kotlin native implementation across 6 features

**Core Widgets** (24 files)
- AppButton (primary, secondary, danger variants)
- AppCard, ErrorView, LoadingOverlay
- GradientText, GradientDivider, ProcessingTypeBadge

**Features**
- **Home** (17 files) — History list, Hive persistence, delete with optimistic rollback
- **Processing** (18 files) — Image capture, ML Kit detection, native OpenCV integration, face/document pipelines
- **Result** (7 files) — Before/after slider, side-by-side compare, PDF viewer
- **History Detail** (6 files) — Full-screen viewer, metadata card, share/delete/OCR actions
- **OCR** (12 files) — Text extraction with search highlighting, copy, share
- **Batch** (7 files) — Multi-image picker, queue processing, live progress tracker

**Android Native** (1 file)
- **MainActivity.kt** (700+ lines) — Production-grade OpenCV document scanner with multi-strategy detection

---

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Generate Coverage
```bash
flutter test --coverage
```

**Testing Strategy**
- **Unit tests**: Use cases, entities, utilities (5 test files included)
- **Widget tests**: Individual widgets, controllers (1 test file included)
- **Integration tests**: Full feature flows (TBD)

Test files use **mocktail** for clean, type-safe mocking without code generation.

---

## 📝 Usage Examples

### Single Image Processing
1. Tap **+** FAB on home screen
2. Choose **Camera** or **Gallery**
3. App auto-detects faces or document text
4. **Android**: Native OpenCV detects document edges and warps automatically
5. If neither detected → dialog asks which pipeline to use
6. View result with before/after comparison
7. Tap **Done** to save to history

### Batch Processing
1. Tap **+** FAB → **Batch Processing**
2. Select 5–10 images from gallery
3. Tap **Start Batch**
4. Watch live progress as each image processes
5. Tap **Done** when complete — all saved to history

### OCR Text Extraction
1. Open any history item
2. Tap **Extract Text (OCR)**
3. Search within extracted text
4. Copy all or share via system share sheet

---

## 🎯 Performance Notes

### Document Processing Speed
- **Native OpenCV (Android)**: 1-2 seconds (includes detection + warp + enhance)
- **Dart Fallback (iOS)**: 2-3 seconds (grayscale + crop + sharpen)
- **Speedup**: 40-60x faster than early opencv_dart attempts (which took 2 minutes)

### Memory Management
- **Image decoding** happens twice in face pipeline (once for dimensions, once inside `compute()`) — negligible cost vs blocking the UI
- **Sequential batch processing** is safer for ML Kit memory management. Parallel processing can be enabled by replacing the `for` loop with `Future.wait()` in `BatchController._processItem()`
- **Hive** is fast enough for this use case. For 1000+ items, consider pagination or switching to SQLite via the datasource abstraction

### Native OpenCV Performance
- **Multi-scale detection**: Tests 9 parameter combinations in parallel (3 blur sizes × 3 Canny thresholds)
- **Skin detection**: Uses HSV color space filtering (H: 0-20, S: 50-200, V: 80-255)
- **Quad scoring**: Combines rectangularity (angle deviation from 90°) + aspect ratio matching
- **Processing time**: ~200ms detection + ~800ms warping = **1 second total**

---

## 🔧 Troubleshooting

**Issue**: Native OpenCV not working on Android  
**Fix**: Ensure Android NDK is installed and OpenCV is initialized in `MainActivity`:
```kotlin
OpenCVLoader.initLocal()
```

**Issue**: Build fails with Hive errors  
**Fix**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

**Issue**: Camera/gallery not working on Android  
**Fix**: Check `AndroidManifest.xml` permissions and `FileProvider` config

**Issue**: ML Kit fails on first run  
**Fix**: ML Kit downloads models on first use — requires internet connection

**Issue**: Document detection misses the card  
**Fix**: The native code has 3 fallback strategies. If all fail, it returns the full frame. Ensure:
- Good lighting (avoid shadows)
- Card fills at least 20% of frame
- Card is on a contrasting background (not matching card color)

---

## 📄 License

This project is a case study implementation. See case study requirements document for usage terms.

---

## 👤 Author

Built as a Flutter Clean Architecture case study demonstrating:
- Feature-first project structure
- GetX state management with reactive bindings
- Native platform integration (Kotlin + OpenCV)
- ML Kit integration (face detection, text recognition)
- Image processing with isolates for performance
- Hive local persistence
- PDF generation and file sharing
- Method Channel communication between Flutter ↔ Native code

**Architecture**: Clean Architecture + Either pattern + Processor abstraction  
**State Management**: GetX  
**ML**: Google ML Kit  
**Document Scanning**: Native OpenCV 4.x (Android) with Dart fallback (iOS)  
**Storage**: Hive + file system