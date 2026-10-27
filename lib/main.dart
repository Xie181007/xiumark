import 'package:flutter/material.dart';

import 'data/photo_store.dart';
import 'features/camera/camera_screen.dart';
import 'features/gallery/gallery_screen.dart';

void main() => runApp(const XiuMarkApp());

class XiuMarkApp extends StatelessWidget {
  const XiuMarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF152B43);
    const teal = Color(0xFF087E83);
    return MaterialApp(
      title: 'XiuMark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
        colorScheme: ColorScheme.fromSeed(seedColor: teal, primary: teal),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7F8),
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const _destinations = <_Destination>[
    _Destination('Beranda', Icons.grid_view_rounded),
    _Destination('Kamera', Icons.photo_camera_outlined),
    _Destination('Galeri', Icons.photo_library_outlined),
    _Destination('Peta Offline', Icons.map_outlined),
    _Destination('Proyek', Icons.folder_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                'assets/images/telkom_akses_logo.png',
                width: 42,
                height: 34,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.hub_outlined),
              ),
            ),
            const SizedBox(width: 11),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'XiuMark',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                Text(
                  'Dokumentasi lapangan',
                  style: TextStyle(fontSize: 11, color: Color(0xFF71808D)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pengaturan',
            onPressed: () => _openSettings(context),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: switch (_selectedIndex) {
          0 => _Dashboard(
              onNavigate: (index) => setState(() => _selectedIndex = index),
            ),
          1 => const CameraScreen(),
          2 => const GalleryScreen(),
          _ => _FeaturePage(destination: _destinations[_selectedIndex]),
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: _destinations
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const _SettingsPage()));
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF123D55), Color(0xFF087E83)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.white, size: 15),
                    SizedBox(width: 6),
                    Text(
                      'TERSIMPAN PRIVAT DI PERANGKAT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Dokumentasikan\npekerjaan dengan yakin.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 25,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Foto, lokasi, dan informasi pekerjaan dalam satu dokumentasi.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .82),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => onNavigate(1),
                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                label: const Text('Mulai dokumentasi'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF125260),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          title: 'Ruang kerja',
          subtitle: 'Akses cepat fitur XiuMark',
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.38,
          children: [
            _QuickCard(
              icon: Icons.photo_library_outlined,
              title: 'Galeri privat',
              caption: 'Dokumentasi tersimpan',
              color: const Color(0xFFEEF4FF),
              iconColor: const Color(0xFF4568A8),
              onTap: () => onNavigate(2),
            ),
            _QuickCard(
              icon: Icons.map_outlined,
              title: 'Peta offline',
              caption: 'Jelajahi lokasi kerja',
              color: const Color(0xFFE9F6F3),
              iconColor: const Color(0xFF168174),
              onTap: () => onNavigate(3),
            ),
            _QuickCard(
              icon: Icons.folder_open_outlined,
              title: 'Proyek',
              caption: 'Kelola pekerjaan',
              color: const Color(0xFFFFF4E6),
              iconColor: const Color(0xFFBA7622),
              onTap: () => onNavigate(4),
            ),
            _QuickCard(
              icon: Icons.tune_rounded,
              title: 'Pengaturan',
              caption: 'Preferensi dokumentasi',
              color: const Color(0xFFF1EDFA),
              iconColor: const Color(0xFF765CA5),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const _SettingsPage()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          title: 'Kesiapan perangkat',
          subtitle: 'Status fitur dokumentasi',
        ),
        const SizedBox(height: 12),
        const _StatusRow(
          icon: Icons.location_searching,
          title: 'Lokasi perangkat',
          detail: 'Perlu izin lokasi saat digunakan',
          badge: 'Belum aktif',
          warning: true,
        ),
        const SizedBox(height: 9),
        const _StatusRow(
          icon: Icons.map_outlined,
          title: 'Paket peta Indonesia',
          detail: 'Pasang paket peta untuk akses offline',
          badge: 'Belum dipasang',
          warning: true,
        ),
      ],
    );
  }
}

class _FeaturePage extends StatelessWidget {
  const _FeaturePage({required this.destination});
  final _Destination destination;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3F2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  destination.icon,
                  size: 34,
                  color: const Color(0xFF087E83),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                destination.label,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF152B43),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fondasi aplikasi siap. Fitur ini akan tersedia pada tahap pengembangan berikutnya.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF71808D), height: 1.5),
              ),
            ],
          ),
        ),
      );
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

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
              icon: Icons.pin_outlined,
              title: 'Keamanan aplikasi',
              subtitle: 'PIN dan biometrik',
            ),
            _SettingsItem(
              icon: Icons.gps_fixed,
              title: 'Akurasi lokasi',
              subtitle: 'Ambang validasi GPS',
              onTap: () => _editAccuracy(context),
            ),
            _SettingsItem(
              icon: Icons.camera_alt_outlined,
              title: 'Preferensi kamera',
              subtitle: 'Resolusi, flash, dan kamera',
            ),
            _SettingsItem(
              icon: Icons.storage_outlined,
              title: 'Penyimpanan',
              subtitle: 'Foto dan paket peta offline',
            ),
            SizedBox(height: 18),
            Text(
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
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF152B43),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF71808D), fontSize: 12),
          ),
        ],
      );
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.caption,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String caption;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF152B43),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      caption,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF71808D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.badge,
    this.warning = false,
  });
  final IconData icon;
  final String title;
  final String detail;
  final String badge;
  final bool warning;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF087E83)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style:
                        const TextStyle(color: Color(0xFF71808D), fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color:
                    warning ? const Color(0xFFFFF3DF) : const Color(0xFFE7F6EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: warning
                      ? const Color(0xFF9B681D)
                      : const Color(0xFF28764D),
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      );
}

class _Destination {
  const _Destination(this.label, this.icon);
  final String label;
  final IconData icon;
}
