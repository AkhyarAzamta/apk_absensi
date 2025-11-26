# Attedance System

Aplikasi absensi berbasis mobile.

## Setup Proyek

Untuk menjalankan proyek ini, ikuti langkah-langkah berikut:

### API (Express & Prisma)

1.  **Clone repositori:**
    ```bash
    git clone https://github.com/akhyarazamta/apk_absensi.git
    cd apk_absensi/api
    ```
2.  **Instal dependensi:**
    ```bash
    npm install
    # atau
    yarn install
    ```
3.  **Konfigurasi database:**
    Buat file `.env` di root proyek dan tambahkan konfigurasi database Anda. Contoh untuk PostgreSQL:
    ```
    DATABASE_URL="postgresql://user:password@localhost:5432/absensi_db?schema=public"
    ```
    Sesuaikan dengan database yang Anda gunakan (MySQL, SQLite, dll.).
4.  **Jalankan migrasi Prisma:**
    ```bash
    npx prisma migrate dev --name init
    npm run prisma:seed
    ```
5.  **Jalankan server pengembangan:**
    ```bash
    npm run dev
    # atau
    yarn dev
    ```
    API akan berjalan di `http://localhost:3000` (atau port yang dikonfigurasi).

### Frontend (Flutter)

1.  **Clone repositori:**
    ```bash
    git clone https://github.com/akhyarazamta/apk_absensi.git
    cd apk_absensi/frontend
    ```
2.  **Instal dependensi Flutter:**
    ```bash
    flutter pub get
    ```
3.  **Konfigurasi API URL:**
    Buka file konfigurasi di proyek Flutter Anda (misalnya `lib/config/api_config.dart` atau sejenisnya) dan sesuaikan URL API dengan backend yang sedang berjalan:
    ```dart
    const String API_BASE_URL = 'http://10.0.2.2:3000'; // Untuk emulator Android
    // const String API_BASE_URL = 'http://localhost:3000'; // Untuk iOS simulator atau web
    ```
    (Catatan: `10.0.2.2` adalah alias untuk `localhost` di emulator Android.)
4.  **Jalankan aplikasi Flutter:**
    ```bash
    flutter run -d chrome
    ```
   
   ## Overview
   ### Admin
<img src="api/public/admin/admin1.png" width="20%" />
<img src="api/public/admin/admin2.png" width="20%" />
<img src="api/public/admin/admin3.png" width="20%" />
<img src="api/public/admin/admin4.png" width="20%" />
<img src="api/public/admin/admin5.png" width="20%" />
<img src="api/public/admin/admin6.png" width="20%" />
<img src="api/public/admin/admin7.png" width="20%" />
<img src="api/public/admin/admin8.png" width="20%" />
<img src="api/public/admin/admin9.png" width="20%" />
<img src="api/public/admin/admin10.png" width="20%" />
<img src="api/public/admin/admin11.png" width="20%" />
<img src="api/public/admin/admin12.png" width="20%" />
<img src="api/public/admin/admin13.png" width="20%" />


   ### User
<img src="api/public/user/user1.png" width="20%" />
<img src="api/public/user/user2.png" width="20%" />
<img src="api/public/user/user3.png" width="20%" />
<img src="api/public/user/user4.png" width="20%" />
<img src="api/public/user/user5.png" width="20%" />
<img src="api/public/user/user6.png" width="20%" />
<img src="api/public/user/user7.png" width="20%" />
<img src="api/public/user/user8.png" width="20%" />
<img src="api/public/user/user9.png" width="20%" />
<img src="api/public/user/user10.png" width="20%" />
<img src="api/public/user/user11.png" width="20%" />
<img src="api/public/user/user12.png" width="20%" />
<img src="api/public/user/user13.png" width="20%" />
