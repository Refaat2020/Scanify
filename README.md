# Scanify

A production-ready Flutter image processing app built with **Feature-first Clean Architecture** and **GetX** state management. Supports face detection with ML Kit, document scanning to PDF, OCR text extraction, and batch processing.

---

## 📋 Features

### Core Features
- **Home Screen** — History list with face/document type badges, swipe-to-delete, pull-to-refresh
- **Face Processing** — ML Kit face detection → crop → B&W filter → composite image
- **Document Scanning** — Text detection → edge detection → perspective transform → contrast enhancement → PDF export
- **Result Screen** — Interactive before/after slider comparison for faces, PDF viewer for documents
- **History Detail** — Full-screen zoomable image viewer, metadata display, share/delete actions

### Bonus Features
- **OCR Text Extraction** — ML Kit text recognition with search, copy, and share
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
│   │   ├── data/                 # ML Kit + image package + pdf package
│   │   └── presentation/
│   │
│   ├── result/
│   ├── history_detail/
│   ├── ocr/
│   └── batch/
│
└── main.dart
```

### Layer Responsibilities

**Domain Layer** (pure Dart, zero framework dependencies)
- Entities: Plain immutable classes with Equatable
- Repositories: Abstract contracts (interfaces)
- Use Cases: Single-responsibility business logic

**Data Layer**
- Models: Hive annotated classes with `fromEntity`/`toEntity` mappers
- DataSources: Abstract contracts + implementations (Hive, ML Kit, image processing)
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
| State Management | GetX 4.7.3 |
| Local Storage | hive_ce 2.19.3|
| ML Kit | google_mlkit_face_detection, google_mlkit_text_recognition |
| Image Processing | image 4.5.4 (with `compute()` for isolates) |
| PDF Generation | pdf 3.11.3 |
| Architecture | Clean Architecture + Either (dartz) |
| Routing | GetX named routes with bindings |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥3.0.0
- Dart ≥3.0.0
- Android Studio / Xcode for platform builds

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
- **Permissions**: Camera, Storage (READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE)
- **FileProvider** configured for sharing processed files

All permissions are declared in `android/app/src/main/AndroidManifest.xml`.

### iOS
- **Min version**: 12.0
- **Permissions**: Camera, Photo Library (read + write), Microphone (required by camera framework)

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

### 4. Datasource Abstraction
Abstract datasources enable swapping implementations (e.g., Hive → SQLite) by changing one file. The repository layer remains unchanged.

### 5. Compute for Heavy Work
All CPU-intensive operations (`img.grayscale`, `img.compositeImage`, `pdf.save()`) run in background isolates via `compute()` to keep UI smooth.

### 6. ML Kit Already Optimized
`FaceDetector.processImage()` and `TextRecognizer.processImage()` run on native threads — no `compute()` needed.

---

## 📦 Project Structure

**Total files**: 85+ Dart files across 6 features

**Core Widgets** (24 files)
- AppButton (primary, secondary, danger variants)
- AppCard, ErrorView, LoadingOverlay
- GradientText, GradientDivider, ProcessingTypeBadge

**Features**
- **Home** (17 files) — History list, Hive persistence, delete with optimistic rollback
- **Processing** (11 files) — Image capture, ML Kit detection, face/document pipelines
- **Result** (7 files) — Before/after slider, side-by-side compare, PDF viewer
- **History Detail** (6 files) — Full-screen viewer, metadata card, share/delete/OCR actions
- **OCR** (12 files) — Text extraction with search highlighting, copy, share
- **Batch** (7 files) — Multi-image picker, queue processing, live progress tracker

---


## 📝 Usage Examples

### Single Image Processing
1. Tap **+** FAB on home screen
2. Choose **Camera** or **Gallery**
3. App auto-detects faces or document text
4. If neither detected → dialog asks which pipeline to use
5. View result with before/after comparison
6. Tap **Done** to save to history

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

- **Image decoding** runs twice in face pipeline (once for dimensions, once inside `compute()`) — negligible cost vs blocking the UI
- **Sequential batch processing** is safer for ML Kit memory management. Parallel processing can be enabled by replacing the `for` loop with `Future.wait()` in `BatchController._processItem()`
- **Hive** is fast enough for this use case. For 1000+ items, consider pagination or switching to SQLite via the datasource abstraction

---

## 🔧 Troubleshooting

**Issue**: `decodeImageHeader` not found  
**Fix**: Already resolved — uses `img.decodeImage()` instead

**Issue**: Build fails with Hive errors  
**Fix**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

**Issue**: Camera/gallery not working on Android  
**Fix**: Check `AndroidManifest.xml` permissions and `FileProvider` config

**Issue**: ML Kit fails on first run  
**Fix**: ML Kit downloads models on first use — requires internet connection

---

## 📄 License

This project is a case study implementation. See case study requirements document for usage terms.

---

## 👤 Author

Built as a Flutter Clean Architecture case study demonstrating:
- Feature-first project structure
- GetX state management with reactive bindings
- ML Kit integration (face detection, text recognition)
- Image processing with isolates for performance
- Hive local persistence
- PDF generation and file sharing

**Architecture**: Clean Architecture + Either pattern  
**State Management**: GetX  
**ML**: Google ML Kit  
**Storage**: Hive + file system