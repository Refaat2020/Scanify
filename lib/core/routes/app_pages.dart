import 'package:get/get.dart';

import '../../features/batch/presentation/bindings/batch_binding.dart';
import '../../features/batch/presentation/pages/batch_page.dart';
import '../../features/history_detail/presentation/bindings/history_detail_binding.dart';
import '../../features/history_detail/presentation/pages/history_detail_page.dart';
import '../../features/home/presentation/bindings/home_binding.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/ocr/presentation/bindings/ocr_binding.dart';
import '../../features/ocr/presentation/pages/ocr_page.dart';
import '../../features/processing/presentation/bindings/processing_binding.dart';
import '../../features/processing/presentation/pages/processing_page.dart';
import '../../features/result/presentation/bindings/result_binding.dart';
import '../../features/result/presentation/pages/result_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.processing,
      page: () => const ProcessingPage(),
      binding: ProcessingBinding(),
    ),
    GetPage(
      name: AppRoutes.result,
      page: () => const ResultPage(),
      binding: ResultBinding(),
    ),
    GetPage(
      name: AppRoutes.historyDetail,
      page: () => const HistoryDetailPage(),
      binding: HistoryDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.ocr,
      page: () => const OcrPage(),
      binding: OcrBinding(),
    ),

    GetPage(
      name: AppRoutes.batch,
      page: () => const BatchPage(),
      binding: BatchBinding(),
    ),
  ];
}
