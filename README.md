# XiuMark

## Identitas

XiuMark adalah aplikasi Android untuk dokumentasi pekerjaan lapangan Telkom Akses. Foto hasil dokumentasi disimpan di perangkat dengan watermark informasi pekerjaan.

## Tujuan

Membantu petugas mendokumentasikan pekerjaan lapangan melalui foto yang dilengkapi informasi waktu, lokasi GPS, dan identitas petugas.

## Peta

Tab **Peta** menampilkan lokasi foto yang tersimpan dan posisi perangkat. Peta dasar OpenStreetMap membutuhkan koneksi internet; data foto tetap disimpan di perangkat. Paket peta offline belum disediakan.

## Unduh APK Android

[Unduh XiuMark.apk dari rilis terbaru](https://github.com/Xie181007/xiumark/releases/latest/download/XiuMark.apk) · [Lihat semua rilis](https://github.com/Xie181007/xiumark/releases)

Tautan unduh langsung tersedia setelah sebuah GitHub Release memiliki aset bernama `XiuMark.apk`. Workflow rilis di bawah menyiapkan dan mengunggah APK dengan nama tersebut. Setelah diunduh, buka file di Android dan ikuti petunjuk pemasangan.

## Build APK dari GitHub Actions

Setiap push ke `main` atau pull request ke `main` menjalankan analisis dan membuat APK debug. [Unduh APK debug dari artefak GitHub Actions ini](https://github.com/Xie181007/xiumark/actions/runs/40682061318/artifacts/12814055503). APK ini untuk uji coba dan disimpan 90 hari.

Rilis APK bertanda tangan dibuat oleh workflow **Build and publish Android APK** saat tag berawalan `v` didorong, misalnya `v1.0.1`. Workflow rilis memerlukan secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, dan `ANDROID_STORE_PASSWORD` yang sudah diatur di GitHub repository settings.

## Checklist sebelum rilis publik

- Pastikan empat secrets penandatanganan Android sudah diatur. Simpan cadangan keystore dan kata sandinya dengan aman; pembaruan aplikasi harus ditandatangani dengan kunci yang sama.
- Buat tag versi seperti `v1.0.1`. Workflow memakai versi dari tag dan nomor build unik dari GitHub Actions.
- ID aplikasi Android saat ini `com.telkomakses.xiumark`. Pastikan ID ini sesuai dengan identitas penerbit dan gunakan ID yang sama untuk semua pembaruan berikutnya.
- Uji APK pada perangkat nyata, terutama izin kamera/lokasi, pengambilan foto saat GPS lemah, penyimpanan, berbagi, dan penghapusan foto.
- Peta dasar memerlukan internet. Foto dan metadata disimpan lokal; belum ada pencadangan atau sinkronisasi otomatis.
