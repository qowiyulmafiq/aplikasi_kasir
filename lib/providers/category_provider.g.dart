// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryNamesHash() => r'ad855e541f4982f2dd5b48e63bfb7b6a9a2bb25f';

/// See also [categoryNames].
@ProviderFor(categoryNames)
final categoryNamesProvider = AutoDisposeProvider<List<String>>.internal(
  categoryNames,
  name: r'categoryNamesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryNamesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoryNamesRef = AutoDisposeProviderRef<List<String>>;
String _$categoryListHash() => r'508462f0044c10f4c72632c4cf76d65d6922e87c';

/// See also [CategoryList].
@ProviderFor(CategoryList)
final categoryListProvider = AutoDisposeStreamNotifierProvider<CategoryList,
    List<KategoriData>>.internal(
  CategoryList.new,
  name: r'categoryListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$categoryListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CategoryList = AutoDisposeStreamNotifier<List<KategoriData>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
