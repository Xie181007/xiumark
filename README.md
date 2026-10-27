# XiuMark

Fondasi aplikasi Flutter untuk dokumentasi lapangan Telkom Akses. XiuMark dirancang offline-first; dokumentasi disimpan privat pada perangkat dan tidak diunggah otomatis.

## Menjalankan

```sh
flutter pub get
flutter run
```

## Status implementasi

Fondasi Android/iOS, tema, navigasi utama, halaman awal, pengaturan nama petugas dan ambang akurasi GPS, serta aset logo resmi tersedia. Logo sumber disalin dari `TelkomAkses Network Logo.png` menjadi `assets/images/telkom_akses_logo.png` tanpa dibuat ulang.

Kamera menggunakan resolusi maksimum yang ditawarkan perangkat, mendukung fokus sentuh, zoom, flash, dan pergantian kamera bila tersedia. Sebelum memotret, aplikasi mengumpulkan tiga sampel GPS; foto hanya dapat diambil jika akurasi dan kestabilan lolos ambang yang diatur (5 m secara default). Sampel yang berumur lebih dari 30 detik ditolak.

Hasil disimpan sebagai PNG beresolusi asli di direktori privat aplikasi. Logo resmi, tanggal/waktu dengan zona waktu, koordinat, akurasi, nama petugas, dan identitas XiuMark digambar permanen ke foto. SQLite menyimpan metadata foto dan waktu pengukuran lokasi. Galeri privat dapat menampilkan dan membagikan foto setelah pengguna memilihnya.

PIN/biometrik, proyek, peta MapLibre/vector tiles, pencarian offline, paket peta Indonesia dan installer terverifikasi belum diimplementasikan. Nama administratif tidak tersedia sampai basis data geografis offline ditambahkan; watermark menyatakan keterbatasan ini secara eksplisit. Ukuran APK belum diukur dan target 30 MB belum diverifikasi.
