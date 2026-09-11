# ♻️ TrashCycleControl

TrashCycleControl adalah aplikasi *mobile* dan sistem *dashboard* terintegrasi yang dirancang untuk membantu pengguna memantau, mengonfigurasi, dan mengendalikan operasional sistem daur ulang sampah secara jarak jauh (*remote*). 

Aplikasi ini ditujukan khusus bagi pihak yang bertanggung jawab atas pengelolaan fasilitas dan kebersihan lingkungan, khususnya para petugas kebersihan (*Office Boy*) dan *Building Management* di lingkungan Universitas Pradita[cite: 4]. Proyek ini dikembangkan sebagai bagian dari tugas *Project-Based Learning* (PBL) mata kuliah Pemrograman Mobile[cite: 2].

## 🌟 Fitur Utama

* **Monitoring Low-Smoke Incinerator:** Memantau suhu ruang bakar utama dan memvisualisasikan data pembakaran sampah residu agar operasional tetap aman dan emisi asap tetap minim[cite: 1, 4].
* **Monitoring Smart Composting Bin:** Memantau parameter metrik lingkungan mikro, seperti tingkat kelembapan dan suhu pengomposan sampah organik secara *real-time*[cite: 1].
* **Monitoring Sistem Pirolisis Sampah Plastik:** Memantau stabilitas suhu pemanasan reaktor dan tekanan gas internal saat proses konversi limbah plastik menjadi bahan bakar cair berlangsung[cite: 1, 4].
* **Sistem Notifikasi & Rekomendasi Aksi:** Memberikan peringatan (*alert*) dan instruksi penanganan instan (misalnya: notifikasi untuk menyemprotkan air pada komposter atau mengatur katup tekanan gas) ketika parameter sensor alat berada di luar batas ideal[cite: 1, 4].

## 🛠️ Tech Stack & Arsitektur Sistem

* **Mobile Frontend:** Flutter (Dart)
* **Backend & Web Admin:** Laravel (PHP) terintegrasi dengan Bootstrap *blade views*
* **Database Pusat:** MySQL / PostgreSQL (Pusat kendali data dan manajemen pengguna)
* **Penyimpanan Lokal (Mobile):** SQLite / Shared Preferences (menyimpan *cache* sesi pengguna dan riwayat *alert* luring)[cite: 3]
* **Komunikasi Data:** RESTful API & Protokol MQTT (transmisi data perangkat mikrokontroler IoT ke *server*)
* **Environment:** Android Studio & Android SDK

## 🚀 Panduan Instalasi & Menjalankan Proyek (Getting Started)

Ikuti langkah-langkah berikut untuk menjalankan aplikasi ini di komputer lokal:

### Prasyarat
Pastikan sistem Anda sudah terinstal:
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Android Studio](https://developer.android.com/studio) (beserta Android SDK & Virtual Device/Emulator)
* Git
