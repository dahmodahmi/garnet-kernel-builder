# AnyKernel3 Ramdisk Mod Script
# Kernel: Garnet WiFi Injection Kernel
# AnyKernel Setup
# import anykernel/anykernel.sh; do.devicecheck=1; do.modules=1;
# import anykernel/anykernel.sh; do.clean=0; do.cleanuponabort=0;
# device.name1=garnet;
# device.name2=monet;
# device.name3=;
# do.sleep=1;
# import anykernel/anykernel.sh; do.clean=0;

# shell variables
is_slot_device=1
block=auto
device.name1=garnet
device.name2=monet
do.devicecheck=1
do.cleanuponabort=0
do.modules=1
do.systemless=1
patch_vbmeta=1

propertiesucked() { }

# AnyKernel install
case $1 in
  post-patch)
    # Mount partitions
    mount -o rw,remount /system 2>/dev/null
    mount -o rw,remount /vendor 2>/dev/null

    # Backup original boot
    backup_file init_boot.img

    # Flash kernel
    flash_part init_boot Image.gz

    # Copy modules (if any)
    if [ -d $patch/system/lib/modules ]; then
      cp -rf $patch/system/lib/modules/* /vendor/lib/modules/ 2>/dev/null
    fi
    if [ -d $patch/vendor/lib/modules ]; then
      cp -rf $patch/vendor/lib/modules/* /vendor/lib/modules/ 2>/dev/null
    fi

    # Fix permissions
    set_perm_recursive 0 0 0755 0644 $patch/system/lib/modules
    set_perm_recursive 0 0 0755 0644 $patch/vendor/lib/modules

    # Set permissions for modules
    find $patch/system/lib/modules -name '*.ko' -exec chmod 0644 {} \;
    find $patch/vendor/lib/modules -name '*.ko' -exec chmod 0644 {} \;

    # WiFi injection configs
    ui_print "  - Applying WiFi injection configs..."

    # Enable monitor mode
    if [ -f /sys/module/wlan/parameters/con_mode ]; then
      echo "4" > /sys/module/wlan/parameters/con_mode
      ui_print "  - Monitor mode enabled"
    fi

    # Remount
    mount -o ro,remount /system 2>/dev/null
    mount -o ro,remount /vendor 2>/dev/null
  ;;

  post-install)
    ui_print ""
    ui_print "============================================"
    ui_print "  Garnet WiFi Injection Kernel"
    ui_print "============================================"
    ui_print "  Device: Poco X6 5G / Redmi Note 13 Pro 5G"
    ui_print "  Features:"
    ui_print "    - QCACLD-3.0 Monitor Mode"
    ui_print "    - Packet Injection"
    ui_print "    - TP-Link WN722N V1 (ath9k_htc)"
    ui_print "    - TP-Link WN722N V2/V3 (RTL8188EU)"
    ui_print "    - RTL88x2BU / RTL88xxAU"
    ui_print "    - Android 16 BTF/BPF"
    ui_print "============================================"
    ui_print ""
  ;;

  post-unpatch)
    ui_print "  - Kernel unpatched"
  ;;
esac
