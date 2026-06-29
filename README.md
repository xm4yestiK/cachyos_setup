# CachyOS Wayland Setup (Hyprland Edition)

A comprehensive installation, personalization, and optimization script for CachyOS. Designed specifically for users who want to achieve absolute peak performance by completely abandoning the legacy X11 protocol and transitioning to a **Pure Wayland Ecosystem (Hyprland)**.

## Key Features

This script is engineered to create the absolute balance between zero-latency performance, premium aesthetics, and laptop battery life:

1. **Pure Hyprland & TTY Autologin (Zero RAM Login)**
   - Heavy Display Managers (like SDDM or GDM) are **permanently disabled**.
   - The laptop will automatically log in via a black TTY and instantly drop into a Hyprland session using a *Fish Shell* injection. This saves up to 100MB of RAM.

2. **Modern Panel & Dock (No Extra Compositors)**
   - Utilizes **Waybar** (smart panel with WiFi/Battery detection) and **nwg-dock-hyprland** as the primary navigation.
   - The script automatically patches Waybar's built-in "Blank Workspace" bug to ensure perfect communication between Waybar and Hyprland.

3. **Hybrid Smart Power & Idle Security (Battery Protection)**
   - Automatically managed by `auto-cpufreq` (Turbo Auto when plugged in, Powersave without turbo on battery).
   - The screen automatically dims when left idle, and the system locks aggressively with **Hyprlock** & **Hypridle** before suspending, preventing privacy leaks in public spaces.

4. **Media Integration & Wayland Portals (Anti-Freeze)**
   - All laptop *Media Keys* (Brightness, Volume, Mute) are forcibly bound through Hyprland keybinds.
   - Injects **XDG Desktop Portals** and the **DBus** daemon. Guarantees no Flatpak apps or screen sharing (Discord/OBS) will crash or freeze your screen.

5. **UI Protection (Consistent Aesthetics)**
   - Forces specific variables so Qt applications (like QTerminal) do not draw double borders (*Double Titlebar Bug*).
   - Injects the standard `Arc-Dark` theme and `Papirus` icons into GTK modules, ensuring no apps (like Audio Settings) revert to the legacy white Adwaita theme.
   - Fixes Wayland's clipboard using `wl-clipboard` and `cliphist` so copied text is never lost when an application closes.

6. **Centralized Kernel & Gecko Engine Tuning**
   - Implements TCP BBRv3, *Transparent Huge Pages* (THP), *MGLRU*, `kyber` SSD I/O Scheduler, and aggressive memory latency tuning.
   - Injects 25+ custom parameters into the Firefox / Cachy-Browser profile even if the browser has never been opened (*headless generation*).

7. **Automated Garbage Collector (Absolute Shutdown Cleanup)**
   - A custom systemd module runs every time you shut down the laptop, ensuring pacman cache, orphaned packages, and old journals are automatically deleted, concluding with an *fstrim*.

## Strict Warnings

- **Root-Blocker:** NEVER run this script using `sudo bash`. This script has a built-in root detector and will self-terminate. It is designed to be run as a standard *user* (it will elegantly request your `sudo` password within the terminal).
- This script is intended for a **Fresh Install** of CachyOS (or a relatively new system) to avoid extensive configuration conflicts. The script's built-in auto-backup system (`.bak`) will attempt to save your old configurations if found.

## OS Installation Guide (Calamares)

To ensure this script works with maximum cleanliness (bloat-free), please follow these instructions when installing CachyOS from a USB drive (Calamares Installer):

1. **The Ultimate Path (Recommended):** 
   Select the **"No Desktop Environment"**, **"Minimal/CLI"**, or **"Base System Only"** option (if available). This installs a pure system without a graphical interface. This script will build the Hyprland interface from scratch.
2. **The Standard Path (Alternative):**
   If the installer forces you to select a Desktop Environment, choose **Hyprland** or **Sway**. This script will overwrite its configurations to a premium version and kill its default SDDM.
3. **Absolute Warning:**
   **NEVER** select LXQt, KDE Plasma (X11), XFCE, or Openbox. Choosing them means polluting your system with legacy packages (`xorg-server`) which will ultimately be forcefully disabled by this script.

## Execution Guide

Run the following commands in your terminal:

```bash
cd ~/Scripts/CACHYOS_SETUP
chmod +x setup_cachyos_wayland.sh
./setup_cachyos_wayland.sh
```

After the terminal log states the installation is successful (Stage 20), please *Reboot* your machine. Do not panic if you don't see the SDDM screen. The TTY terminal will flash briefly and take you straight into the Wayland Desktop of the future.
