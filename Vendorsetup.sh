#!/usr/bin/env bash
#
# Clean vendorsetup.sh for Redmi 12 5G (sky) - crDroid 17.0 (Android 17)
# NOTE: All device, vendor, kernel, hardware, camera, dolby, and GApps trees
# are managed cleanly via .repo/local_manifests/crdroid.xml.
#

echo "==> Cleaning duplicate dolby folder in hardware/xiaomi (if present)..."
rm -rf hardware/xiaomi/dolby

echo "==> Fixing libjni_latinimegoogle.so conflict between crDroid LatinIME and MindTheGapps..."
python3 -c '
import pathlib, re
for bp in ["vendor/gapps/arm64/Android.bp", "vendor/gapps/arm/Android.bp"]:
    p = pathlib.Path(bp)
    if p.exists():
        txt = p.read_text()
        txt = re.sub(r"cc_prebuilt_library_shared\s*\{[^{}]*name:\s*\"libjni_latinimegoogle\"[^{}]*(?:\{[^{}]*\}[^{}]*(?:\{[^{}]*\}[^{}]*)*)*\}\s*", "", txt, flags=re.S)
        p.write_text(txt)
for mk in ["vendor/gapps/arm64/arm64-vendor.mk", "vendor/gapps/arm/arm-vendor.mk"]:
    p = pathlib.Path(mk)
    if p.exists():
        txt = re.sub(r"\s*\\\s*\n\s*libjni_latinimegoogle\b", "", p.read_text()).replace("libjni_latinimegoogle", "")
        p.write_text(txt)
' 2>/dev/null || true

if [[ -f "device/xiaomi/sky/prebuilts/tools/merge.sh" ]]; then
  echo "==> Merging split prebuilt firmware files for sky..."
  bash device/xiaomi/sky/prebuilts/tools/merge.sh device/xiaomi/sky/prebuilts/firmware
fi