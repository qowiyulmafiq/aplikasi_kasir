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
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else {
      imageContent = _buildFallback();
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 36,
        color: Colors.grey.shade400,
      ),
    );
  }
}
