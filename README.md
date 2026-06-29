# CachyOS LXQt Hybrid God-Tier Setup

Script instalasi dan optimasi komprehensif untuk CachyOS berbasis ekosistem LXQt dan Openbox. Script ini secara dinamis mengkonfigurasi performa, manajemen daya, antarmuka pengguna (UI), dan mitigasi keamanan di level kernel, dirancang khusus untuk laptop (seperti Latitude 5300) maupun desktop.

## Fitur Utama

Script ini bukan sekadar installer, melainkan mesin automasi (deployment engine) dengan fitur perlindungan tingkat lanjut:

1. **Hybrid Smart Power (Manajemen Daya Otomatis)**
   - Otomatis beralih ke profil performa maksimal (turbo auto) saat tersambung ke pengisi daya.
   - Beralih ke penghematan baterai ekstrem (powersave, turbo mati) saat menggunakan baterai, diatur sepenuhnya oleh `auto-cpufreq`.
   - Menghapus daemon daya yang saling berkonflik (TLP, power-profiles-daemon, cpupower bawaan).

2. **Deteksi Hardware Dinamis & Injeksi Polybar**
   - Mendeteksi vendor CPU dan GPU (Intel/AMD) secara real-time.
   - Menyuntikkan nama antarmuka WiFi, baterai, dan kartu backlight yang tepat ke dalam konfigurasi tema Polybar secara otomatis. Ini menjamin Polybar selalu berfungsi 100% pada mesin apa pun.

3. **Perlindungan Kernel & X11 Anti-Blackscreen**
   - Menangani X11 secara dinamis: Mencegah Black Screen pada sistem Intel modern dengan memeriksa ketersediaan driver lawas sebelum memaksakan fitur `TearFree`.
   - Dukungan Universal Initramfs: Otomatis mendeteksi dan menggunakan `mkinitcpio` atau `dracut` sesuai dengan sistem Anda untuk memastikan injeksi parameter GPU di awal proses booting (Early KMS).

4. **Proteksi Kehilangan Data (Auto-Backup)**
   - Melindungi pengaturan pengguna yang sudah ada. Sebelum menimpa konfigurasi LXQt, Firefox, atau QTerminal, script otomatis membuat salinan cadangan (`.bak`).

5. **Optimasi Sistem Tingkat Lanjut**
   - **Sysctl & I/O:** Memaksa parameter latensi rendah, MGLRU, TCP BBRv3, THP (Transparent Huge Pages), dan penjadwal disk `kyber` untuk SSD/NVMe.
   - **Firefox Gecko Tuning:** Menyuntikkan 25+ parameter rahasia ke profil Firefox (dan Cachy-Browser), bahkan memaksa pembuatan profil dasar jika sistem masih dalam keadaan perawan (fresh install).
   - **Touchpad & Konektivitas:** Menanamkan konfigurasi `libinput` untuk mengaktifkan Tap-to-Click dan Natural Scrolling secara permanen. Mendaftarkan daemon Bluetooth dan NTP (sinkronisasi waktu).

6. **Absolute Shutdown Cleanup**
   - Memasukkan modul systemd khusus (`shutdown-cleanup.service`) yang berjalan setiap kali laptop dimatikan.
   - Modul ini membersihkan cache pacman, paket yatim piatu (orphans), cache aplikasi pengguna, dan melakukan TRIM pada SSD (Write-Amplification minimal).

## Pencegahan Fatal Error

Script ini menanamkan mekanisme perlindungan ketat:
- **Root-Blocker:** Menolak untuk berjalan jika dieksekusi dengan perintah `sudo bash ...`. Ini melindungi struktur konfigurasi direktori `/root` dari kerusakan.
- **Kemandirian Resolusi Paket:** Menghindari paket-paket *ghosting* (seperti `systemd-oomd` atau kustom Kvantum theme) dari pengelola paket Pacman agar script tidak crash.

## Cara Penggunaan

1. **Persiapan (Opsional)**
   Pastikan sistem Anda sudah terkoneksi ke internet.

2. **Eksekusi Script**
   Jalankan script menggunakan akun pengguna biasa (jangan gunakan `sudo` saat memulai). Script akan meminta kata sandi Anda setiap kali dibutuhkan hak akses root.

   ```bash
   cd ~/Scripts/CACHYOS_SETUP
   chmod +x setup_cachyos_lxqt_hybrid.sh
   ./setup_cachyos_lxqt_hybrid.sh
   ```

3. **Reboot**
   Setelah proses selesai dan log terminal menunjukan keberhasilan kompilasi, lakukan _reboot_ sistem untuk menerapkan seluruh modul, daemon, dan injeksi kernel.

## Struktur Lingkungan

- **Shell Default:** Fish Shell
- **Tampilan Utama:** LXQt + Openbox
- **Dock & Panel:** Plank & Polybar (Panel LXQt bawaan dinonaktifkan)
- **Skema Warna:** Arc Dark (Sistem) & Dracula Purple (Terminal)
- **Integrasi Login:** Modul otentikasi sidik jari (`pam_fprintd.so`) disuntikkan ke SDDM dan Login TTY.
