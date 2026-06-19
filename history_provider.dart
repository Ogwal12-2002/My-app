import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scan_record.dart';
import '../services/database_service.dart';

class HistoryState {
  final List<ScanRecord> records;
  final bool isLoading;
  final String searchQuery;

  const HistoryState({
    this.records = const [],
    this.isLoading = false,
    this.searchQuery = '',
  });

  HistoryState copyWith({
    List<ScanRecord>? records,
    bool? isLoading,
    String? searchQuery,
  }) {
    return HistoryState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Owns the History screen's list state: loading from DB, live search,
/// individual delete, and clear-all. Each mutating method re-fetches from
/// the DB rather than mutating in-memory lists, keeping the DB as the
/// single source of truth (simple to reason about at this scale).
class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(const HistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    final records = await DatabaseService.instance.getAll(
      searchQuery: state.searchQuery,
    );
    state = state.copyWith(records: records, isLoading: false);
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadHistory();
  }

  Future<void> deleteRecord(int id) async {
    await DatabaseService.instance.deleteById(id);
    await loadHistory();
  }

  Future<void> clearAll() async {
    await DatabaseService.instance.clearAll();
    await loadHistory();
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>(
  (ref) => HistoryNotifier(),
);
