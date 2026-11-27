flowchart LR
A[Push ke v1.0_dev] --> B{Jalankan 200 Unit Test}
B -- Ada Test Failed (Merah) --> C[Build & Deploy Diblokir ❌<br/>Versi Live Tetap Aman]
B -- All 200 Passed (Hijau) --> D[Auto Build APK Release ✅]
D --> E[Upload Artifact / Deploy]
E --> F[Merge ke Branch V1.1 🚀]