import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/history_local_datasource_impl.dart';
import '../../data/models/history_item_model.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/usecases/delete_history_item.dart';
import '../../domain/usecases/get_history.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // DataSource
    Get.lazyPut<HistoryLocalDataSourceImpl>(
      () => HistoryLocalDataSourceImpl(
        Hive.box<HistoryItemModel>(AppConstants.historyBoxName),
      ),
    );

    // Repository
    Get.lazyPut<HistoryRepositoryImpl>(
      () => HistoryRepositoryImpl(
        localDataSource: Get.find<HistoryLocalDataSourceImpl>(),
      ),
    );

    // Use cases
    Get.lazyPut(() => GetHistory(Get.find<HistoryRepositoryImpl>()));
    Get.lazyPut(() => DeleteHistoryItem(Get.find<HistoryRepositoryImpl>()));

    // Controller
    Get.lazyPut(
      () => HomeController(
        getHistory: Get.find<GetHistory>(),
        deleteHistoryItem: Get.find<DeleteHistoryItem>(),
      ),
    );
  }
}
