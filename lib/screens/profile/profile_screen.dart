import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/store_settings_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../utils/image_picker_helper.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditProfileModal(BuildContext context, WidgetRef ref) {
    final profile = ref.read(userProfileNotifierProvider);
    final namaController = TextEditingController(text: profile.namaKasir);
    final peranController = TextEditingController(text: profile.peran);
    
    // Preset shift options
    const presetShifts = ['Full Day', 'Shift Pagi', 'Shift Sore'];
    String selectedPreset = presetShifts.contains(profile.namaShift)
        ? profile.namaShift
        : 'Kustom...';
        
    final shiftController = TextEditingController(text: profile.namaShift);
    String? selectedAvatarPath = profile.avatarPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Profil Kasir',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            backgroundImage: selectedAvatarPath != null &&
                                    File(selectedAvatarPath!).existsSync()
                                ? FileImage(File(selectedAvatarPath!))
                                : null,
                            child: (selectedAvatarPath == null ||
                                    !File(selectedAvatarPath!).existsSync())
                                ? Icon(
                                    Icons.person,
                                    size: 44,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  )
                                : null,
                          ),
                          InkWell(
                            onTap: () async {
                              final newPath =
                                  await ImagePickerHelper.pickAndSaveImage();
                              if (newPath != null) {
                                setStateModal(() {
                                  selectedAvatarPath = newPath;
                                });
                              }
                            },
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Nama Kasir / Pengguna',
                      isRequired: true,
                      controller: namaController,
                      hintText: 'Contoh: Budi Prasetyo',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Peran / Jabatan',
                      controller: peranController,
                      hintText: 'Contoh: Admin / Kasir Utama',
                    ),
                    const SizedBox(height: 16),
                    
                    // OPSI SHIFT KERJA
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Shift Kerja',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Full Day',
                            'Shift Pagi',
                            'Shift Sore',
                            'Kustom...'
                          ].map((option) {
                            final isSelected = selectedPreset == option;
                            return ChoiceChip(
                              label: Text(option),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setStateModal(() {
                                    selectedPreset = option;
                                    if (option != 'Kustom...') {
                                      shiftController.text = option;
                                    }
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                        if (selectedPreset == 'Kustom...') ...[
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Nama Shift Kustom',
                            controller: shiftController,
                            hintText: 'Contoh: Shift Malam / Shift 2',
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final nama = namaController.text.trim();
                          if (nama.isEmpty) return;

                          final finalShift = shiftController.text.trim().isNotEmpty
                              ? shiftController.text.trim()
                              : 'Shift Pagi';

                          ref
                              .read(userProfileNotifierProvider.notifier)
                              .updateProfile(
                                namaKasir: nama,
                                peran: peranController.text.trim(),
                                namaShift: finalShift,
                                avatarPath: selectedAvatarPath,
                              );

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profil berhasil diperbarui!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Profil'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileNotifierProvider);
    final storeSettings = ref.watch(storeSettingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil & Pengaturan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Header Profil (Material 3 style)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildProfileHeader(context, ref, userProfile, storeSettings),
          ),

          const Divider(height: 1),

          // 2. Grid Dashboard Menu
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16.0),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildGridItem(
                  context,
                  icon: Icons.store_mall_directory_outlined,
                  title: 'Toko & Struk',
                  onTap: () {
                    context.push('/profile/store-settings');
                  },
                ),
                _buildGridItem(
                  context,
                  icon: Icons.point_of_sale_outlined,
                  title: 'Perangkat Kasir',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur Perangkat Kasir segera hadir!'),
                      ),
                    );
                  },
                ),
                _buildGridItem(
                  context,
                  icon: Icons.settings_applications_outlined,
                  title: 'Operasional',
                  onTap: () {
                    context.push('/profile/operational-settings');
                  },
                ),
                _buildGridItem(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Sistem & Tampilan',
                  onTap: () {
                    context.push('/profile/system-settings');
                  },
                ),
              ],
            ),
          ),

          // 3. Tombol Logout / Ganti Shift
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  _showEditProfileModal(context, ref);
                },
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Ganti Shift / Edit Profil'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    UserProfile userProfile,
    StoreSettings storeSettings,
  ) {
    final hasAvatar = userProfile.avatarPath != null &&
        File(userProfile.avatarPath!).existsSync();

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: hasAvatar ? FileImage(File(userProfile.avatarPath!)) : null,
          child: !hasAvatar
              ? Icon(
                  Icons.person,
                  size: 36,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      userProfile.namaKasir,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Edit Profil',
                    onPressed: () => _showEditProfileModal(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                userProfile.peran,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                storeSettings.namaToko,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Badge Status Shift
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            userProfile.namaShift,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
