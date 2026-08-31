import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/google_sheets_provider.dart';
import '../services/google_sheets_service.dart';
import 'custom_text_field.dart';

class GoogleSheetsSyncDialog extends ConsumerStatefulWidget {
  const GoogleSheetsSyncDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GoogleSheetsSyncDialog(),
    );
  }

  @override
  ConsumerState<GoogleSheetsSyncDialog> createState() =>
      _GoogleSheetsSyncDialogState();
}

class _GoogleSheetsSyncDialogState
    extends ConsumerState<GoogleSheetsSyncDialog> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final currentState = ref.read(googleSheetsSyncProvider);
    _urlController = TextEditingController(text: currentState.webAppUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _copyTemplateCode() {
    Clipboard.setData(
        const ClipboardData(text: GoogleSheetsService.appsScriptTemplate));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kode Apps Script berhasil disalin ke Clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleSaveAndSync() async {
    final url = _urlController.text.trim();
    await ref.read(googleSheetsSyncProvider.notifier).saveWebAppUrl(url);

    if (!mounted) return;

    final result = await ref.read(googleSheetsSyncProvider.notifier).syncNow();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );

    if (result.success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final syncState = ref.watch(googleSheetsSyncProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.sync_alt,
                      color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sinkronisasi Google Sheets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (syncState.lastSyncTime != null)
                        Text(
                          'Terakhir: ${syncState.lastSyncTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // KOTAK INSTRUKSI SETUP SCRIPT
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Panduan Setup (Hanya 1x Saja):',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Buka Google Sheet -> Ekstensi -> Apps Script\n'
                      '2. Salin kode script lalu tempel di Apps Script\n'
                      '3. Klik Deploy -> Web App (Set "Who has access" ke Anyone)\n'
                      '4. Tempel URL Web App ke kolom di bawah ini',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _copyTemplateCode,
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Salin Kode Apps Script'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // INPUT URL WEB APP DENGAN CUSTOM TEXT FIELD
            CustomTextField(
              label: 'URL Web App Google Apps Script',
              hintText: 'https://script.google.com/macros/s/.../exec',
              controller: _urlController,
              prefixIcon: const Icon(Icons.link),
              suffixIcon: _urlController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _urlController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            if (syncState.lastError != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: colorScheme.error.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: colorScheme.onErrorContainer, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        syncState.lastError!,
                        style: TextStyle(
                            color: colorScheme.onErrorContainer, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            if (syncState.lastMessage != null && syncState.lastError == null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: colorScheme.onPrimaryContainer, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        syncState.lastMessage!,
                        style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // TOMBOL SINKRONISASI SEKARANG
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: syncState.isSyncing ? null : _handleSaveAndSync,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: syncState.isSyncing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: colorScheme.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_sync),
                label: Text(
                  syncState.isSyncing
                      ? 'Menyinkronkan Data...'
                      : 'Simpan & Sinkronkan Sekarang',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
