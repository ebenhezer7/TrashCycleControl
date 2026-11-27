mobile/
├── lib/
│   ├── core/                         # Komponen global & utilitas lintas-fitur
│   │   ├── constants/                # Palet tema SCADA (Charcoal/Cyan/Red) & konfigurasi API
│   │   ├── network/                  # HTTP client terpusat, handler 401 & deteksi offline
│   │   ├── services/                 # Layanan native (LogService, NotificationService)
│   │   └── widgets/                  # Komponen UI reusable (loading button, empty state)
│   │
│   ├── features/                     # Modul bisnis terisolasi per fitur
│   │   ├── auth/                     # Autentikasi & manajemen sesi RBAC
│   │   │   ├── data/                 # AuthRepository & penyimpanan token
│   │   │   ├── domain/               # Model User & aturan hak akses role
│   │   │   └── presentation/         # LoginView
│   │   │
│   │   ├── dashboard/                # Pemantauan sensor mesin (Incinerator, Composter, Pirolisis)
│   │   │   ├── data/                 # SensorRepository
│   │   │   ├── domain/               # Model MachineStatus & kalkulasi status anomali
│   │   │   └── presentation/         # DashboardView (LayoutBuilder adaptif)
│   │   │
│   │   ├── shift_notes/              # Manajemen Catatan Shift & Log Aktivitas
│   │   │   ├── data/                 # NotesRepository
│   │   │   ├── domain/               # Model ShiftNote & filter visibilitas role
│   │   │   └── presentation/         # NotesView & form input catatan
│   │   │
│   │   ├── scanner/                  # Pemindai QR Code perangkat
│   │   │   └── presentation/         # ScannerView & manajemen izin kamera
│   │   │
│   │   └── profile/                  # Manajemen Profil Pengguna
│   │       ├── data/                 # ProfileRepository (komunikasi API)
│   │       ├── domain/               # ProfileValidator (aturan validasi input murni)
│   │       └── presentation/         # ProfileView & ProfileForm (state UI)
│   │
│   └── main.dart                     # Entry point & Global Error Handler (runZonedGuarded)
│
└── test/                             # Pengujian otomatis terisolasi
└── scada_system_unit_test.dart   # 200 Unit Test Cases