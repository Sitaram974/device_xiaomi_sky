#!/usr/bin/env bash
#
# vendorsetup.sh — Redmi 12 5G (sky) — crDroid / LineageOS 17.0 (Android 17)
#

echo "============================================================"
echo "  Sky (Redmi 12 5G) — vendorsetup.sh"
echo "============================================================"

info() { echo "[*] $*"; }
warn() { echo "[!] $*" >&2; }
ok()   { echo "[✓] $*"; }

# -------------------------------------------------------------
# 1) Fix libjni_latinimegoogle.so packaging conflict
# -------------------------------------------------------------
info "Fixing libjni_latinimegoogle.so conflict (GApps vs AOSP LatinIME)..."

python3 - <<'PYEOF'
import pathlib, re, sys
TOKEN = "libjni_latinimegoogle"
ROOT  = pathlib.Path("vendor/gapps")
def strip_module_from_bp(bp_path):
    p = pathlib.Path(bp_path)
    if not p.exists(): return False
    lines = p.read_text().split('\n')
    out, i, removed = [], 0, False
    while i < len(lines):
        s = lines[i].lstrip()
        if s.startswith('cc_prebuilt_library_shared'):
            start, depth, has_token, j = i, 0, False, i
            while j < len(lines):
                depth += lines[j].count('{') - lines[j].count('}')
                if f'name: "{TOKEN}"' in lines[j]: has_token = True
                if j > start and depth <= 0: break
                j += 1
            if has_token:
                removed = True
                i = j + 1
                continue
        out.append(lines[i])
        i += 1
    if removed: p.write_text('\n'.join(out))
    return removed

def strip_token_from_mk(mk_path):
    p = pathlib.Path(mk_path)
    if not p.exists(): return False
    original = p.read_text()
    if TOKEN not in original: return False
    esc = re.escape(TOKEN)
    new = original
    new = re.sub(r'^[ \t]*' + esc + r'[ \t]*\\?[ \t]*\r?\n', '', new, flags=re.MULTILINE)
    new = re.sub(r'^[ \t]*' + esc + r'[ \t]*\\?[ \t]*\Z', '', new, flags=re.MULTILINE)
    new = re.sub(r'[ \t]+' + esc + r'(?=[ \t\\]|\r?$)', '', new, flags=re.MULTILINE)
    if new == original: return False
    p.write_text(new)
    return True

removed_bps, removed_mks = [], []
if ROOT.exists():
    for bp in sorted(ROOT.rglob("Android.bp")):
        if strip_module_from_bp(str(bp)): removed_bps.append(str(bp))
    for mk in sorted(ROOT.rglob("*.mk")):
        try:
            if TOKEN in mk.read_text(errors='ignore'):
                if strip_token_from_mk(str(mk)): removed_mks.append(str(mk))
        except Exception as e: pass
else: print("  [warn] vendor/gapps not found.")
if removed_bps or removed_mks:
    for f in removed_bps: print(f"  [bp] removed module  -> {f}")
    for f in removed_mks: print(f"  [mk] removed token   -> {f}")
PYEOF

info "Verifying libjni fix..."
if grep -rq 'name: "libjni_latinimegoogle"' vendor/gapps --include="Android.bp" 2>/dev/null; then
    warn "libjni_latinimegoogle STILL present in vendor/gapps Android.bp files!"
else
    ok "No libjni_latinimegoogle module in vendor/gapps (fix OK)"
fi

# -------------------------------------------------------------
# 2) Remove duplicate hardware/xiaomi/dolby
# -------------------------------------------------------------
info "Removing hardware/xiaomi/dolby (if present)..."
rm -rf hardware/xiaomi/dolby
ok "dolby cleanup done."

# -------------------------------------------------------------
# 3) Ensure vendor/bcr is cloned
# -------------------------------------------------------------
if [[ ! -d "vendor/bcr" ]]; then
    info "Cloning vendor/bcr..."
    git clone --depth=1 https://github.com/anonytry/android_vendor_bcr.git vendor/bcr \
        || warn "vendor/bcr clone failed (non-fatal)"
fi

# -------------------------------------------------------------
# 4) Run Signify to generate signing keys
# -------------------------------------------------------------
info "Running Signify..."
KEYS_DIR="vendor/signify/keys" SKIP_OTA=true \
    bash <(curl -s https://raw.githubusercontent.com/TopexGuy/Signify/main/signify.sh) --auto \
    || warn "Signify failed (non-fatal)"

# -------------------------------------------------------------
# 5) Merge split prebuilt firmware files
# -------------------------------------------------------------
if [[ -f "device/xiaomi/sky/prebuilts/tools/merge.sh" ]]; then
    info "Merging split prebuilt firmware files for sky..."
    bash device/xiaomi/sky/prebuilts/tools/merge.sh device/xiaomi/sky/prebuilts/firmware \
        || warn "firmware merge failed (non-fatal)"
fi

# -------------------------------------------------------------
# 5.5) PERMANENT FIX: TV Tuner C++ Error (At 67%)
#      Directly removes the problematic file from AOSP source
# -------------------------------------------------------------
info "Applying PERMANENT TV Tuner HAL fix..."
TV_AIDL_BP="hardware/interfaces/tv/tuner/aidl/Android.bp"
if [ -f "$TV_AIDL_BP" ]; then
    # Physically remove the file from the build list
    sed -i '/"FrontendAnalogCapabilities.cpp",/d' "$TV_AIDL_BP"
    ok "Removed FrontendAnalogCapabilities.cpp from $TV_AIDL_BP"
else
    warn "$TV_AIDL_BP not found!"
fi

# Backup: Also add to device.mk just in case
if [ -f "device/xiaomi/sky/device.mk" ]; then
    if ! grep -q "PRODUCT_PACKAGES_REMOVE += android.hardware.tv.tuner" device/xiaomi/sky/device.mk; then
        echo "" >> device/xiaomi/sky/device.mk
        echo "PRODUCT_PACKAGES_REMOVE += android.hardware.tv.tuner-V3-ndk" >> device/xiaomi/sky/device.mk
        echo "PRODUCT_PACKAGES_REMOVE += android.hardware.tv.tuner-V3-ndk_platform" >> device/xiaomi/sky/device.mk
    fi
fi

# -------------------------------------------------------------
# 5.6) PERMANENT FIX: SELinux Camera/Torch Error (sysfs_torch)
#      Android 17 changed/removed sysfs_torch and sysfs_leds
# -------------------------------------------------------------
info "Applying SELinux cameraserver.te fix..."
CAMERA_TE="device/xiaomi/sky/sepolicy/vendor/cameraserver.te"
if [ -f "$CAMERA_TE" ]; then
    # Comment out the failing lines so checkpolicy doesn't crash
    sed -i 's/^allow cameraserver sysfs_torch/# allow cameraserver sysfs_torch/g' "$CAMERA_TE"
    sed -i 's/^allow cameraserver sysfs_leds/# allow cameraserver sysfs_leds/g' "$CAMERA_TE"
    ok "Patched $CAMERA_TE to prevent sysfs_torch error."
else
    warn "$CAMERA_TE not found! Skipping SELinux fix."
fi

# -------------------------------------------------------------
# 6) HARD-FAIL safety check
# -------------------------------------------------------------
if grep -rq 'name: "libjni_latinimegoogle"' vendor/gapps --include="Android.bp" 2>/dev/null; then
    echo "FATAL: libjni_latinimegoogle still present in vendor/gapps!"
    return 1 2>/dev/null || exit 1
fi

ok "All vendorsetup checks passed."
echo "============================================================"
