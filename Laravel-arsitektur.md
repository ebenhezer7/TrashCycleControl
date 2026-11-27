backend/app/
├── Http/
│   ├── Controllers/Api/              # Menerima request tervalidasi & mengembalikan JSON
│   ├── Middleware/                   # Validasi token Sanctum & pembatasan akses RBAC
│   └── Requests/                     # Validasi input terisolasi (FormRequest classes)
├── Models/                           # Eloquent ORM & relasi tabel database
└── Services/                         # Logika bisnis, query database, & threshold sensor