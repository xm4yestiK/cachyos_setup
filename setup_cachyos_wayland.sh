#!/usr/bin/env bash

# ========================================================================
# WAYLAND OPTIMIZATION & PERSONALIZATION SCRIPT (HYPRLAND)
# Built specifically for: CachyOS x86_64 | DYNAMIC AUTO-DETECT (INTEL & AMD)
#
# CACHYOS INSTALLATION GUIDE (Calamares):
# 1. Select the "No Desktop Environment" (CLI) option if available.
# 2. If forced to choose a DE, select "Hyprland" or "Sway".
# 3. NEVER choose LXQt, XFCE, or Openbox (X11 Bloat).
# 
# [CORE FEATURES]:
# - Full migration from X11 (Openbox) to pure WAYLAND (Hyprland).
# - No SDDM (TTY Autologin goes straight into Hyprland).
# - Waybar + nwg-dock as modern panel & dock without third-party compositors.
# - Root Protection, Auto-backup, Hardware Intelligence, Gecko Tuning, Smart-power.
# ========================================================================

set -e

if [ "$EUID" -eq 0 ]; then
  echo "================================================================="
  echo "[-] FATAL ERROR: DO NOT RUN THIS SCRIPT WITH 'SUDO' OR ROOT!"
  echo "    This script is designed to be run as a Standard User."
  echo "    Please run it again without 'sudo'."
  echo "================================================================="
  exit 1
fi

USER_NAME=$(whoami)

echo "================================================================="
echo "Starting WAYLAND CachyOS Performance Injection (June 2026)..."
echo "                      by m4yestiK"
echo "================================================================="

# ========================================================================
# HARDWARE AUTO-DETECTION (CPU & GPU)
# ========================================================================
echo ">> [PROCESS] Detecting CPU Vendor..."
CPU_VENDOR=$(grep -m 1 'vendor_id' /proc/cpuinfo | awk '{print $3}' || true)
GPU_VENDOR="unknown"

echo ">> [PROCESS] Detecting GPU Vendor (VGA/3D)..."
if lspci -nn | grep -i 'vga\|3d\|display' | grep -iq 'intel'; then
    GPU_VENDOR="intel"
elif lspci -nn | grep -i 'vga\|3d\|display' | grep -iq 'amd\|radeon'; then
    GPU_VENDOR="amd"
fi

echo ">> DETECTED CPU: $CPU_VENDOR"
echo ">> DETECTED GPU: $GPU_VENDOR"
echo "================================================================="

# 1. Update & Install Wayland Stack
echo ""
echo "[1/20] Installing Wayland Ecosystem + Tuning Packages..."
# Securing PGP Keyring from fresh install sync failures
sudo pacman -Sy --noconfirm archlinux-keyring cachyos-keyring || true
sudo pacman -Syu --noconfirm --needed \
    fish hyprland waybar swaybg rofi-wayland mako hyprpolkitagent \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk wireplumber pipewire-pulse pipewire-alsa pipewire-jack \
    ttf-jetbrains-mono-nerd ttf-font-awesome papirus-icon-theme arc-gtk-theme kvantum qterminal fastfetch scx-scheds \
    ananicy-cpp cachyos-ananicy-rules irqbalance auto-cpufreq pacman-contrib \
    network-manager-applet blueman bluez bluez-utils brightnessctl \
    fprintd pavucontrol qt5-wayland qt6-wayland hyprlock hypridle wl-clipboard cliphist grim slurp xdg-user-dirs

# Securing Directory Structure and Font Cache
xdg-user-dirs-update || true
fc-cache -fv >/dev/null 2>&1 || true

# Check for nwg-dock-hyprland (CachyOS/AUR Fallback)
if pacman -Ss nwg-dock-hyprland >/dev/null; then
    sudo pacman -S --noconfirm --needed nwg-dock-hyprland || true
elif command -v paru >/dev/null; then
    paru -S --noconfirm --needed nwg-dock-hyprland || true
elif command -v yay >/dev/null; then
    yay -S --noconfirm --needed nwg-dock-hyprland || true
else
    sudo pacman -S --noconfirm --needed nwg-dock || true
fi

# 2. Setup Shell & Locale
echo ""
echo "[2/20] Setting up Shell & Locale..."
[ "$SHELL" != "/usr/bin/fish" ] && chsh -s /usr/bin/fish || true
sudo sed -i 's/^#id_ID.UTF-8 UTF-8/id_ID.UTF-8 UTF-8/' /etc/locale.gen || true
sudo locale-gen >/dev/null 2>&1 || true
sudo localectl set-locale LANG=id_ID.UTF-8 || true

# 3. TTY Autologin (Killing SDDM)
echo ""
echo "[3/20] Tearing down SDDM & Building TTY Autologin..."
sudo systemctl disable display-manager.service --force 2>/dev/null || true
sudo systemctl disable sddm.service 2>/dev/null || true
sudo systemctl disable lightdm.service 2>/dev/null || true
sudo systemctl disable gdm.service 2>/dev/null || true

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
cat <<EOF | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER_NAME --noclear %I \$TERM
EOF

mkdir -p ~/.config/fish
# Adding automatic Hyprland trigger upon TTY1 login
if ! grep -q "Hyprland" ~/.config/fish/config.fish 2>/dev/null; then
    cat << 'EOF' >> ~/.config/fish/config.fish

# Wayland Autostart (Hyprland) via TTY
if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        # Removing 'exec' so user has a safe fallback to terminal if Hyprland crashes!
        Hyprland
    end
else if status is-interactive
    fastfetch
end
EOF
fi

# 4. Hyprland, Waybar & nwg-dock Config
echo ""
echo "[4/20] Setting up Core Hyprland, Waybar & Dock Configurations..."
mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/rofi

# Inject Waybar Config (Prevent Blank Workspaces due to Sway default)
[ -f ~/.config/waybar/config ] && cp ~/.config/waybar/config ~/.config/waybar/config.bak || true
cat << 'EOF' > ~/.config/waybar/config
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["tray", "network", "pulseaudio", "battery"],
    "hyprland/workspaces": { "format": "{icon}", "on-click": "activate" },
    "clock": { "format": "{:%H:%M - %d %b}" },
    "network": { "format-wifi": "  {essid}", "format-ethernet": "  {ipaddr}", "format-disconnected": "⚠ Disconnected" },
    "battery": { "states": { "warning": 30, "critical": 15 }, "format": "{icon}  {capacity}%", "format-icons": ["", "", "", "", ""] },
    "pulseaudio": { "format": "{icon}  {volume}%", "format-muted": " Muted", "format-icons": { "default": ["", "", ""] } }
}
EOF

# Inject Rofi Config (Prevent ugly GUI)
[ -f ~/.config/rofi/config.rasi ] && cp ~/.config/rofi/config.rasi ~/.config/rofi/config.rasi.bak || true
cat << 'EOF' > ~/.config/rofi/config.rasi
configuration {
    modi: "drun,run";
    show-icons: true;
    font: "JetBrainsMono Nerd Font 12";
}
/* Removed @theme Arc-Dark due to crash risk if theme is missing */
EOF

mkdir -p ~/.config/hypr
# Hyprpaper Block Cleaned (Reverted to Swaybg)

[ -f ~/.config/hypr/hyprland.conf ] && cp ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.bak || true
cat << 'EOF' > ~/.config/hypr/hyprland.conf
# Smart monitor auto-scaling (prevents GUI breakage on 4K/HiDPI monitors)
monitor=,preferred,auto,auto

# Lock Cursor Size (Prevents Giant/Tiny Cursor Bug in Wayland)
env = XCURSOR_SIZE,24
env = XCURSOR_THEME,Adwaita

# Autostart Daemons & Wayland Portal Integration
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
# Using 2026 standard native Hyprland polkit agent
exec-once = systemd-cat -t hyprpolkitagent /usr/lib/hyprpolkitagent
exec-once = swaybg -c "#282a36"
exec-once = waybar
# Separate background processes to prevent zombie processes in Hyprland
exec-once = nm-applet --indicator
exec-once = blueman-applet
exec-once = nwg-dock-hyprland -d -x -p bottom -l top
exec-once = hypridle
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

input {
    kb_layout = us
    touchpad {
        natural_scroll = true
        tap-to-click = true
        disable_while_typing = true
    }
}
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(bd93f9ee) rgba(ff79c6ee) 45deg
    layout = dwindle
}
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
}
animations {
    enabled = yes
}
bind = SUPER, Return, exec, qterminal
bind = SUPER, Q, killactive, 
bind = SUPER, M, exit, 
bind = SUPER, V, togglefloating, 
bind = SUPER, R, exec, rofi -show drun
# Window and Workspace Management (Vital)
bind = SUPER, left, movefocus, l
bind = SUPER, right, movefocus, r
bind = SUPER, up, movefocus, u
bind = SUPER, down, movefocus, d
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
bind = SUPER SHIFT, 3, movetoworkspace, 3
bind = SUPER SHIFT, 4, movetoworkspace, 4

# Media & Brightness Control (Mandatory for Laptops)
bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bindel = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
bindel = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Screenshot (Mandatory for Wayland)
bind = , Print, exec, grim -g "\$(slurp)" - | wl-copy
bind = SHIFT, Print, exec, grim - | wl-copy
EOF

echo ""
echo "[4.5/20] Setting up Screen Security System & GTK Wayland Customization..."
# Hypridle Config
[ -f ~/.config/hypr/hypridle.conf ] && cp ~/.config/hypr/hypridle.conf ~/.config/hypr/hypridle.conf.bak || true
cat << 'EOF' > ~/.config/hypr/hypridle.conf
general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}
listener {
    timeout = 300
    on-timeout = loginctl lock-session
}
listener {
    timeout = 330
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}
EOF

# Hyprlock Config
[ -f ~/.config/hypr/hyprlock.conf ] && cp ~/.config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf.bak || true
cat << 'EOF' > ~/.config/hypr/hyprlock.conf
background {
    monitor =
    color = rgba(40, 42, 54, 1.0)
}
input-field {
    monitor =
    size = 250, 50
    outline_thickness = 3
    dots_size = 0.33
    dots_spacing = 0.15
    dots_center = true
    outer_color = rgb(189, 147, 249)
    inner_color = rgb(40, 42, 54)
    font_color = rgb(248, 248, 242)
    fade_on_empty = true
    placeholder_text = <i>Password...</i>
    hide_input = false
    position = 0, -20
    halign = center
    valign = center
}
label {
    monitor =
    text = $TIME
    color = rgba(248, 248, 242, 1.0)
    font_size = 50
    font_family = JetBrainsMonoNL Nerd Font
    position = 0, 80
    halign = center
    valign = center
}
EOF

# Saving GTK Theme from default Adwaita ugliness
mkdir -p ~/.config/gtk-3.0
cat << 'EOF' > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=JetBrainsMono Nerd Font 10
gtk-cursor-theme-name=Adwaita
gtk-application-prefer-dark-theme=1
EOF

# Saving QT Theme with Kvantum Arc-Dark
mkdir -p ~/.config/Kvantum
cat << 'EOF' > ~/.config/Kvantum/kvantum.kvconfig
[General]
theme=KvArcDark#
EOF

# 5. QTerminal Dracula Purple
echo ""
echo "[5/20] Injecting Dracula Purple Color Scheme for QTerminal..."
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
mkdir -p ~/.config/qterminal.org
[ -f ~/.config/qterminal.org/qterminal.ini ] && cp ~/.config/qterminal.org/qterminal.ini ~/.config/qterminal.org/qterminal.ini.bak || true
cat <<EOF > ~/.config/qterminal.org/qterminal.ini
[General]
fontFamily=JetBrainsMonoNL Nerd Font Mono
fontSize=14
colorScheme=DraculaPurple
EOF

# 6. Fingerprint Integration (PAM)
echo ""
echo "[6/20] Registering Fingerprint (fprintd) into TTY PAM module..."
if [ -f /etc/pam.d/system-local-login ] && ! grep -q "pam_fprintd.so" /etc/pam.d/system-local-login; then
    sudo sed -i '1iauth      sufficient  pam_fprintd.so' /etc/pam.d/system-local-login || true
fi

# 7. Firefox Optimization Integration
echo ""
echo "[7/20] Injecting Max Tuning for Gecko Engine..."
killall -9 firefox cachy-browser 2>/dev/null || true
sleep 0.5
command -v firefox >/dev/null && firefox --headless -CreateProfile "default" 2>/dev/null || true
command -v cachy-browser >/dev/null && cachy-browser --headless -CreateProfile "default" 2>/dev/null || true
for PROFILE_DIR in ~/.mozilla/firefox/*.default* ~/.cachy/cachy-browser/*.default* ~/.config/mozilla/firefox/*.default*; do
    if [ -d "$PROFILE_DIR" ]; then
        [ -f "$PROFILE_DIR/user.js" ] && cp "$PROFILE_DIR/user.js" "$PROFILE_DIR/user.js.bak" || true
        cat << 'EOF' > "$PROFILE_DIR/user.js"
user_pref("gfx.webrender.all", true);
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("gfx.canvas.accelerated", true);
user_pref("network.http.http3.enable", true);
user_pref("network.http.max-connections", 1800);
EOF
    fi
done

# 8. Kernel Sysctl
echo ""
echo "[8/20] Kernel Sysctl (Zero Latency & TCP BBRv3)..."
sudo mkdir -p /etc/sysctl.d
cat <<EOF | sudo tee /etc/sysctl.d/99-cachyos-optimized.conf
vm.swappiness=150
vm.page-cluster=0
vm.watermark_boost_factor=20000
vm.watermark_scale_factor=250
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_low_latency=1
kernel.split_lock_mitigate=0
EOF
sudo sysctl --system || true

# 9. MGLRU & THP
echo ""
echo "[9/20] Forcibly Enabling MGLRU & THP..."
sudo mkdir -p /etc/tmpfiles.d
cat <<EOF | sudo tee /etc/tmpfiles.d/mglru-thp.conf
w /sys/kernel/mm/lru_gen/enabled - - - - 1
w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise
EOF

# 10. AUTO-CPUFREQ
echo ""
echo "[10/20] AUTO-CPUFREQ: Smart Power Management Brain..."
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

# 11. iGPU Driver
echo ""
echo "[11/20] Executing iGPU Driver..."
sudo mkdir -p /etc/modprobe.d
if [ "$GPU_VENDOR" = "intel" ]; then
    cat <<EOF | sudo tee /etc/modprobe.d/gpu-optimized.conf
options i915 enable_guc=3 enable_fbc=1 enable_psr=1
EOF
elif [ "$GPU_VENDOR" = "amd" ]; then
    cat <<EOF | sudo tee /etc/modprobe.d/gpu-optimized.conf
options amdgpu ppfeaturemask=0xffffffff
EOF
fi

# 12. Wayland Environment Variables
echo ""
echo "[12/20] Injecting Wayland-Specific Environment Variables..."
sudo mkdir -p /etc/profile.d
cat <<EOF | sudo tee /etc/profile.d/wayland-optimized.sh
export MESA_NO_ERROR=1
export MOZ_ENABLE_WAYLAND=1
export LIBVA_DRIVER_NAME=iHD
export ELECTRON_OZONE_PLATFORM_HINT=auto
export MOZ_USE_XINPUT2=1
export QT_QPA_PLATFORM="wayland;xcb"
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_STYLE_OVERRIDE=kvantum
export QT_QPA_PLATFORMTHEME=kvantum
export XCURSOR_SIZE=24
export XCURSOR_THEME=Adwaita
export GDK_BACKEND="wayland,x11"
export SDL_VIDEODRIVER="wayland,x11"
export XDG_SESSION_TYPE=wayland
EOF

# 13. FSTAB Optimization
echo ""
echo "[13/20] FSTAB Optimization..."
if [ -f /etc/fstab ]; then
    sudo cp /etc/fstab /etc/fstab.optimized.backup || true
    sudo sed -i 's/relatime/noatime,commit=60/g' /etc/fstab || true
fi

# 14. SSD UDEV Rules
echo ""
echo "[14/20] UDEV Rules: SSD/NVMe I/O Scheduler -> 'kyber'..."
sudo mkdir -p /etc/udev/rules.d
cat <<EOF | sudo tee /etc/udev/rules.d/60-ioschedulers.rules
ACTION=="add|change", KERNEL=="nvme[0-9]*|sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
EOF

# 15. Absolute Shutdown Cleanup Module
echo ""
echo "[15/20] Building Shutdown Cleanup Module..."
sudo mkdir -p /usr/local/bin
cat <<'EOF' | sudo tee /usr/local/bin/shutdown-cleanup.sh
#!/bin/bash
# Remove pacman cache (keep last 2 versions)
paccache -r -k2 || true
# Remove AUR (Yay/Paru) cache that piles up insanely
rm -rf /home/*/.cache/yay/* /home/*/.cache/paru/* 2>/dev/null || true
# Remove orphaned packages
pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || true
# Clean systemd logs older than 3 days
journalctl --vacuum-time=3d || true
# Execute TRIM on SSD
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

# 16. Critical Boot Parameters
echo ""
echo "[16/20] Injecting Critical Boot Parameters (mitigations=off)..."
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
            sudo sed -i "s/^\(options[[:space:]].*\)/\1 $BOOT_PARAMS/" "$entry"
        fi
    done
    shopt -u nullglob
elif [ -f /etc/kernel/cmdline ]; then
    if ! grep -q "mitigations=off" /etc/kernel/cmdline; then
        sudo sed -i "s/$/ $BOOT_PARAMS/" /etc/kernel/cmdline
        sudo sdboot-manage gen || sudo bootctl update || true
    fi
elif [ -f /etc/default/grub ]; then
    if ! grep -q "mitigations=off" /etc/default/grub; then
        sudo sed -i "s/^\(GRUB_CMDLINE_LINUX_DEFAULT=[\"']\)/\1$BOOT_PARAMS /" /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg || true
    fi
fi

# 17. Daemon Execution
echo ""
echo "[17/20] Executing Daemons & Eliminating Power Conflicts..."
sudo systemctl daemon-reload
sudo systemctl disable --now power-profiles-daemon.service tlp.service 2>/dev/null || true
sudo systemctl mask power-profiles-daemon.service tlp.service 2>/dev/null || true
sudo systemctl disable --now cpupower.service 2>/dev/null || true

sudo systemctl enable --now ananicy-cpp.service || true
sudo systemctl enable --now irqbalance.service || true
sudo systemctl enable --now auto-cpufreq.service || true
sudo systemctl enable shutdown-cleanup.service || true
sudo systemctl enable systemd-tmpfiles-setup.service || true
sudo systemctl enable --now bluetooth.service || true
sudo sed -i 's/^#AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf || true
sudo sed -i 's/^#AutoEnable=true/AutoEnable=true/' /etc/bluetooth/main.conf || true
sudo timedatectl set-ntp true || true

if [ -f /etc/default/scx ]; then
    sudo sed -i 's/^SCX_SCHEDULER=.*/SCX_SCHEDULER="scx_lavd"/' /etc/default/scx
else
    sudo mkdir -p /etc/default
    echo 'SCX_SCHEDULER="scx_lavd"' | sudo tee /etc/default/scx
fi
sudo systemctl enable --now scx.service || true

# 18. Rebuild Initramfs
echo ""
echo "[18/20] Rebuilding Initramfs (Universal)..."
if command -v mkinitcpio &> /dev/null; then
    sudo mkinitcpio -P || true
fi
if command -v dracut &> /dev/null; then
    sudo dracut --force --regenerate-all || true
fi

echo ""
echo "=============================================================================="
echo "[V] TRANSITION TO WAYLAND (HYPRLAND) COMPLETED SUCCESSFULLY!"
echo "SDDM has been disabled. When you reboot, the machine will auto-login at TTY1"
echo "and go straight into Hyprland + Waybar + nwg-dock without a GUI Login."
echo "Please REBOOT your device now."
echo "=============================================================================="
