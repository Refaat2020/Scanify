import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scanify/features/processing/data/processors/document_processor_impl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../home/data/datasources/history_local_datasource_impl.dart';
import '../../../home/data/models/history_item_model.dart';
import '../../../home/data/repositories/history_repository_impl.dart';
import '../../../home/domain/usecases/save_history_item.dart';
import '../../../processing/data/datasources/image_processing_datasource_impl.dart';
import '../../../processing/data/processors/face_processor_impl.dart';
import '../../../processing/data/repositories/image_processing_repository_impl.dart';
import '../../../processing/domain/usecases/detect_content_type.dart';
import '../../../processing/domain/usecases/process_document_image.dart';
import '../../../processing/domain/usecases/process_face_image.dart';
import '../../domain/usecases/process_batch_images.dart';
import '../controllers/batch_controller.dart';

class BatchBinding extends Bindings {
  @override
  void dependencies() {
    // ImagePicker
    if (!Get.isRegistered<ImagePicker>()) {
      Get.lazyPut(() => ImagePicker());
    }
    if (!Get.isRegistered<FaceProcessorImpl>()) {
      Get.lazyPut(() => FaceProcessorImpl());
    }
    if (!Get.isRegistered<DocumentProcessorImpl>()) {
      Get.lazyPut(() => DocumentProcessorImpl());
    }
    // Image processing datasource + repository
    if (!Get.isRegistered<ImageProcessingDataSourceImpl>()) {
      Get.lazyPut(
        () => ImageProcessingDataSourceImpl(
          Get.find<FaceProcessorImpl>(),
          Get.find<DocumentProcessorImpl>(),
        ),
      );
    }
    if (!Get.isRegistered<ImageProcessingRepositoryImpl>()) {
      Get.lazyPut<ImageProcessingRepositoryImpl>(
        () => ImageProcessingRepositoryImpl(
          dataSource: Get.find<ImageProcessingDataSourceImpl>(),
        ),
      );
    }

    // History datasource + repository
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

    // Batch use case
    Get.lazyPut(
      () => ProcessBatchImage(
        detectContentType: Get.find<DetectContentType>(),
        processFaceImage: Get.find<ProcessFaceImage>(),
        processDocumentImage: Get.find<ProcessDocumentImage>(),
      ),
    );

    // Batch controller
    Get.lazyPut(
      () => BatchController(
        picker: Get.find<ImagePicker>(),
        processBatchImage: Get.find<ProcessBatchImage>(),
        saveHistoryItem: Get.find<SaveHistoryItem>(),
      ),
    );
  }
}
