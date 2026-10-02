# 🏛️ Arsitektur Sistem & Standar Pengembangan — TrashCycleControl

Dokumen ini menjelaskan arsitektur menyeluruh, alur data (*data flow*), serta standar penamaan berkas dan *endpoint* API yang digunakan dalam pengembangan proyek **TrashCycleControl**. Proyek ini merupakan sistem pemantauan dan pengelolaan alat daur ulang sampah (Low-Smoke Incinerator, Smart Composting Bin, dan Sistem Pirolisis) yang ditujukan untuk *Building Management* dan petugas kebersihan di lingkungan Universitas Pradita.

---

## 1. Arsitektur Sistem (Monorepo)

Proyek ini menggunakan pendekatan **Monorepo** di bawah satu repositori Git utama, dengan pemisahan direktori yang jelas antara *backend* peladen dan aplikasi *mobile*:

```text
TrashCycleControl/
├── backend/            # Berisi project Laravel (REST API & Web Admin)
├── mobile/             # Berisi project Flutter (Mobile Client / APK)
├── .gitignore
└── README.md

```

* **Frontend Mobile (Flutter):** Berjalan di perangkat Android milik petugas lapangan untuk memantau metrik sensor secara *real-time* dan menerima notifikasi peringatan (*alert*).
* **Backend & Database Pusat (Laravel & MySQL):** Bertindak sebagai pusat pemrosesan data, menyediakan *RESTful API* untuk aplikasi *mobile*, serta menyajikan *dashboard* web bagi administrator.

---

## 2. Alur Data (*Data Flow*)

1. **Pengumpulan Data Fisik:** Perangkat mikrokontroler (ESP32/ESP32-S3) pada alat daur ulang membaca parameter lingkungan (suhu, kelembapan, tekanan).


2. **Transmisi Jaringan:** Perangkat mengirimkan data melalui protokol MQTT atau HTTP ke *server* pusat.
3. **Penyimpanan Database:** Backend Laravel menerima dan menyimpan data log sensor ke dalam database relasional pusat (MySQL).
4. **Konsumsi API (Mobile):** Aplikasi Flutter melakukan *HTTP request* (GET) ke *endpoint* API Laravel untuk merender data terbaru ke antarmuka pengguna (*UI*).
5. **Tindakan & Audit (Action Log):** Ketika petugas lapangan mendeteksi anomali (misalnya tekanan reaktor pirolisis berlebih) dan menyelesaikan tindakan penanganan melalui aplikasi, Flutter mengirimkan *request* (POST) ke *server* untuk mencatat status penyelesaian.



---

## 3. Standar Penamaan Berkas & Kode (*Naming Conventions*)

### A. Flutter (Mobile Frontend)

* **Direktori / Folder:** Menggunakan huruf kecil dengan pemisah garis bawah (`snake_case`), contoh: `lib/views/`, `lib/services/`, `lib/models/`.
* **Nama Berkas (*Files*):** Menggunakan format `snake_case.dart` (contoh: `dashboard_view.dart`, `api_service.dart`, `device_model.dart`).
* **Nama Kelas (*Classes*):** Menggunakan format huruf kapital di awal setiap kata tanpa spasi (`PascalCase`), contoh: `DashboardView`, `ApiService`, `DeviceModel`.
* **Variabel & Fungsi:** Menggunakan huruf kecil di awal dan kapital di kata selanjutnya (`camelCase`), contoh: `fetchDeviceData()`, `isLoading`, `temperatureValue`.

### B. Laravel (Backend & API)

* **Database Tables:** Menggunakan bentuk jamak (*plural*) dengan format `snake_case` (contoh: `users`, `devices`, `sensor_logs`, `alerts`).
* **Models:** Menggunakan nama tunggal (*singular*) dengan format `PascalCase` (contoh: `User`, `Device`, `SensorLog`).
* **Controllers:** Menggunakan format `PascalCase` diakhiri dengan kata `Controller` (contoh: `DeviceController`, `ActionController`).

---

## 4. Standar Endpoint RESTful API

Komunikasi data antara aplikasi Flutter dan *backend* Laravel menggunakan format JSON dengan standar RESTful berikut:

| Method | Endpoint | Deskripsi |
| --- | --- | --- |
| `GET` | `/api/v1/devices` | Mengambil daftar seluruh alat daur ulang (Incinerator, Composter, Pirolisis). |
| `GET` | `/api/v1/devices/{id}/sensors` | Mengambil data log sensor terbaru berdasarkan ID alat tertentu. |
| `POST` | `/api/v1/actions` | Mengirim data log tindakan penyelesaian masalah oleh petugas lapangan. |
| `POST` | `/api/v1/auth/login` | Autentikasi pengguna (*Office Boy* atau *Building Management*). |
