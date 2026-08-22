#!/bin/bash
set -e

# ============================================
# Garnet Kernel Builder — Local Build Script
# Poco X6 5G / Redmi Note 13 Pro 5G
# WiFi Injection Support
# ============================================

KERNEL_SRC="https://github.com/garnet-random/android_kernel_xiaomi_sm7435.git"
KERNEL_BRANCH="lineage-23"
CLANG_URL="https://github.com/ZyCromerZ/Clang/releases/download/23.0.0git-20260130-release/Clang-23.0.0git-20260130.tar.gz"

echo "============================================"
echo "  Garnet Kernel Builder — WiFi Injection"
echo "============================================"
echo ""

# Step 1: Check dependencies
echo "[1/8] Checking dependencies..."
for cmd in git curl wget make gcc python3; do
  if ! command -v $cmd &> /dev/null; then
    echo "ERROR: $cmd not found!"
    echo "Install: sudo apt install build-essential git curl wget python3"
    exit 1
  fi
done
echo "✅ Dependencies OK"

# Step 2: Setup workspace
echo ""
echo "[2/8] Setting up workspace..."
WORKDIR=$(pwd)/garnet-kernel-builder
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Step 3: Install Clang
echo ""
echo "[3/8] Installing Clang toolchain..."
if [ ! -d "toolchains/clang/bin" ]; then
  mkdir -p toolchains
  cd toolchains
  wget -q "$CLANG_URL" -O Clang.tar.gz
  tar -xzf Clang.tar.gz
  chmod +x clang/bin/*
  rm Clang.tar.gz
  cd "$WORKDIR"
  echo "✅ Clang installed"
else
  echo "✅ Clang already installed"
fi

export PATH="$WORKDIR/toolchains/clang/bin:$PATH"

# Step 4: Clone kernel source
echo ""
echo "[4/8] Cloning kernel source..."
if [ ! -d "kernel" ]; then
  git clone --depth=1 -b "$KERNEL_BRANCH" "$KERNEL_SRC" kernel
  echo "✅ Kernel source cloned"
else
  echo "✅ Kernel source exists"
fi

# Step 5: Download WiFi injection patches
echo ""
echo "[5/8] Downloading WiFi injection patches..."
if [ ! -d "patches" ]; then
  git clone --depth=1 https://github.com/kimocoder/qualcomm_android_monitor_mode.git patches
  echo "✅ Patches downloaded"
else
  echo "✅ Patches exist"
fi

# Step 6: Apply patches
echo ""
echo "[6/8] Applying WiFi injection patches..."
cd kernel
QCACLD_DIR=$(find . -type d -name "qcacld-3*" 2>/dev/null | head -1)
if [ -n "$QCACLD_DIR" ] && [ -d "../patches/patches" ]; then
  cp -r ../patches/patches/* "$QCACLD_DIR/" 2>/dev/null || true
  echo "✅ Patches applied to $QCACLD_DIR"
else
  echo "⚠️  QCACLD-3.0 not found, skipping patch"
fi
cd "$WORKDIR"

# Step 7: Configure kernel
echo ""
echo "[7/8] Configuring kernel..."
cd kernel
make ARCH=arm64 clean
make ARCH=arm64 mrproper

DEFCONFIG=$(ls arch/arm64/configs/ | grep -iE "garnet|monet" | head -1)
if [ -z "$DEFCONFIG" ]; then
  echo "⚠️  No garnet defconfig found, using defconfig"
  make ARCH=arm64 defconfig
else
  echo "Using defconfig: $DEFCONFIG"
  make ARCH=arm64 "$DEFCONFIG"
fi

# Add WiFi configs
cat >> .config << 'EOF'

# WiFi Injection Support
CONFIG_MAC80211=y
CONFIG_CFG80211=y
CONFIG_CFG80211_WEXT=y
CONFIG_DEBUG_INFO_BTF=y
CONFIG_DEBUG_INFO_BTF_MODULES=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
EOF

make ARCH=arm64 olddefconfig
cd "$WORKDIR"

# Step 8: Build kernel
echo ""
echo "[8/8] Building kernel..."
cd kernel
make -j$(nproc) \
  ARCH=arm64 \
  CC=clang \
  CROSS_COMPILE=aarch64-linux-gnu- \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  Image.gz 2>&1 | tee ../build.log

if [ -f arch/arm64/boot/Image.gz ]; then
  echo ""
  echo "============================================"
  echo "  ✅ BUILD SUCCESSFUL!"
  echo "============================================"
  echo "  Image: $WORKDIR/kernel/arch/arm64/boot/Image.gz"
  echo "  Size: $(ls -lh arch/arm64/boot/Image.gz | awk '{print $5}')"
  echo ""
  echo "  Next: Flash via AnyKernel3 or Magisk"
  echo "============================================"
else
  echo ""
  echo "============================================"
  echo "  ❌ BUILD FAILED!"
  echo "  Check: $WORKDIR/build.log"
  echo "============================================"
  exit 1
fi

cd "$WORKDIR"
