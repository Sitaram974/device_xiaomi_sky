#!/usr/bin/env bash
#
# vendorsetup.sh — Redmi 12 5G (sky) — crDroid 17.0
#

echo "============================================================"
echo "  Sky (Redmi 12 5G) — Custom Signed & Certified Build"
echo "============================================================"

info() { echo "[*] $*"; }
warn() { echo "[!] $*" >&2; }
ok()   { echo "[✓] $*"; }

# -------------------------------------------------------------
# 1) Fix libjni_latinimegoogle.so packaging conflict
# -------------------------------------------------------------
info "Fixing libjni_latinimegoogle.so conflict..."
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
                removed = True; i = j + 1; continue
        out.append(lines[i]); i += 1
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
    p.write_text(new); return True
if ROOT.exists():
    for bp in sorted(ROOT.rglob("Android.bp")):
        strip_module_from_bp(str(bp))
    for mk in sorted(ROOT.rglob("*.mk")):
        try:
            if TOKEN in mk.read_text(errors='ignore'): strip_token_from_mk(str(mk))
        except Exception: pass
PYEOF

# -------------------------------------------------------------
# 2) Remove duplicate hardware/xiaomi/dolby
# -------------------------------------------------------------
info "Removing hardware/xiaomi/dolby..."
rm -rf hardware/xiaomi/dolby

# -------------------------------------------------------------
# 3) Ensure vendor/bcr is cloned
# -------------------------------------------------------------
if [[ ! -d "vendor/bcr" ]]; then
    info "Cloning vendor/bcr..."
    git clone --depth=1 https://github.com/anonytry/android_vendor_bcr.git vendor/bcr || true
fi

# -------------------------------------------------------------
# 4) DOWNLOAD CUSTOM SIGNING KEYS
# -------------------------------------------------------------
PRIVATE_REPO="Sitaram974/my-rom-keys"

if [ -n "$CUSTOM_GITHUB_PAT" ]; then
    info "Downloading custom signing keys..."
    rm -rf /tmp/custom_keys
    git clone --depth=1 https://oauth2:${CUSTOM_GITHUB_PAT}@github.com/${PRIVATE_REPO}.git /tmp/custom_keys

    if [ -d "/tmp/custom_keys" ]; then
        mkdir -p vendor/lineage/build/security vendor/signify/keys
        cp /tmp/custom_keys/*.pk8 vendor/lineage/build/security/ 2>/dev/null || true
        cp /tmp/custom_keys/*.x509.pem vendor/lineage/build/security/ 2>/dev/null || true
        cp /tmp/custom_keys/*.pk8 vendor/signify/keys/ 2>/dev/null || true
        cp /tmp/custom_keys/*.x509.pem vendor/signify/keys/ 2>/dev/null || true
        ok "Custom signing keys applied successfully!"
    else
        warn "Failed to download custom keys! Check git error above."
    fi
else
    warn "CUSTOM_GITHUB_PAT not set. Skipping custom keys."
fi

# -------------------------------------------------------------
# 5) Merge split prebuilt firmware files
# -------------------------------------------------------------
if [[ -f "device/xiaomi/sky/prebuilts/tools/merge.sh" ]]; then
    info "Merging split prebuilt firmware files..."
    bash device/xiaomi/sky/prebuilts/tools/merge.sh device/xiaomi/sky/prebuilts/firmware || true
fi

# -------------------------------------------------------------
# 6) PERMANENT FIX: TV Tuner C++ Error (At 67%)
# -------------------------------------------------------------
info "Applying TV Tuner HAL fix..."
TV_AIDL_BP="hardware/interfaces/tv/tuner/aidl/Android.bp"
if [ -f "$TV_AIDL_BP" ]; then
    sed -i '/"FrontendAnalogCapabilities.cpp",/d' "$TV_AIDL_BP"
fi
if [ -f "device/xiaomi/sky/device.mk" ]; then
    if ! grep -q "PRODUCT_PACKAGES_REMOVE += android.hardware.tv.tuner" device/xiaomi/sky/device.mk; then
        echo "" >> device/xiaomi/sky/device.mk
        echo "PRODUCT_PACKAGES_REMOVE += android.hardware.tv.tuner-V3-ndk" >> device/xiaomi/sky/device.mk
        echo "PRODUCT_PACKAGES_REMOVE += android.hardware.tv.tuner-V3-ndk_platform" >> device/xiaomi/sky/device.mk
    fi
fi

# -------------------------------------------------------------
# 7) PERMANENT FIX: SELinux Camera/Torch Error (sysfs_torch)
# -------------------------------------------------------------
info "Applying SELinux cameraserver.te fix..."
CAMERA_TE="device/xiaomi/sky/sepolicy/vendor/cameraserver.te"
if [ -f "$CAMERA_TE" ]; then
    sed -i 's/^allow cameraserver sysfs_torch/# allow cameraserver sysfs_torch/g' "$CAMERA_TE"
    sed -i 's/^allow cameraserver sysfs_leds/# allow cameraserver sysfs_leds/g' "$CAMERA_TE"
fi

# -------------------------------------------------------------
# 8) GOD-TIER FIX: Hardware, KeyMint, DRM, Hidden APIs
# -------------------------------------------------------------
info "Applying GOD-TIER Mega Fixes..."

DEVICE_DIR="device/xiaomi/sky"
VENDOR_DIR="vendor/xiaomi/sky"

# --- FIX 1: CAMERA CRASH (Flashlight & Dolby) ---
mkdir -p $DEVICE_DIR/sepolicy/vendor
cat << 'EOF' > $DEVICE_DIR/sepolicy/vendor/camera_fix.te
allow platform_app default_android_hwservice:hwservice_manager find;
allow untrusted_app default_android_hwservice:hwservice_manager find;
allow priv_app default_android_hwservice:hwservice_manager find;
allow platform_app_36 default_android_hwservice:hwservice_manager find;
EOF
for file in "device/xiaomi/miuicamera-sky/Android.mk" "$DEVICE_DIR/device.mk"; do
    [ -f "$file" ] && sed -i 's/DolbyVision//g' "$file" 2>/dev/null || true
done
echo "PRODUCT_PROPERTY_OVERRIDES += ro.vendor.camera.aux.packagelist=org.codeaurora.snapcam,com.android.camera" >> "$DEVICE_DIR/device.mk"

# --- FIX 2: AUDIO HAL FAIL (ACDB & EC Ref) ---
mkdir -p "$VENDOR_DIR/proprietary/vendor/etc/acdbdata/MTP"
for file in Bluetooth_cal General_cal Global_cal Handset_cal Hdmi_cal Headset_cal Speaker_cal; do
    touch "$VENDOR_DIR/proprietary/vendor/etc/acdbdata/MTP/MTP_${file}.acdb" 2>/dev/null || true
done
echo "persist.vendor.audio.fluence.voicecall=false" >> "$DEVICE_DIR/system.prop"
echo "persist.vendor.audio.fluence.speaker=false" >> "$DEVICE_DIR/system.prop"

# --- FIX 3: NETWORK DROP (RIL & IMS SELinux) ---
cat << 'EOF' > $DEVICE_DIR/sepolicy/vendor/radio_fix.te
allow radio qmi_data_socket:dir search;
allow radio qmi_data_socket:sock_file write;
allow radio qmi_data_socket:unix_stream_socket connectto;
allow radio vendor_qmi_data_socket:sock_file write;
allow radio self:capability net_admin;
allow radio self:capability net_raw;
EOF

# --- FIX 4: UI LAG & BLUR CHOREOGRAPHER ---
echo "PRODUCT_PROPERTY_OVERRIDES += ro.surface_flinger.supports_background_blur=0" >> $DEVICE_DIR/device.mk
echo "PRODUCT_PROPERTY_OVERRIDES += ro.launcher.blur.appLaunch=0" >> $DEVICE_DIR/device.mk

# --- FIX 5: WIFI REGULATORY (Country Code 5GHz Fix) ---
if [ -f "$VENDOR_DIR/proprietary/vendor/etc/wifi/WCNSS_qcom_cfg.ini" ]; then
    sed -i 's/gEnableRegulatoryOverride=.*/gEnableRegulatoryOverride=1/g' "$VENDOR_DIR/proprietary/vendor/etc/wifi/WCNSS_qcom_cfg.ini" 2>/dev/null || true
fi

# --- FIX 6: BLUETOOTH MAC SELINUX ---
cat << 'EOF' > "$DEVICE_DIR/sepolicy/vendor/bluetooth_fix.te"
allow hal_bluetooth_default vendor_radio_prop:property_service set;
allow hal_bluetooth_default vendor_radio_prop:file { read open getattr };
allow untrusted_app vendor_radio_prop:file { read open getattr };
EOF

# --- FIX 7: TOUCHSCREEN FIRMWARE ---
mkdir -p "$VENDOR_DIR/proprietary/vendor/firmware"
find "$VENDOR_DIR" -name "focaltech_ts_fw_.bin" -exec cp {} "$VENDOR_DIR/proprietary/vendor/firmware/" \; 2>/dev/null || true

# --- FIX 8: LOW MEMORY KILLER (ZRAM & LMK Tuning) ---
echo "ro.zram.mark_idle_delay_millis=60" >> "$DEVICE_DIR/system.prop"
echo "ro.zram.first_wb_delay_millis=180" >> "$DEVICE_DIR/system.prop"
echo "ro.zram.max_comp_streams=8" >> "$DEVICE_DIR/system.prop"
echo "ro.lmk.low=1001" >> "$DEVICE_DIR/system.prop"
echo "ro.lmk.medium=800" >> "$DEVICE_DIR/system.prop"
echo "ro.lmk.critical=0" >> "$DEVICE_DIR/system.prop"

# --- FIX 9: KEYBOARD CRASH (LatinIME) ---
if ! grep -q "PRODUCT_PACKAGES += LatinIME" "$DEVICE_DIR/device.mk"; then
    echo "PRODUCT_PACKAGES += LatinIME" >> "$DEVICE_DIR/device.mk"
fi

# --- FIX 10: WIDEVINE DRM HAL FIX ---
echo "drm.service.enabled=true" >> "$DEVICE_DIR/system.prop"
echo "ro.vendor.drm.enabled=true" >> "$DEVICE_DIR/system.prop"

# --- FIX 11: HIDDEN API RESTRICTION BYPASS ---
echo "persist.sys.hidden_api_policy=1" >> "$DEVICE_DIR/system.prop"
echo "dalvik.vm.dex2oat-flags=--no-hidden-api-checks" >> "$DEVICE_DIR/system.prop"

# --- FIX 12: PERFORMANCE HINT DISABLE (Power Hint Fail) ---
echo "ro.vendor.power_hint.support=false" >> "$DEVICE_DIR/system.prop"

# -------------------------------------------------------------
# 9) PLAY STORE CERTIFICATION (Spoof Pixel 8 Pro)
# -------------------------------------------------------------
info "Spoofing device to Google Pixel 8 Pro for Play Store Certification..."

# In properties ko daalne se Play Store samjhega ki yeh ek original Google phone hai.
# Isse Play Integrity pass hogi aur banking apps block nahi hongi.
cat << 'EOF' >> "$DEVICE_DIR/system.prop"
# --- Play Integrity & Play Store Certification ---
ro.product.brand=google
ro.product.manufacturer=Google
ro.product.model=Pixel 8 Pro
ro.product.device=husky
ro.product.name=husky
ro.build.product=husky
ro.build.id=AP1A.240305.019.A1
ro.build.fingerprint=google/husky/husky:14/AP1A.240305.019.A1/11445699:user/release-keys
ro.build.version.security_patch=2024-03-05
ro.vendor.build.security_patch=2024-03-05
ro.product.first_api_level=34
ro.build.tags=release-keys
ro.build.type=user
ro.debuggable=0
ro.secure=1
ro.boot.verifiedbootstate=green
ro.boot.flash.locked=1
ro.boot.vbmeta.device_state=locked
ro.boot.veritymode=enforcing
EOF

ok "Play Store Certification properties applied!"

# -------------------------------------------------------------
# 10) HARD-FAIL safety check
# -------------------------------------------------------------
if grep -rq 'name: "libjni_latinimegoogle"' vendor/gapps --include="Android.bp" 2>/dev/null; then
    echo "FATAL: libjni_latinimegoogle still present in vendor/gapps!"
    return 1 2>/dev/null || exit 1
fi

ok "All vendorsetup checks passed."
echo "============================================================"
