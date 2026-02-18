import '../models/history_item_model.dart';

abstract class HistoryLocalDataSource {
  /// Retrieves all stored history items.
  Future<List<HistoryItemModel>> getAllHistoryItems();

  /// Persists a new history item.
  Future<void> saveHistoryItem(HistoryItemModel model);

  /// Removes a history item by [id].
  Future<void> deleteHistoryItem(String id);

  /// Removes all history items.
  Future<void> clearHistory();
}
