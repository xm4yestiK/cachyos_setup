#!/usr/bin/env bash

# ========================================================================
# Script Personalisasi & Optimasi "HYBRID GOD-TIER" (SMART POWER)
# Dibuat khusus: OS CachyOS x86_64 | DYNAMIC AUTO-DETECT (INTEL & AMD)
# 
# [FITUR UTAMA SCRIPT INI]:
# - Otomatis Ganas/Rata Kanan (Mode Performa) saat dicolok Charger.
# - Otomatis Hemat Baterai Ekstrem (Mode Powersave) saat tanpa Charger.
# - (BARU) Integrasi Mutlak: Firefox Gecko Tuning, Polybar Modern,
#   QTerminal Dracula Purple, Fingerprint (PAM), & Absolute Cleanup.
# ========================================================================

set -e

if [ "$EUID" -eq 0 ]; then
  echo "================================================================="
  echo "[-] FATAL ERROR: JANGAN JALANKAN SCRIPT INI DENGAN 'SUDO' ATAU ROOT!"
  echo "    Script ini dirancang untuk dijalankan sebagai User Biasa."
  echo "    Ia akan meminta password sudo secara otomatis saat dibutuhkan."
  echo "    Jika dijalankan sebagai root, semua konfigurasi desktop akan rusak!"
  echo "    Silakan jalankan ulang tanpa 'sudo'."
  echo "================================================================="
  exit 1
fi

echo "================================================================="
echo "Memulai injeksi performa HYBRID SMART-POWER CachyOS (Juni 2026)..."
echo "Mengintegrasikan SEMUA script kustom Anda menjadi 1 eksekusi solid."
echo "================================================================="

# ========================================================================
# AUTO-DETEKSI HARDWARE (CPU & GPU)
# ========================================================================
echo ">> [PROSES] Mendeteksi Vendor CPU..."
CPU_VENDOR=$(grep -m 1 'vendor_id' /proc/cpuinfo | awk '{print $3}' || true)
GPU_VENDOR="unknown"

echo ">> [PROSES] Mendeteksi Vendor GPU (VGA/3D)..."
if lspci -nn | grep -i 'vga\|3d\|display' | grep -iq 'intel'; then
    GPU_VENDOR="intel"
elif lspci -nn | grep -i 'vga\|3d\|display' | grep -iq 'amd\|radeon'; then
    GPU_VENDOR="amd"
fi

echo ">> HASIL DETEKSI CPU: $CPU_VENDOR"
echo ">> HASIL DETEKSI GPU: $GPU_VENDOR"
echo "================================================================="

# 1. Update & Instalasi
echo ""
echo "[1/20] Instalasi Ekosistem CachyOS + Paket Tuning..."
sudo pacman -Syu --noconfirm --needed \
    fish lxqt openbox kvantum ttf-jetbrains-mono-nerd \
    papirus-icon-theme breeze qterminal fastfetch scx-scheds ananicy-cpp \
    cachyos-ananicy-rules irqbalance auto-cpufreq pacman-contrib \
    picom plank network-manager-applet blueman bluez bluez-utils brightnessctl \
    fprintd pavucontrol

# 2. Personalisasi UI (LXQt, Kvantum, GTK)
echo ""
echo "[2/20] Setup Shell, Locale & Tampilan LXQt..."
[ "$SHELL" != "/usr/bin/fish" ] && chsh -s /usr/bin/fish || true

sudo sed -i 's/^#id_ID.UTF-8 UTF-8/id_ID.UTF-8 UTF-8/' /etc/locale.gen || true
sudo locale-gen >/dev/null 2>&1 || true
sudo localectl set-locale LANG=id_ID.UTF-8 || true

mkdir -p ~/.config/lxqt ~/.config/Kvantum ~/.config/gtk-3.0 ~/.config/gtk-4.0 ~/.config/qterminal.org
# Backup konfigurasi lama agar tidak musnah
[ -f ~/.config/lxqt/lxqt.conf ] && cp ~/.config/lxqt/lxqt.conf ~/.config/lxqt/lxqt.conf.bak || true
[ -f ~/.config/lxqt/session.conf ] && cp ~/.config/lxqt/session.conf ~/.config/lxqt/session.conf.bak || true
cat <<EOF > ~/.config/lxqt/lxqt.conf
[General]
theme=kvantum
icon_theme=Papirus-Dark
cursor_theme=breeze
cursor_size=22
[Qt]
font="JetBrainsMono Nerd Font,12,-1,5,50,0,0,0,0,0,Regular"
style=kvantum
EOF
echo "[General]" > ~/.config/Kvantum/kvantum.kvconfig
echo "theme=KvArcDark#" >> ~/.config/Kvantum/kvantum.kvconfig

cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=HighContrastInverse
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Adwaita Sans 11
EOF
cat <<EOF > ~/.config/gtk-4.0/settings.ini
[Settings]
gtk-theme-name=Adwaita
gtk-icon-theme-name=Adwaita
gtk-font-name=Adwaita Sans 11
EOF

cat <<EOF > ~/.config/lxqt/session.conf
[General]
window_manager=openbox
EOF

# 3. Integrasi Autostart (Polybar, Plank, Picom, Applet Jaringan)
echo ""
echo "[3/20] Merakit Sistem Autostart (Dock, Bar, Visual, dan Konektivitas)..."
mkdir -p ~/.config/autostart

# Mematikan lxqt-panel bawaan agar tidak bentrok dengan Polybar & Plank
cat << 'EOF' > ~/.config/autostart/lxqt-panel.desktop
[Desktop Entry]
Hidden=true
EOF

cat << 'EOF' > ~/.config/autostart/polybar.desktop
[Desktop Entry]
Type=Application
Name=Polybar Status Bar
Exec=bash -c "sleep 0.2 && bash ~/.config/polybar/launch.sh --shapes"
Hidden=false
NoDisplay=false
X-LXQt-Need-Tray=true
EOF

cat << 'EOF' > ~/.config/autostart/plank.desktop
[Desktop Entry]
Type=Application
Name=Plank Dock
Exec=bash -c "sleep 0.5 && plank"
Hidden=false
NoDisplay=false
X-LXQt-Need-Tray=false
EOF

cat << 'EOF' > ~/.config/autostart/picom.desktop
[Desktop Entry]
Type=Application
Name=Picom Compositor
Exec=picom -b
Hidden=false
NoDisplay=false
X-LXQt-Need-Tray=false
EOF

cat << 'EOF' > ~/.config/autostart/nm-applet.desktop
[Desktop Entry]
Type=Application
Name=Network Manager Applet
Exec=nm-applet
Hidden=false
NoDisplay=false
X-LXQt-Need-Tray=true
EOF

cat << 'EOF' > ~/.config/autostart/blueman.desktop
[Desktop Entry]
Type=Application
Name=Bluetooth Manager Applet
Exec=blueman-applet
Hidden=false
NoDisplay=false
X-LXQt-Need-Tray=true
EOF

chmod +x ~/.config/autostart/*.desktop 2>/dev/null || true

echo ""
echo "[3.5/20] Injeksi Intelijen Hardware ke Polybar..."
# Polybar pada perangkat baru sering rusak/kosong karena nama WiFi/Baterai berbeda
# Modul ini secara cerdas mendeteksi hardware spesifik dan menginjeksinya.
POLYBAR_DIR="$HOME/.config/polybar/shapes"
if [ -d "$POLYBAR_DIR" ]; then
    WIFI_IFACE=$(ls /sys/class/net 2>/dev/null | grep '^wl' | head -n1 || true)
    BATTERY_NAME=$(ls -1 /sys/class/power_supply/ 2>/dev/null | grep '^BAT' | head -n1 || true)
    ADAPTER_NAME=$(ls -1 /sys/class/power_supply/ 2>/dev/null | grep -E '^ADP|^AC' | head -n1 || true)
    BACKLIGHT_CARD=$(ls -1 /sys/class/backlight/ 2>/dev/null | head -n1 || true)

    # Fallback aman
    [ -z "$WIFI_IFACE" ] && WIFI_IFACE="wlan0"
    [ -z "$BATTERY_NAME" ] && BATTERY_NAME="BAT0"
    [ -z "$ADAPTER_NAME" ] && ADAPTER_NAME="AC"
    [ -z "$BACKLIGHT_CARD" ] && BACKLIGHT_CARD="intel_backlight"

    if [ -f "$POLYBAR_DIR/modules.ini" ]; then
        sed -i "s/^[[:space:]]*card[[:space:]]*=.*/card = $BACKLIGHT_CARD/" "$POLYBAR_DIR/modules.ini" || true
        sed -i "s/^[[:space:]]*battery[[:space:]]*=.*/battery = $BATTERY_NAME/" "$POLYBAR_DIR/modules.ini" || true
        sed -i "s/^[[:space:]]*adapter[[:space:]]*=.*/adapter = $ADAPTER_NAME/" "$POLYBAR_DIR/modules.ini" || true
        sed -i "s/^[[:space:]]*interface[[:space:]]*=[[:space:]]*wlp.*/interface = $WIFI_IFACE/" "$POLYBAR_DIR/modules.ini" || true
        sed -i "s/^[[:space:]]*interface[[:space:]]*=[[:space:]]*wlan.*/interface = $WIFI_IFACE/" "$POLYBAR_DIR/modules.ini" || true
    fi
    if [ -f "$POLYBAR_DIR/bars.ini" ]; then
        sed -i "s/^[[:space:]]*card[[:space:]]*=.*/card = $BACKLIGHT_CARD/" "$POLYBAR_DIR/bars.ini" || true
        sed -i "s/^[[:space:]]*battery[[:space:]]*=.*/battery = $BATTERY_NAME/" "$POLYBAR_DIR/bars.ini" || true
        sed -i "s/^[[:space:]]*adapter[[:space:]]*=.*/adapter = $ADAPTER_NAME/" "$POLYBAR_DIR/bars.ini" || true
    fi
    echo "       -> Polybar auto-config: WiFi[$WIFI_IFACE], Bat[$BATTERY_NAME], AC[$ADAPTER_NAME], Light[$BACKLIGHT_CARD]"
fi

# 4. Integrasi QTerminal Dracula
echo ""
echo "[4/20] Menginjeksi Skema Warna Dracula Purple untuk QTerminal..."
sudo mkdir -p /usr/share/qtermwidget5/color-schemes/ /usr/share/qtermwidget6/color-schemes/
sudo tee /usr/share/qtermwidget5/color-schemes/DraculaPurple.colorscheme /usr/share/qtermwidget6/color-schemes/DraculaPurple.colorscheme > /dev/null << 'EOF'
[General]
Description=Dracula Purple per 2026
Opacity=1
[Background]
Color=40,42,54
[Foreground]
Color=248,248,242
[Color0]
Color=40,42,54
[Color0Intense]
Color=98,114,164
[Color1]
Color=255,85,85
[Color1Intense]
Color=255,106,106
[Color2]
Color=80,250,123
[Color2Intense]
Color=96,253,143
[Color3]
Color=241,250,140
[Color3Intense]
Color=242,251,160
[Color4]
Color=189,147,249
[Color4Intense]
Color=202,169,250
[Color5]
Color=255,121,198
[Color5Intense]
Color=255,146,211
[Color6]
Color=139,233,253
[Color6Intense]
Color=154,237,254
[Color7]
Color=248,248,242
[Color7Intense]
Color=255,255,255
EOF
[ -f ~/.config/qterminal.org/qterminal.ini ] && cp ~/.config/qterminal.org/qterminal.ini ~/.config/qterminal.org/qterminal.ini.bak || true
cat <<EOF > ~/.config/qterminal.org/qterminal.ini
[General]
fontFamily=JetBrainsMonoNL Nerd Font Mono
fontSize=14
colorScheme=DraculaPurple
EOF

# 5. Integrasi Fingerprint (PAM)
echo ""
echo "[5/20] Mendaftarkan Fingerprint (fprintd) ke modul PAM TTY & Display Manager..."
if [ -f /etc/pam.d/system-local-login ] && ! grep -q "pam_fprintd.so" /etc/pam.d/system-local-login; then
    sudo sed -i '1iauth      sufficient  pam_fprintd.so' /etc/pam.d/system-local-login || true
fi
if [ -f /etc/pam.d/sddm ] && ! grep -q "pam_fprintd.so" /etc/pam.d/sddm; then
    sudo sed -i '1iauth      sufficient  pam_fprintd.so' /etc/pam.d/sddm || true
fi
if [ -f /etc/pam.d/lightdm ] && ! grep -q "pam_fprintd.so" /etc/pam.d/lightdm; then
    sudo sed -i '1iauth      sufficient  pam_fprintd.so' /etc/pam.d/lightdm || true
fi

# 6. Integrasi Optimasi Firefox
echo ""
echo "[6/20] Menyuntikkan Tuning Mentok Engine Gecko (Firefox/Cachy-Browser)..."
killall -9 firefox cachy-browser 2>/dev/null || true
sleep 0.5

# Memaksa pembuatan profil jika OS masih perawan (browser belum pernah dibuka)
command -v firefox >/dev/null && firefox -CreateProfile "default" 2>/dev/null || true
command -v cachy-browser >/dev/null && cachy-browser -CreateProfile "default" 2>/dev/null || true

for PROFILE_DIR in ~/.mozilla/firefox/*.default* ~/.cachy/cachy-browser/*.default* ~/.config/mozilla/firefox/*.default*; do
    if [ -d "$PROFILE_DIR" ]; then
        echo "       -> Mengoptimalkan profil Firefox: $PROFILE_DIR"
        [ -f "$PROFILE_DIR/user.js" ] && cp "$PROFILE_DIR/user.js" "$PROFILE_DIR/user.js.bak" || true
        cat << 'EOF' > "$PROFILE_DIR/user.js"
user_pref("gfx.webrender.all", true);
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.ffvpx.enabled", false); 
user_pref("media.rdd-vpx.enabled", false);
user_pref("gfx.canvas.accelerated", true);
user_pref("gfx.canvas.accelerated.cache-items", 4096);
user_pref("gfx.canvas.accelerated.cache-size", 512);
user_pref("gfx.content.skia-font-cache-size", 20);
user_pref("network.http.http3.enable", true);
user_pref("network.http.max-connections", 1800);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.dns.disableIPv6", false);
user_pref("network.predictor.enabled", true);
user_pref("network.predictor.enable-prefetch", true);
user_pref("browser.cache.disk.enable", false);
user_pref("browser.cache.memory.enable", true);
user_pref("browser.cache.memory.capacity", -1);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("content.notify.interval", 100000);
user_pref("browser.display.show_image_placeholders", true);
EOF
    fi
done

# ========================================================================
# OPTIMASI KERNEL & HARDWARE (HYBRID SMART-POWER)
# ========================================================================

echo ""
echo "[7/20] Kernel Sysctl (Latensi Nol & TCP BBRv3)..."
sudo mkdir -p /etc/sysctl.d
cat <<EOF | sudo tee /etc/sysctl.d/99-cachyos-godtier.conf
vm.swappiness=150
vm.watermark_boost_factor=20000
vm.watermark_scale_factor=250
vm.page-cluster=0
vm.vfs_cache_pressure=10
vm.dirty_bytes=268435456
vm.dirty_background_bytes=134217728
vm.dirty_writeback_centisecs=1500
vm.stat_interval=10
net.ipv4.tcp_fastopen=3
net.core.default_qdisc=cake
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_low_latency=1
net.core.netdev_max_backlog=32768
net.ipv4.tcp_max_syn_backlog=16384
kernel.split_lock_mitigate=0
kernel.nmi_watchdog=0
kernel.kptr_restrict=0
kernel.perf_cpu_time_max_percent=1
EOF
sudo sysctl --system || true

echo ""
echo "[8/20] Mengaktifkan MGLRU & THP secara paksa..."
sudo mkdir -p /etc/tmpfiles.d
cat <<EOF | sudo tee /etc/tmpfiles.d/mglru-thp.conf
w /sys/kernel/mm/lru_gen/enabled - - - - 1
w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise
w /sys/kernel/mm/transparent_hugepage/shmem_enabled - - - - advise
EOF

echo ""
echo "[9/20] AUTO-CPUFREQ: Otak Manajemen Daya Cerdas (Hybrid Mode)..."
sudo mkdir -p /etc
cat <<EOF | sudo tee /etc/auto-cpufreq.conf
[battery]
governor = powersave
energy_performance_preference = power
turbo = never
[charger]
governor = performance
energy_performance_preference = performance
turbo = auto
EOF

echo ""
echo "[10/20] Mematikan Coredump & Watchdog secara permanen..."
sudo mkdir -p /etc/systemd/coredump.conf.d
cat <<EOF | sudo tee /etc/systemd/coredump.conf.d/disable.conf
[Coredump]
Storage=none
ProcessSizeMax=0
EOF

echo ""
echo "[11/20] Eksekusi Driver iGPU (Akselerasi & Penghematan Layar)..."
sudo mkdir -p /etc/modprobe.d
if [ "$GPU_VENDOR" = "intel" ]; then
    cat <<EOF | sudo tee /etc/modprobe.d/gpu-godtier.conf
options i915 enable_guc=3 enable_fbc=1 enable_psr=1
EOF
elif [ "$GPU_VENDOR" = "amd" ]; then
    cat <<EOF | sudo tee /etc/modprobe.d/gpu-godtier.conf
options amdgpu ppfeaturemask=0xffffffff
EOF
fi

echo ""
echo "[12/20] Konfigurasi X11 (TearFree & Low Latency)..."
sudo mkdir -p /etc/X11/xorg.conf.d
if [ "$GPU_VENDOR" = "intel" ]; then
    # Hanya gunakan konfigurasi "intel" jika xf86-video-intel terinstal, mencegah Black Screen
    if pacman -Qs xf86-video-intel >/dev/null 2>&1; then
        cat <<EOF | sudo tee /etc/X11/xorg.conf.d/20-gpu.conf
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "TearFree" "true"
    Option "TripleBuffer" "false"
    Option "SwapbuffersWait" "false"
EndSection
EOF
    fi
elif [ "$GPU_VENDOR" = "amd" ]; then
    cat <<EOF | sudo tee /etc/X11/xorg.conf.d/20-gpu.conf
Section "Device"
    Identifier "AMD Graphics"
    Driver "amdgpu"
    Option "TearFree" "true"
EndSection
EOF
fi

echo "       -> Menanamkan Konfigurasi Touchpad (Tap-to-Click & Natural Scrolling)..."
cat <<EOF | sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf
Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
    Option "ClickMethod" "clickfinger"
EndSection
EOF

echo ""
echo "[13/20] MESA & OpenGL Environment Variables..."
sudo mkdir -p /etc/profile.d
cat <<EOF | sudo tee /etc/profile.d/mesa-godtier.sh
export MESA_NO_ERROR=1
export MESA_DISK_CACHE_MAX_SIZE=10G
export LIBGL_ALWAYS_SOFTWARE=0
EOF
if [ "$GPU_VENDOR" = "intel" ]; then
    echo "export INTEL_DEBUG=noccs" | sudo tee -a /etc/profile.d/mesa-godtier.sh
fi

echo ""
echo "[14/20] Optimasi FSTAB (Mengurangi Write-Amplification SSD)..."
if [ -f /etc/fstab ]; then
    sudo cp /etc/fstab /etc/fstab.godtier.backup
    sudo sed -i 's/relatime/noatime,commit=60/g' /etc/fstab
fi

echo ""
echo "[15/20] UDEV Rules: I/O Scheduler SSD/NVMe -> 'kyber' (0-latency)..."
sudo mkdir -p /etc/udev/rules.d
cat <<EOF | sudo tee /etc/udev/rules.d/60-ioschedulers.rules
ACTION=="add|change", KERNEL=="nvme[0-9]*|sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
EOF

echo ""
echo "[16/20] Konfigurasi Picom (Compositor Paling Mulus)..."
mkdir -p ~/.config/picom
cat <<EOF > ~/.config/picom/picom.conf
backend = "glx";
vsync = false;
glx-no-stencil = true;
glx-no-rebind-pixmap = true;
use-damage = true;
unredir-if-possible = true;
EOF

echo ""
echo "[17/20] Membangun Modul Absolute Shutdown Cleanup..."
echo "       -> Menggabungkan penghapusan cache, orphans, pacman, yay, log, dan TRIM SSD."
sudo mkdir -p /usr/local/bin
cat <<'EOF' | sudo tee /usr/local/bin/shutdown-cleanup.sh
#!/usr/bin/env bash
# 1. Hapus Orphans Packages (jika ada)
if pacman -Qtdq > /dev/null 2>&1; then
    pacman -Rns $(pacman -Qtdq) --noconfirm || true
fi
# 2. Pembersihan Pacman Cache (Yay cache otomatis terhapus di langkah 3)
pacman -Sc --noconfirm || true
paccache -rk2 || true
# 3. Ekstrem Cache Cleanup (Menghapus isi ~/.cache user)
rm -rf /home/*/.cache/* || true
# 4. Log Journal & Sync
journalctl --vacuum-size=100M || true
sync
fstrim -av || true
EOF
sudo chmod +x /usr/local/bin/shutdown-cleanup.sh

cat <<EOF | sudo tee /etc/systemd/system/shutdown-cleanup.service
[Unit]
Description=Absolute SSD Purge and Clean on Shutdown
DefaultDependencies=no
Before=shutdown.target reboot.target halt.target
Requires=local-fs.target
ConditionPathExists=/usr/local/bin/shutdown-cleanup.sh
[Service]
Type=oneshot
ExecStart=/usr/local/bin/shutdown-cleanup.sh
TimeoutSec=120
[Install]
WantedBy=halt.target shutdown.target
EOF

echo ""
echo "[18/20] Injeksi Parameter Boot Kritis (mitigations=off)..."
if [ "$CPU_VENDOR" = "AuthenticAMD" ]; then
    BOOT_PARAMS="mitigations=off nowatchdog amd_pstate=active quiet"
else
    BOOT_PARAMS="mitigations=off nowatchdog quiet"
fi

if bootctl is-installed &>/dev/null; then
    shopt -s nullglob
    for entry in /boot/loader/entries/*.conf; do
        [ -f "$entry" ] || continue
        if ! grep -q "mitigations=off" "$entry"; then
            sudo sed -i "s/^\(options .*\)/\1 $BOOT_PARAMS/" "$entry"
        fi
    done
    shopt -u nullglob
elif [ -f /etc/default/grub ]; then
    if ! grep -q "mitigations=off" /etc/default/grub; then
        sudo sed -i "s/^\(GRUB_CMDLINE_LINUX_DEFAULT=[\"']\)/\1$BOOT_PARAMS /" /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg || true
    fi
fi

echo ""
echo "[19/20] Eksekusi Daemon (Auto-Cpufreq, Shutdown-Cleanup & Pemusnahan Konflik Daya)..."
sudo systemctl daemon-reload
# Mematikan Daemon yang Bentrok (TLP / PPD) sesuai perf_tweak.sh
sudo systemctl disable --now power-profiles-daemon.service tlp.service 2>/dev/null || true
sudo systemctl mask power-profiles-daemon.service tlp.service 2>/dev/null || true
# Membuang sisa cpupower lama
sudo systemctl disable --now cpupower.service 2>/dev/null || true

# Menyalakan Daemon Vital
sudo systemctl enable --now ananicy-cpp.service || true
sudo systemctl enable --now irqbalance.service || true
sudo systemctl enable --now auto-cpufreq.service || true
sudo systemctl enable shutdown-cleanup.service || true
sudo systemctl enable systemd-tmpfiles-setup.service || true
sudo systemctl enable --now bluetooth.service || true
# Menggunakan timedatectl agar tidak bentrok jika sistem memakai chrony
sudo timedatectl set-ntp true || true

if [ -f /etc/default/scx ]; then
    sudo sed -i 's/^SCX_SCHEDULER=.*/SCX_SCHEDULER="scx_lavd"/' /etc/default/scx
else
    sudo mkdir -p /etc/default
    echo 'SCX_SCHEDULER="scx_lavd"' | sudo tee /etc/default/scx
fi
sudo systemctl enable --now scx.service || true

echo ""
echo "[20/20] Membangun Ulang Initramfs (Universal)..."
if command -v mkinitcpio &> /dev/null; then
    sudo mkinitcpio -P || true
fi
if command -v dracut &> /dev/null; then
    sudo dracut --force --regenerate-all || true
fi

echo ""
echo "=============================================================================="
echo "[V] CACHYOS THERMAL, POWER PROFILE, & GOD-TIER INTEGRATION COMPILED SUCCESSFULLY!"
echo "Semua script kustom Anda (Terminal, Firefox, Fingerprint, Tweak Daya) telah"
echo "digabung ke dalam 1 arsitektur solid tanpa celah."
echo "Silakan REBOOT perangkat Anda sekarang."
echo "=============================================================================="
