import 'package:flutter/material.dart';
import 'category_quick_picker_sheet.dart';
import '../providers/inventory_provider.dart';

class CategoryManagementSheet {
  static void show(BuildContext context) {
    CategoryQuickPickerSheet.show(
      context: context,
      selectedCategory: 'Semua',
      onCategorySelected: (_) {},
      selectedSort: ProductSortOption.namaAsc,
      onSortSelected: (_) {},
      initialManageMode: true,
    );
  }
}
