# Finance App 💰

Aplikasi manajemen keuangan pribadi berbasis Flutter.

## Tech Stack
- Flutter & Dart
- Supabase (Database)
- QuickChart.io (Grafik)

## Setup Project

### 1. Clone repo
```bash
git clone https://github.com/username/finance-app.git
cd finance-app
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Setup Supabase Config
Salin file contoh lalu isi dengan kredensial yang didapat dari Anggota 1:
```bash
cp lib/config/supabase_config.example.dart lib/config/supabase_config.dart
```

### 4. Jalankan app
```bash
flutter run
```

## Pembagian Tugas
| Anggota | Branch | Tugas |
|---------|--------|-------|
| Anggota 1 | dev | Setup & Integrasi |
| Anggota 2 | feature/dashboard-riwayat | Dashboard & Riwayat |
| Anggota 3 | feature/tambah-edit-transaksi | Form Transaksi |
| Anggota 4 | feature/supabase-crud | Koneksi Supabase |
| Anggota 5 | feature/analisis-chart | Grafik & Analisis |