import 'dart:io';
import 'package:flutter/material.dart';

class ProductImageWidget extends StatelessWidget {
  final String? imagePath;
  final String namaBarang;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const ProductImageWidget({
    super.key,
    required this.imagePath,
    required this.namaBarang,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imagePath != null && imagePath!.isNotEmpty;
    
    // Mengecek apakah file benar-benar ada di perangkat
    final bool fileExists = hasImage && File(imagePath!).existsSync();

    Widget imageContent;

    if (fileExists) {
      imageContent = Image.file(
        File(imagePath!),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: 300, // Membatasi ukuran decode RAM agar tidak berat
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      );
    } else {
      imageContent = _buildFallback(context);
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 36,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}
