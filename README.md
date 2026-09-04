# ♻️ TrashCycleControl

TrashCycleControl adalah aplikasi *mobile* yang dirancang untuk membantu pengguna memantau, mengonfigurasi, dan mengendalikan operasional sistem daur ulang sampah secara jarak jauh (*remote*). 

Aplikasi ini ditujukan khusus bagi pihak yang bertanggung jawab atas pengelolaan fasilitas dan kebersihan lingkungan, khususnya para petugas kebersihan (*Office Boy*) dan *Building Management* di lingkungan Universitas. Proyek ini dikembangkan sebagai bagian dari tugas *Project-Based Learning* (PBL) mata kuliah Pemrograman Mobile[cite: 2].

## 🌟 Fitur Utama

* **Monitoring Low-Smoke Incinerator:** Memantau suhu ruang bakar utama dan memvisualisasikan data pembakaran sampah residu agar operasional tetap aman dan emisi asap tetap minim.
* **Monitoring Smart Composting Bin:** Memantau parameter metrik lingkungan mikro, seperti tingkat kelembapan dan suhu pengomposan sampah organik secara *real-time*.
* **Monitoring Sistem Pirolisis Sampah Plastik:** Memantau stabilitas suhu pemanasan reaktor dan tekanan gas internal saat proses konversi limbah plastik menjadi bahan bakar cair berlangsung.
* **Sistem Notifikasi & Rekomendasi Aksi:** Memberikan peringatan (*alert*) dan instruksi penanganan instan (misalnya: notifikasi untuk menyemprotkan air pada komposter atau mengatur katup tekanan gas) ketika parameter sensor alat berada di luar batas ideal.

## 🛠️ Tech Stack

* **Framework:** Flutter
* **Bahasa Pemrograman:** Dart
* **Penyimpanan Data:** Local Storage (menyimpan *log* histori peringatan alat)[cite: 3]
* **Integrasi Data:** Dummy REST API / Mock MQTT (untuk menyimulasikan aliran data dari sensor mikrokontroler)[cite: 3]
* **Environment:** Android Studio & Android SDK
