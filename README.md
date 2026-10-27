# XiuMark

Fondasi aplikasi Flutter untuk dokumentasi lapangan Telkom Akses. XiuMark dirancang offline-first; dokumentasi disimpan privat pada perangkat dan tidak diunggah otomatis.

## Identitas aplikasi

- **Nama:** XiuMark
- **Kegunaan:** dokumentasi pekerjaan lapangan.
- **Lingkungan penggunaan:** Telkom Akses.
- **Platform unduhan pada rilis ini:** Android (APK).
- **Atribusi logo:** logo Telkom Akses pada aset aplikasi dipertahankan apa adanya.

Android `applicationId` masih bernilai template `com.example.xiumark`. Ganti dengan ID unik milik organisasi sebelum rilis publik pertama, lalu pertahankan ID yang sama untuk semua pembaruan.

## Unduh dan pasang

[Unduh APK XiuMark terbaru](https://github.com/Xie181007/xiumark/releases/latest/download/XiuMark.apk)

Rilis terbaru: [v1.0.3](https://github.com/Xie181007/xiumark/releases/tag/v1.0.3). APK berukuran sekitar 53,6 MB. [Checksum SHA-256](https://github.com/Xie181007/xiumark/releases/download/v1.0.3/SHA256SUMS.txt).

1. Unduh `XiuMark.apk` dari halaman GitHub Releases.
2. Buka APK di perangkat Android dan ikuti petunjuk instalasi. Jika Android meminta izin, izinkan instalasi aplikasi dari aplikasi sumber unduhan.
3. Buka XiuMark dan izinkan kamera serta lokasi saat digunakan. Foto valid hanya bisa diambil jika GPS memenuhi ambang yang diatur.

APK saat ini belum membawa paket peta offline Indonesia; fitur kamera dan dokumentasi foto dapat digunakan tanpa paket tersebut.

Unduh pembaruan dari tautan rilis yang sama. Jaga keystore penandatanganan tetap aman dan gunakan keystore yang sama untuk seluruh versi agar pembaruan dapat dipasang di atas versi sebelumnya.

## Terbitkan APK melalui GitHub Actions

Workflow `.github/workflows/android-release.yml` menganalisis kode, membangun APK rilis bertanda tangan, membuat checksum SHA-256, lalu menerbitkan GitHub Release setiap kali tag versi `v*` didorong.

Siapkan keystore Android satu kali di luar repo:

```sh
keytool -genkeypair -v -keystore "$HOME/xiumark-upload.jks" \
  -keyalg RSA -keysize 2048 -validity 10000 -alias xiumark
base64 -w 0 "$HOME/xiumark-upload.jks"
```

Tambahkan output Base64 dan informasi keystore sebagai **Actions repository secrets** dengan nama berikut. Jangan simpan nilainya di source code atau commit ke Git:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_STORE_PASSWORD`

Workflow memerlukan izin `contents: write` untuk membuat GitHub Release. GitHub Actions menyediakan token repo dengan izin yang diatur di workflow. [Dokumentasi `GITHUB_TOKEN`](https://docs.github.com/en/actions/concepts/security/github_token)

Setelah menaikkan versi pada `pubspec.yaml`, buat dan dorong tag versi baru (contoh `v1.0.4`):

```sh
git tag v1.0.4
git push origin v1.0.4
```

Selesai jika job **Build and publish Android APK** berhasil. APK, checksum, dan informasi build akan tersedia pada GitHub Release.

## Menjalankan

```sh
flutter pub get
flutter run
```

## Struktur kode

- `lib/main.dart`: tema dan entry point.
- `lib/features/home/`: navigasi dan beranda.
- `lib/features/camera/`: pratinjau serta pengambilan foto.
- `lib/features/location/`: izin, pengambilan sampel, dan validasi GPS.
- `lib/features/watermark/`: komposisi watermark ke piksel foto.
- `lib/features/gallery/`: galeri privat dan berbagi eksplisit.
- `lib/features/settings/`: nama petugas dan ambang akurasi.
- `lib/data/`: penyimpanan SQLite dan lokasi file privat.

Konfigurasi mesin lokal, kredensial, signing keys, cache, dan hasil build dikecualikan di `.gitignore`. Jangan menambahkan credential ke source control.

## Status implementasi

Fondasi Android/iOS, tema, navigasi utama, halaman awal, pengaturan nama petugas dan ambang akurasi GPS, serta aset logo resmi tersedia. Logo sumber disalin dari `TelkomAkses Network Logo.png` menjadi `assets/images/telkom_akses_logo.png` tanpa dibuat ulang.

Kamera menggunakan resolusi maksimum yang ditawarkan perangkat, mendukung fokus sentuh, zoom, flash, dan pergantian kamera bila tersedia. Sebelum memotret, aplikasi mengumpulkan tiga sampel GPS; foto hanya dapat diambil jika akurasi dan kestabilan lolos ambang yang diatur (5 m secara default). Sampel yang berumur lebih dari 30 detik ditolak.

Hasil disimpan sebagai PNG beresolusi asli di direktori privat aplikasi. Logo resmi, tanggal/waktu dengan zona waktu, koordinat, akurasi, nama petugas, dan identitas XiuMark digambar permanen ke foto. SQLite menyimpan metadata foto dan waktu pengukuran lokasi. Galeri privat dapat menampilkan dan membagikan foto setelah pengguna memilihnya.

PIN/biometrik, proyek, peta MapLibre/vector tiles, pencarian offline, paket peta Indonesia dan installer terverifikasi belum diimplementasikan. Nama administratif tidak tersedia sampai basis data geografis offline ditambahkan; watermark menyatakan keterbatasan ini secara eksplisit. Ukuran APK belum diukur dan target 30 MB belum diverifikasi.
