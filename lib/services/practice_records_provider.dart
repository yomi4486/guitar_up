import 'package:flutter/foundation.dart';
import '../models/practice_record.dart';
import '../services/database_service.dart';

class PracticeRecordsProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<PracticeRecord> _records = [];
  bool _isLoading = false;

  List<PracticeRecord> get records => _records;
  bool get isLoading => _isLoading;

  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      _records = await _databaseService.getAllRecords();
    } catch (e) {
      debugPrint('Error loading records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecord(PracticeRecord record) async {
    try {
      await _databaseService.insertRecord(record);
      await loadRecords();
    } catch (e) {
      debugPrint('Error adding record: $e');
      rethrow;
    }
  }

  Future<void> updateRecord(PracticeRecord record) async {
    try {
      await _databaseService.updateRecord(record);
      await loadRecords();
    } catch (e) {
      debugPrint('Error updating record: $e');
      rethrow;
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _databaseService.deleteRecord(id);
      await loadRecords();
    } catch (e) {
      debugPrint('Error deleting record: $e');
      rethrow;
    }
  }

  Future<List<String>> getGuitarModelSuggestions() async {
    try {
      return await _databaseService.getUsedGuitarModels();
    } catch (e) {
      debugPrint('Error getting guitar models: $e');
      return [];
    }
  }
}
