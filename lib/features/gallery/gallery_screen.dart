import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/photo_store.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<List<PhotoRecord>> _photos;

  @override
  void initState() {
    super.initState();
    _photos = PhotoStore.instance.all();
  }

  void _refresh() => setState(() => _photos = PhotoStore.instance.all());

  @override
  Widget build(BuildContext context) => FutureBuilder<List<PhotoRecord>>(
        future: _photos,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError)
            return Center(
              child: Text('Galeri tidak dapat dibuka: ${snapshot.error}'),
            );
          final photos = snapshot.data ?? [];
          if (photos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 54,
                      color: Color(0xFF8B9AA5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada dokumentasi',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Foto yang diambil akan tersimpan privat di perangkat ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF71808D)),
                    ),
                  ],
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .78,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showPhoto(photo),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(photo.path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0xFFE8ECEE),
                          child:
                              Center(child: Icon(Icons.broken_image_outlined)),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          color: const Color(0xBB001725),
                          child: Text(
                            '${_date(photo.takenAt)}\n±${photo.accuracy.toStringAsFixed(1)} m',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
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

  Future<void> _showPhoto(PhotoRecord photo) async {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: const Color(0xFF101820),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  color: Colors.white,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  child: Center(
                    child: Image.file(File(photo.path), fit: BoxFit.contain),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${photo.latitude.toStringAsFixed(6)}, ${photo.longitude.toStringAsFixed(6)}\n${_date(photo.takenAt)} • ±${photo.accuracy.toStringAsFixed(1)} m',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _share(photo),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Bagikan'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    _refresh();
  }

  Future<void> _share(PhotoRecord photo) async {
    final shouldShare = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bagikan foto ini?'),
        content: const Text(
            'Foto akan dikirim ke aplikasi berbagi yang Anda pilih. Salinan yang diterima dapat disimpan oleh penerima atau aplikasi lain di luar kendali XiuMark.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Lanjutkan')),
        ],
      ),
    );
    if (shouldShare != true || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(photo.path)],
        text:
            'Dokumentasi XiuMark • ${photo.latitude.toStringAsFixed(6)}, ${photo.longitude.toStringAsFixed(6)}',
        sharePositionOrigin:
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  String _date(DateTime value) {
    final local = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }
}
