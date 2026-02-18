import 'package:hive_ce/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/history_item_model.dart';
import 'history_local_datasource.dart';

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final Box<HistoryItemModel> _box;

  const HistoryLocalDataSourceImpl(this._box);

  @override
  Future<List<HistoryItemModel>> getAllHistoryItems() async {
    try {
      final items = _box.values.toList();
      // Sort by date descending — newest first
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    } catch (e) {
      throw const CacheException('Failed to read history from local storage');
    }
  }

  @override
  Future<void> saveHistoryItem(HistoryItemModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw const CacheException('Failed to save history item');
    }
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw const CacheException('Failed to delete history item');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await _box.clear();
    } catch (e) {
      throw const CacheException('Failed to clear history');
    }
  }
}
