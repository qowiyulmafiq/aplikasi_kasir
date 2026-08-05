// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionsStreamHash() =>
    r'ad882105ca81aa6d7d5568f25843cd87eb8e54b1';

/// See also [transactionsStream].
@ProviderFor(transactionsStream)
final transactionsStreamProvider =
    AutoDisposeStreamProvider<List<TransaksiData>>.internal(
  transactionsStream,
  name: r'transactionsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TransactionsStreamRef
    = AutoDisposeStreamProviderRef<List<TransaksiData>>;
String _$filteredTransactionsHash() =>
    r'45a11052228544a2f758b8586f91b129f1739ab2';

/// See also [filteredTransactions].
@ProviderFor(filteredTransactions)
final filteredTransactionsProvider =
    AutoDisposeProvider<List<TransaksiData>>.internal(
  filteredTransactions,
  name: r'filteredTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredTransactionsRef = AutoDisposeProviderRef<List<TransaksiData>>;
String _$filteredRevenueHash() => r'd738557c1e2f964bc6bfce3197ab917a328173fc';

/// See also [filteredRevenue].
@ProviderFor(filteredRevenue)
final filteredRevenueProvider = AutoDisposeProvider<int>.internal(
  filteredRevenue,
  name: r'filteredRevenueProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredRevenueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredRevenueRef = AutoDisposeProviderRef<int>;
String _$filteredTransactionCountHash() =>
    r'42dddbee3a775e079937cba0af09e37da4122b37';

/// See also [filteredTransactionCount].
@ProviderFor(filteredTransactionCount)
final filteredTransactionCountProvider = AutoDisposeProvider<int>.internal(
  filteredTransactionCount,
  name: r'filteredTransactionCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredTransactionCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredTransactionCountRef = AutoDisposeProviderRef<int>;
String _$historySearchQueryHash() =>
    r'a76709602f61260636caf3585090762954b6bd26';

/// See also [HistorySearchQuery].
@ProviderFor(HistorySearchQuery)
final historySearchQueryProvider =
    AutoDisposeNotifierProvider<HistorySearchQuery, String>.internal(
  HistorySearchQuery.new,
  name: r'historySearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$historySearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HistorySearchQuery = AutoDisposeNotifier<String>;
String _$historyDateFilterHash() => r'ac19ad0a13f5ef2602839cd664743f55da4d8b8b';

/// See also [HistoryDateFilter].
@ProviderFor(HistoryDateFilter)
final historyDateFilterProvider =
    AutoDisposeNotifierProvider<HistoryDateFilter, DateFilter>.internal(
  HistoryDateFilter.new,
  name: r'historyDateFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$historyDateFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HistoryDateFilter = AutoDisposeNotifier<DateFilter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
