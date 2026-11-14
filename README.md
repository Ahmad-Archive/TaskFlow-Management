# TaskFlow - Aplikasi Manajemen Tugas & Proyek
**TaskFlow** adalah aplikasi manajemen tugas berbasis **Flutter** dengan desain **Material 3** yang mengimplementasikan operasi **REST API CRUD** (Create, Read, Update, Delete) secara penuh.
Aplikasi ini dibangun menggunakan arsitektur berlapis (Layered Architecture) dengan pemisahan yang jelas antara tampilan (UI), pengelolaan state, model data, dan layanan komunikasi jaringan.

## Fitur Utama
- Manajemen Tugas Lengkap (CRUD): Membuat tugas baru, melihat daftar dan detail tugas, memperbarui informasi tugas, serta menghapus tugas yang sudah tidak diperlukan.
- Ubah Status Cepat: Memperbarui status pengerjaan (To-Do, In Progress, Done) langsung dari halaman detail menggunakan komponen SegmentedButton tanpa harus membuka form edit.
- Pencarian & Filter Dinamis: Menyaring daftar tugas berdasarkan kategori status dan mencari tugas secara instan berdasarkan judul maupun deskripsi.
- Deteksi Tenggat Waktu (Deadline): Pemformatan tanggal yang mudah dibaca beserta penanda otomatis apabila tugas telah melewati batas waktu (overdue).
- Penanganan State & Jaringan: Dilengkapi indikator loading, pull-to-refresh, tampilan saat data kosong (empty state), serta pesan error dengan tombol Coba Lagi saat koneksi terputus.

## Teknologi & PackageFramework
- Flutter SDK (Material 3)
- State Management: provider - Mengelola sinkronisasi data antara API dan antarmuka pengguna secara reaktif.
- HTTP Client: dio - Menangani permintaan HTTP (GET, POST, PUT, DELETE), konfigurasi timeout, dan penerjemahan error jaringan.
- Formatting: intl - Memformat objek DateTime menjadi format tanggal yang ramah pengguna.
- Mock Backend: MockAPI.io - Penyedia layanan REST API untuk pengujian data.

## Struktur Proyek
```bash
lib/
├── main.dart                         # Entry point aplikasi, tema Material 3, & inisialisasi Provider
├── models/
│   └── task_model.dart               # Model data Tugas & serialisasi JSON (fromJson / toJson)
├── providers/
│   └── task_provider.dart            # State management, filter status, & pencarian kata kunci
├── screens/
│   ├── home_screen.dart              # Halaman utama: daftar tugas, search bar, & filter chip
│   ├── task_detail_screen.dart       # Halaman detail tugas, ubah status cepat, & aksi hapus
│   └── task_form_screen.dart         # Form serbaguna untuk tambah (POST) & edit (PUT) tugas
└── services/
    └── task_service.dart             # Lapisan komunikasi REST API menggunakan Dio
```

## Skema & Endpoint REST API
Aplikasi ini terhubung ke resource `/tasks` dengan struktur objek JSON sebagai berikut:
```bash
{
  "id": "1",
  "title": "Selesaikan laporan praktikum",
  "description": "Melengkapi dokumentasi arsitektur dan pengujian CRUD",
  "status": "in_progress",
  "priority": "high",
  "dueDate": "2026-11-20T00:00:00.000Z"
}
```

## Daftar Endpoint
| Metode | Endpoint | Deskripsi |
| - | - | - |
| GET | `/tasks` | Mengambil seluruh daftar tugas |
| POST | `/tasks` | Menambahkan tugas baru |
| PUT | `/tasks/:id` | Memperbarui data tugas berdasarkan `id` |
| DELETE | `/tasks/:id` | Menghapus tugas berdasarkan `id` |

## Cara Menjalankan Proyek
1. Clone repositori ini:
```bash
git clone https://github.com/Ahmad-Archive/TaskFlow-Management.git
cd TaskFlow-Management
```

2. Unduh seluruh dependensi Flutter:
```bash
flutter pub get
```

3. Konfigurasi Endpoint API:
Buka file `lib/services/task_service.dart` dan sesuaikan nilai _baseUrl dengan URL proyek MockAPI milikmu:
```bash
static const String _baseUrl = 'https://<kode-unik-kamu>.mockapi.io';
```

4. Jalankan aplikasi:
```bash
flutter run
```
## Pengembang
Ahmad-Archive - GitHub Profile