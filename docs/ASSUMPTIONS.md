# Asumsi

- Proyek Flutter tetap di root repo (bukan `app/`); `emotion-service/` dan `n8n/` akan disamping `lib/`.
- Tahap 1 hanya mockup: `MockTemaniApi` menggantikan n8n/LLM. Kontrak API Bagian 6 sudah dimodelkan agar `DioTemaniApi` bisa menggantikannya.
- Penyimpanan lokal sementara in-memory di balik interface repository; drift menyusul. `TODO-VERIFY`.
- Label: anger, sadness, fear, happy, love; neutral dari ambang (default 0.5, `TODO-VERIFY`).
- `docs/PROMPT.md` belum disalin; simpan prompt asli di sana.
