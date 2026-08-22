# Flash Guide — Garnet WiFi Injection Kernel

## Prasyarat

- Bootloader sudah unlock
- TWRP / OrangeFox recovery terinstall
- Backup boot.img stock (WAJIB!)

## Cara 1: Flash via Recovery (Recommended)

```
# 1. Download ZIP dari GitHub Actions Artifact
#    File: Garnet-Kernel-WiFi-Injection.zip

# 2. Push ke HP
adb push Garnet-Kernel-WiFi-Injection.zip /sdcard/Download/

# 3. Reboot ke recovery
adb reboot recovery

# 4. Di TWRP/OrangeFox:
#    Install > pilih Garnet-Kernel-WiFi-Injection.zip > Swipe

# 5. Reboot System
```

## Cara 2: Flash via Magisk

```
# 1. Extract Image.gz dari ZIP
unzip Garnet-Kernel-WiFi-Injection.zip Image.gz

# 2. Push ke HP
adb push Image.gz /sdcard/Download/

# 3. Buka Magisk App
#    Install > Install from Storage > pilih Image.gz

# 4. Reboot
```

## Cara 3: Flash via Fastboot

```
# 1. Boot ke fastboot
adb reboot bootloader

# 2. Flash kernel
fastboot flash init_boot Image.gz

# 3. Reboot
fastboot reboot
```

## Backup & Restore

### Backup Stock Boot:
```
adb shell su -c 'dd if=/dev/block/by-name/init_boot of=/sdcard/Download/init_boot_stock.img'
adb pull /sdcard/Download/init_boot_stock.img .
```

### Restore Stock Boot (jika bootloop):
```
adb reboot bootloader
fastboot flash init_boot init_boot_stock.img
fastboot reboot
```

## Test WiFi Injection

### Setelah Flash & Reboot:

```bash
# Cek kernel version
adb shell uname -r

# === Monitor Mode (Internal WiFi) ===
adb shell su -c 'ip link set wlan0 down'
adb shell su -c 'echo "4" > /sys/module/wlan/parameters/con_mode'
adb shell su -c 'ip link set wlan0 up'

# Test monitor mode
adb shell su -c 'iw dev wlan0 info'
# Harusnya: type monitor

# Test capture
adb shell su -c 'airodump-ng wlan0'

# === USB WiFi Adapter ===
# 1. Plug adapter via OTG
adb shell su -c 'iw dev'
# Cek wlan1 atau wlan2

# 2. Monitor mode
adb shell su -c 'ip link set wlan1 down'
adb shell su -c 'airmon-ng check kill'
adb shell su -c 'airmon-ng start wlan1'

# 3. Test injection
adb shell su -c 'aireplay-ng --test wlan1'

# === Stop Monitor Mode ===
adb shell su -c 'iw dev wlan1 set type managed'
adb shell su -c 'ip link set wlan1 up'
```

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Bootloop | Flash stock init_boot.img via fastboot |
| WiFi tidak jalan | Reboot, cek `lsmod \| grep wlan` |
| Monitor mode gagal | Pastikan `con_mode=4` |
| Injection gagal | Cek driver, restart adapter |
| USB adapter tidak detect | Cek OTG, cek `lsusb` |
| BTF error | Pastikan `CONFIG_DEBUG_INFO_BTF=y` |

## WhatsApp/Telegram Group

Join komunitas garnet:
- Telegram: @garnet_updates
- Telegram: @garnet_community
