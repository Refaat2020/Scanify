import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scanify/features/processing/data/processors/face_processor_impl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../home/data/datasources/history_local_datasource_impl.dart';
import '../../../home/data/models/history_item_model.dart';
import '../../../home/data/repositories/history_repository_impl.dart';
import '../../../home/domain/usecases/save_history_item.dart';
import '../../data/datasources/image_processing_datasource_impl.dart';
import '../../data/processors/document_processor_impl.dart';
import '../../data/repositories/image_processing_repository_impl.dart';
import '../../domain/usecases/detect_content_type.dart';
import '../../domain/usecases/process_document_image.dart';
import '../../domain/usecases/process_face_image.dart';
import '../controllers/processing_controller.dart';

class ProcessingBinding extends Bindings {
  @override
  void dependencies() {
    // ImagePicker — singleton is fine
    Get.lazyPut(() => ImagePicker());
    Get.lazyPut(() => FaceProcessorImpl());
    Get.lazyPut(() => DocumentProcessorImpl());

    // Image processing datasource + repository
    Get.lazyPut(
      () => ImageProcessingDataSourceImpl(
        Get.find<FaceProcessorImpl>(),
        Get.find<DocumentProcessorImpl>(),
      ),
    );
    Get.lazyPut<ImageProcessingRepositoryImpl>(
      () => ImageProcessingRepositoryImpl(
        dataSource: Get.find<ImageProcessingDataSourceImpl>(),
      ),
    );

    // History datasource + repository (needed to save result)
    // Re-use existing instances if already registered (home feature may have them)
    if (!Get.isRegistered<HistoryLocalDataSourceImpl>()) {
      Get.lazyPut<HistoryLocalDataSourceImpl>(
        () => HistoryLocalDataSourceImpl(
          Hive.box<HistoryItemModel>(AppConstants.historyBoxName),
        ),
      );
    }
    if (!Get.isRegistered<HistoryRepositoryImpl>()) {
      Get.lazyPut<HistoryRepositoryImpl>(
        () => HistoryRepositoryImpl(
          localDataSource: Get.find<HistoryLocalDataSourceImpl>(),
        ),
      );
    }

    // Use cases
    Get.lazyPut(
      () => DetectContentType(Get.find<ImageProcessingRepositoryImpl>()),
    );
    Get.lazyPut(
      () => ProcessFaceImage(Get.find<ImageProcessingRepositoryImpl>()),
    );
    Get.lazyPut(
      () => ProcessDocumentImage(Get.find<ImageProcessingRepositoryImpl>()),
    );
    Get.lazyPut(() => SaveHistoryItem(Get.find<HistoryRepositoryImpl>()));

    // Controller
    Get.lazyPut(
      () => ProcessingController(
        picker: Get.find<ImagePicker>(),
        detectContentType: Get.find<DetectContentType>(),
        processFaceImage: Get.find<ProcessFaceImage>(),
        processDocumentImage: Get.find<ProcessDocumentImage>(),
        saveHistoryItem: Get.find<SaveHistoryItem>(),
      ),
    );
  }
}
