import 'package:get/get.dart';

import '../../data/datasources/ocr_datasource_impl.dart';
import '../../data/repositories/ocr_repository_impl.dart';
import '../../domain/usecases/extract_text.dart';
import '../controllers/ocr_controller.dart';

class OcrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OcrDataSourceImpl());
    Get.lazyPut<OcrRepositoryImpl>(
      () => OcrRepositoryImpl(dataSource: Get.find<OcrDataSourceImpl>()),
    );
    Get.lazyPut(() => ExtractText(Get.find<OcrRepositoryImpl>()));
    Get.lazyPut(() => OcrController(extractText: Get.find<ExtractText>()));
  }
}
