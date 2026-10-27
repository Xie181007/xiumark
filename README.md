# XiuMark

## Identitas

XiuMark adalah aplikasi Android untuk dokumentasi pekerjaan lapangan Telkom Akses. Foto hasil dokumentasi disimpan di perangkat dengan watermark informasi pekerjaan.

## Tujuan

Membantu petugas mendokumentasikan pekerjaan lapangan melalui foto yang dilengkapi informasi waktu, lokasi GPS, dan identitas petugas.

## Peta

Tab **Peta** menampilkan lokasi foto yang tersimpan dan posisi perangkat. Peta dasar OpenStreetMap membutuhkan koneksi internet; data foto tetap disimpan di perangkat. Paket peta offline belum disediakan.

## Cara mengunduh

[Unduh APK XiuMark](https://github.com/Xie181007/xiumark/releases/latest/download/XiuMark.apk)

Unduh dan buka `XiuMark.apk` di perangkat Android, lalu ikuti petunjuk instalasi. Jika diminta, izinkan pemasangan aplikasi dari sumber unduhan tersebut.

## Build APK dari GitHub Actions

Setiap push ke `main` atau pull request ke `main` menjalankan analisis dan membuat APK debug. APK dapat diunduh sebagai artefak **XiuMark-debug-apk** dari halaman Actions pada workflow yang berhasil. APK ini untuk uji coba dan disimpan 90 hari.

Rilis APK bertanda tangan dibuat oleh workflow **Build and publish Android APK** saat tag berawalan `v` didorong, misalnya `v1.0.1`. Workflow rilis memerlukan secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, dan `ANDROID_STORE_PASSWORD` yang sudah diatur di GitHub repository settings.
