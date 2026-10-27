import 'package:flutter/material.dart';

import '../../data/photo_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pengaturan',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SettingsItem(
              icon: Icons.person_outline,
              title: 'Nama petugas',
              subtitle: 'Atur identitas pada watermark',
              onTap: () => _editOfficer(context),
            ),
            _SettingsItem(
              icon: Icons.gps_fixed,
              title: 'Akurasi lokasi',
              subtitle: 'Ambang validasi GPS',
              onTap: () => _editAccuracy(context),
            ),
            _SettingsItem(
              icon: Icons.camera_alt_outlined,
              title: 'Resolusi kamera',
              subtitle: 'Pilih kualitas foto sesuai kemampuan perangkat',
              onTap: () => _editCameraResolution(context),
            ),
            const _SettingsItem(
              icon: Icons.storage_outlined,
              title: 'Penyimpanan foto',
              subtitle: 'Foto disimpan privat di perangkat',
            ),
            const SizedBox(height: 18),
            const Text(
              'XiuMark menyimpan dokumentasi secara lokal. Berbagi hanya dilakukan atas pilihan Anda.',
              style: TextStyle(color: Color(0xFF71808D), height: 1.5),
            ),
          ],
        ),
      );

  Future<void> _editOfficer(BuildContext context) async {
    final controller = TextEditingController(
      text: await PhotoStore.instance.officerName(),
    );
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nama petugas'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(
            labelText: 'Nama yang tampil pada watermark',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              await PhotoStore.instance.setOfficerName(controller.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _editAccuracy(BuildContext context) async {
    final current = await PhotoStore.instance.accuracyThreshold();
    if (!context.mounted) return;
    var selected = current.clamp(1.0, 50.0);
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ambang akurasi GPS'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
                'Foto valid memerlukan akurasi perangkat maksimal ${selected.toStringAsFixed(0)} meter.'),
            Slider(
                value: selected,
                min: 1,
                max: 50,
                divisions: 49,
                label: '${selected.toStringAsFixed(0)} m',
                onChanged: (value) => setDialogState(() => selected = value)),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal')),
            FilledButton(
                onPressed: () async {
                  await PhotoStore.instance.setAccuracyThreshold(selected);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }

  Future<void> _editCameraResolution(BuildContext context) async {
    final current = await PhotoStore.instance.cameraResolution();
    if (!context.mounted) return;
    const options = <String, String>{
      'low': 'Rendah',
      'medium': 'Sedang',
      'high': 'Tinggi',
      'veryHigh': 'Sangat tinggi',
      'max': 'Maksimum perangkat',
    };
    var selected = options.containsKey(current) ? current : 'max';
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Resolusi kamera'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in options.entries)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: selected,
                  onChanged: (value) =>
                      setDialogState(() => selected = value!),
                ),
              const Text(
                'Pilihan maksimum mengikuti batas kamera perangkat. Perubahan berlaku saat kamera dibuka kembali.',
                style: TextStyle(color: Color(0xFF71808D), fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                await PhotoStore.instance.setCameraResolution(selected);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5),
        leading: Icon(icon, color: const Color(0xFF087E83)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
        onTap: onTap,
      );
}
