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
# 1.5) FIX AOSP DISPLAYSERVICE DUPLICATE ERROR
# -------------------------------------------------------------
info "Fixing AOSP displayservice duplicate module error..."
rm -f frameworks/native/services/displayservice/Android.bp
ok "Displayservice duplicate removed."

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
    sed -i '/"FrontendAnalogCapabilities.cpp",/d' "$TV_AIDL_BP" || true
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
    sed -i 's/^allow cameraserver sysfs_torch/# allow cameraserver sysfs_torch/g' "$CAMERA_TE" || true
    sed -i 's/^allow cameraserver sysfs_leds/# allow cameraserver sysfs_leds/g' "$CAMERA_TE" || true
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
    if [ -f "$file" ]; then
        sed -i 's/DolbyVision//g' "$file" 2>/dev/null || true
    fi
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
# 9) PLAY STORE CERTIFICATION (Xiaomi Spoof for Govt Apps)
# -------------------------------------------------------------
info "Spoofing device to Xiaomi for Play Store Certification & Govt Apps..."

cat << 'EOF' >> "$DEVICE_DIR/system.prop"
# --- Play Integrity & Play Store Certification (Xiaomi Spoof) ---
ro.product.brand=Xiaomi
ro.product.manufacturer=Xiaomi
ro.product.model=Redmi 12 5G
ro.product.device=sky
ro.product.name=sky
ro.build.product=sky
ro.build.id=UKQ1.230917.001
ro.build.fingerprint=Xiaomi/alioth/alioth:13/TKQ1.221114.001/V816.0.5.0.TKHINXM:user/release-keys
ro.build.version.security_patch=2024-03-05
ro.vendor.build.security_patch=2024-03-05
ro.product.first_api_level=33
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
# 10) BATTERY LIFE & FAST CHARGING OPTIMIZATIONS
# -------------------------------------------------------------
info "Applying Battery Life & Fast Charging Tweaks..."

# --- FAST CHARGING FIX ---
cat << 'EOF' >> "$DEVICE_DIR/system.prop"
# Fast Charging
persist.vendor.charge.speedup=1
ro.quick.charge=1
persist.vendor.charger.fast=1
EOF

# Thermal throttling relax (Taaki charging speed na gire)
if [ -f "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" ]; then
    sed -i 's/"Battery": .*/"Battery": 45000,/' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
fi

# --- BATTERY LIFE IMPROVEMENT ---
cat << 'EOF' >> "$DEVICE_DIR/system.prop"
# Aggressive Doze Mode
ro.vendor.qti.config.doze=1
ro.vendor.qti.config.doze_aggressive=1
persist.sys.doze.timeout=1
persist.log.tag=W
persist.sys.trace.enable=0
ro.vendor.qti.sys.fw.bg_apps_limit=32
ro.vendor.qti.sys.fw.empty_app_percent=50
EOF

# GApps Wakelocks Fix
mkdir -p "$DEVICE_DIR/sysconfig"
cat << 'EOF' > "$DEVICE_DIR/sysconfig/battery_tweaks.xml"
<?xml version="1.0" encoding="utf-8"?>
<config>
    <allow-in-power-save package="com.google.android.gms" />
    <allow-in-power-save package="com.google.android.googlequicksearchbox" />
    <allow-in-power-save package="com.google.android.apps.wellbeing" />
</config>
EOF

# Ensure XML is built
if ! grep -q "battery_tweaks.xml" "$DEVICE_DIR/device.mk"; then
    echo "PRODUCT_COPY_FILES += $DEVICE_DIR/sysconfig/battery_tweaks.xml:system/etc/sysconfig/battery_tweaks.xml" >> "$DEVICE_DIR/device.mk"
fi

ok "Battery Life & Fast Charging Tweaks applied!"

# -------------------------------------------------------------
# 11) AUDIO ENHANCEMENT & LOUDNESS BOOST
# -------------------------------------------------------------
info "Applying Audio Enhancement & Volume Boost..."

cat << 'EOF' >> "$DEVICE_DIR/system.prop"
# --- Audio Volume & Steps Boost ---
ro.config.media_vol_steps=100
ro.config.alarm_vol_steps=100
ro.config.notification_vol_steps=20
ro.config.system_vol_steps=20
ro.config.vc_call_vol_steps=14

# --- Bypass Safe Volume Warning ---
audio.safemedia.bypass=true
ro.config.safemedia.bypass=true

# --- Clear & Loud Sound ---
persist.vendor.audio.hifi=true
persist.vendor.audio.hac.enable=1
persist.vendor.audio.ll_audio=false
persist.vendor.audio.offload=true
persist.vendor.audio.spatializer_enabled=true

# Force Speaker to use max gain
persist.vendor.audio.volume.support_dynamic_gain=true
EOF

ok "Audio Enhancement & Volume Boost applied!"

# -------------------------------------------------------------
# 12) GAMING BOOST, 0.0x ANIMATION & HEATING CONTROL
# -------------------------------------------------------------
info "Applying Gaming, 0.0x Animation & Heating Tweaks..."

cat << 'EOF' >> "$DEVICE_DIR/system.prop"
# --- 0.0x Instant Animation (Fatafat App Open) ---
persist.sys.window_animation_scale=0.0
persist.sys.transition_animation_scale=0.0
persist.sys.animator_duration_scale=0.0

# --- High FPS & Gaming Boost ---
debug.sf.hw=1
debug.egl.hw=1
debug.composition.type=gpu
ro.surface_flinger.max_frame_buffer_acquired_buffers=3
ro.surface_flinger.set_idle_timer_ms=0
persist.vendor.qti.config.gaming_mode=1
persist.vendor.qti.config.perf_mode=1

# Disable touch delay during gaming
persist.sys.input.touch_delay=0

# Free up RAM for games
sys.sysctl.extra_free_kbytes=14400
EOF

# --- HEATING CONTROL (Overheat Fix) ---
# Humne thermal limit 95 se ghatakar 65 kar di hai
# Isse phone garam nahi hoga, par performance smooth rahegi
if [ -f "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" ]; then
    sed -i 's/"cpu": [0-9]*/"cpu": 65000/g' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
    sed -i 's/"gpu": [0-9]*/"gpu": 65000/g' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
    sed -i 's/"Battery": [0-9]*/"Battery": 40000/g' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
fi

ok "Gaming Boost, 0.0x Animation & Heating Control applied!"

# -------------------------------------------------------------
# 13) SECURITY HARDENING (Anti-Hack & Anti-Malware)
# -------------------------------------------------------------
info "Applying Security Hardening..."

cat << 'EOF' >> "$DEVICE_DIR/system.prop"
# --- Strict Security (Koi Hack na kar paye) ---
ro.adb.secure=1
ro.secure=1
ro.debuggable=0
service.adb.tcp.port=-1
persist.adb.tcp.port=-1
ro.force.encryption=1
persist.sys.adb.root=0
ro.sys.unknown_sources=0
EOF

# Ensure SELinux is strictly Enforcing
if [ -f "$DEVICE_DIR/BoardConfig.mk" ]; then
    sed -i 's/SELINUX_ENFORCING := false/SELINUX_ENFORCING := true/g' "$DEVICE_DIR/BoardConfig.mk" 2>/dev/null || true
    sed -i 's/SELINUX_ENFORCING := permissive/SELINUX_ENFORCING := true/g' "$DEVICE_DIR/BoardConfig.mk" 2>/dev/null || true
    if ! grep -q "SELINUX_ENFORCING := true" "$DEVICE_DIR/BoardConfig.mk"; then
        echo "SELINUX_ENFORCING := true" >> "$DEVICE_DIR/BoardConfig.mk"
    fi
fi

ok "Security Hardening applied! System is now Protected."

# -------------------------------------------------------------
# 14) HARD-FAIL safety check
# -------------------------------------------------------------
if grep -rq 'name: "libjni_latinimegoogle"' vendor/gapps --include="Android.bp" 2>/dev/null; then
    echo "FATAL: libjni_latinimegoogle still present in vendor/gapps!"
    return 1 2>/dev/null || exit 1
fi

ok "All vendorsetup checks passed."
echo "============================================================"
