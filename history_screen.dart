import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../providers/history_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import 'widgets/history_tile.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(historyProvider.notifier).search('');
      }
    });
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('This will permanently delete all scan history. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear all', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(historyProvider.notifier).clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search history...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => ref.read(historyProvider.notifier).search(value),
              )
            : const Text('History'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          if (!_isSearching && state.records.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear_all') _confirmClearAll();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'clear_all', child: Text('Clear all')),
              ],
            ),
        ],
      ),
      body: _buildBody(state),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildBody(HistoryState state) {
    if (state.isLoading && state.records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.records.isEmpty) {
      return _EmptyState(isSearching: state.searchQuery.isNotEmpty);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final record = state.records[index];
        return Dismissible(
          key: ValueKey(record.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) {
            ref.read(historyProvider.notifier).deleteRecord(record.id!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Scan deleted')),
            );
          },
          child: HistoryTile(
            record: record,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.result, arguments: record),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearching;

  const _EmptyState({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.history,
            size: 56,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 12),
          Text(
            isSearching ? 'No matching scans' : 'No scans yet',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
