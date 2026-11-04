# Design system

Token ada di `lib/core/theme/app_colors.dart`; kontras diuji di `test/contrast_test.dart`.

## Perubahan hex dari usulan awal (hasil uji kontras)
- `yellow600` `#D98E04` -> `#B26A03` (kontras 2.59 vs yellow50, butuh >= 3).
- `yellow700` `#B26A03` -> `#9A5C00` (kontras 4.09, butuh >= 4.5 untuk teks).

Aturan: teks di atas `primary` selalu `ink`; tidak pernah putih di atas kuning.
