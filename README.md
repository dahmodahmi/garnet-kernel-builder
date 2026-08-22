# Garnet Kernel Builder — Poco X6 5G / Redmi Note 13 Pro 5G

Auto-build custom kernel dengan WiFi injection support untuk Kali NetHunter.

## Features

- **WiFi Monitor Mode** (internal QCACLD-3.0)
- **Packet Injection** (internal + USB adapter)
- **TP-Link WN722N V1** (Atheros AR9271 — ath9k_htc)
- **TP-Link WN722N V2/V3** (Realtek RTL8188EUS)
- **RTL88x2BU / RTL88xxAU** support
- **Android 16 / LineageOS 23** compatible
- **BTF/BPF** support (wajib untuk Android 16)

## How to Use

### 1. Fork Repository ini

Klik tombol **Fork** di pojok kanan atas.

### 2. Trigger Build

**Manual:**
1. Tab **Actions** > **Build Kernel Garnet**
2. Klik **Run workflow**
3. Pilih branch kernel (default: `bka`)
4. Klik **Run workflow**

**Automatic:**
Push ke branch `main` akan trigger build otomatis.

### 3. Download Hasil Build

1. Tab **Actions** > klik build yang selesai
2. Scroll ke **Artifacts**
3. Download `Garnet-Kernel-WiFi-Injection.zip`

### 4. Flash ke Device

```
# Copy ZIP ke HP
adb push Garnet-Kernel-WiFi-Injection.zip /sdcard/Download/

# Reboot ke recovery
adb reboot recovery

# Di TWRP/OrangeFox:
# Install > pilih ZIP > Swipe

# Reboot
```

### 5. Test WiFi Injection

```bash
# Monitor mode (internal WiFi)
adb shell su -c 'ip link set wlan0 down'
adb shell su -c 'echo "4" > /sys/module/wlan/parameters/con_mode'
adb shell su -c 'ip link set wlan0 up'

# Test
adb shell su -c 'iw dev wlan0 info'
adb shell su -c 'airodump-ng wlan0'

# USB WiFi adapter
adb shell su -c 'iw dev'
# Lihat wlan1 atau wlan2
adb shell su -c 'airmon-ng start wlan1'
adb shell su -c 'aireplay-ng --test wlan1'
```

## Supported Devices

| Device | Codename | Status |
|--------|----------|--------|
| Poco X6 5G | garnet | ✅ |
| Redmi Note 13 Pro 5G | garnet | ✅ |
| Redmi Note 13 Pro 5G (India) | garnet | ✅ |

## Supported WiFi Adapters

| Adapter | Chipset | Monitor | Injection |
|---------|---------|---------|-----------|
| TP-Link WN722N V1 | Atheros AR9271 | ✅ | ✅ |
| TP-Link WN722N V2/V3 | RTL8188EUS | ✅ | ⚠️ |
| TP-Link TL-WN822N | RTL8188EU | ✅ | ⚠️ |
| Alfa AWUS036ACH | RTL8812AU | ✅ | ✅ |
| Alfa AWUS036ACM | MT7612U | ✅ | ✅ |

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Bootloop | Flash stock boot.img: `fastboot flash boot boot.img` |
| WiFi mati | Cek: `adb shell lsmod \| grep wlan` |
| BTF error | Aktifkan: `CONFIG_DEBUG_INFO_BTF=y` |
| Injection gagal | Cek driver, gunakan adapter yang supported |

## Kernel Source

- **Base Kernel**: [Evolution-X-Devices/kernel_xiaomi_garnet](https://github.com/Evolution-X-Devices/kernel_xiaomi_garnet) (branch: `bka`)
- **WiFi Injection Patches**: [kimocoder/qualcomm_android_monitor_mode](https://github.com/kimocoder/qualcomm_android_monitor_mode)

## Credits

- [Evolution-X-Devices](https://github.com/Evolution-X-Devices) — Evolution X kernel source
- [kimocoder](https://github.com/kimocoder) — QCACLD injection patch
- [osm0sis](https://github.com/osm0sis) — AnyKernel3
- [ZyCromerZ](https://github.com/ZyCromerZ) — Clang toolchain
- Kali NetHunter Team
