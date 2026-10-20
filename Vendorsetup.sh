#!/usr/bin/env bash
#
# Clean vendorsetup.sh for Redmi 12 5G (sky) - crDroid 17.0 (Android 17)
# NOTE: All device, vendor, kernel, hardware, camera, dolby, and GApps trees
# are managed cleanly via .repo/local_manifests/crdroid.xml.
# Do NOT delete or git-clone repo-managed paths here (prevents repo sync corruption).
#

echo "==> Cleaning duplicate dolby folder in hardware/xiaomi (if present)..."
rm -rf hardware/xiaomi/dolby

if [[ -f "device/xiaomi/sky/prebuilts/tools/merge.sh" ]]; then
  echo "==> Merging split prebuilt firmware files for sky..."
  bash device/xiaomi/sky/prebuilts/tools/merge.sh device/xiaomi/sky/prebuilts/firmware
fi