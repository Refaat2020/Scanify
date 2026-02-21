import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../home/data/datasources/history_local_datasource_impl.dart';
import '../../../home/data/models/history_item_model.dart';
import '../../../home/data/repositories/history_repository_impl.dart';
import '../../../home/domain/usecases/delete_history_item.dart';
import '../controllers/history_detail_controller.dart';

class HistoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Re-use already-registered instances if available
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

    Get.lazyPut(() => DeleteHistoryItem(Get.find<HistoryRepositoryImpl>()));

    Get.lazyPut(
      () => HistoryDetailController(
        deleteHistoryItem: Get.find<DeleteHistoryItem>(),
      ),
    );
  }
}
