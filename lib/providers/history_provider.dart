import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database/app_database.dart';
import 'database_provider.dart';

part 'history_provider.g.dart';

enum DateFilter { today, last7Days, thisMonth, all }

@riverpod
class HistorySearchQuery extends _$HistorySearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

@riverpod
class HistoryDateFilter extends _$HistoryDateFilter {
  @override
  DateFilter build() => DateFilter.today;

  void setFilter(DateFilter filter) {
    state = filter;
  }
}

@riverpod
Stream<List<TransaksiData>> transactionsStream(TransactionsStreamRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllTransaksi();
}

@riverpod
List<TransaksiData> filteredTransactions(FilteredTransactionsRef ref) {
  final transactions = ref.watch(transactionsStreamProvider).valueOrNull ?? [];
  final searchQuery = ref.watch(historySearchQueryProvider).trim().toLowerCase();
  final dateFilter = ref.watch(historyDateFilterProvider);

  final now = DateTime.now();

  return transactions.where((t) {
    // Filter by Date (Jika sedang melakukan pencarian ID, cari di semua tanggal)
    bool dateMatch = false;
    if (searchQuery.isNotEmpty) {
      dateMatch = true;
    } else {
      final date = t.tanggalTransaksi;
      switch (dateFilter) {
        case DateFilter.today:
          dateMatch = date.year == now.year && date.month == now.month && date.day == now.day;
          break;
        case DateFilter.last7Days:
          final diff = now.difference(date).inDays;
          dateMatch = diff >= 0 && diff <= 7;
          break;
        case DateFilter.thisMonth:
          dateMatch = date.year == now.year && date.month == now.month;
          break;
        case DateFilter.all:
          dateMatch = true;
          break;
      }
    }

    // Filter berdasarkan Pencarian ID Transaksi
    bool searchMatch = true;
    if (searchQuery.isNotEmpty) {
      final rawId = t.id.toString();
      final paddedId = rawId.padLeft(4, '0');
      final formattedId = '#trx-$paddedId';
      final formattedIdNoHash = 'trx-$paddedId';

      final cleanNumberQuery = searchQuery
          .replaceAll('#', '')
          .replaceAll('trx', '')
          .replaceAll('-', '')
          .trim();

      searchMatch = rawId.contains(searchQuery) ||
          paddedId.contains(searchQuery) ||
          formattedId.contains(searchQuery) ||
          formattedIdNoHash.contains(searchQuery) ||
          (cleanNumberQuery.isNotEmpty && rawId.contains(cleanNumberQuery)) ||
          (cleanNumberQuery.isNotEmpty && paddedId.contains(cleanNumberQuery));
    }

    return dateMatch && searchMatch;
  }).toList().reversed.toList();
}

@riverpod
int filteredRevenue(FilteredRevenueRef ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  return transactions.fold(0, (sum, t) => sum + t.totalHarga);
}

@riverpod
int filteredTransactionCount(FilteredTransactionCountRef ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  return transactions.length;
}
