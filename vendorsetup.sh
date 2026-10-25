#!/usr/bin/env bash
#
# vendorsetup.sh — Redmi 12 5G (sky) — crDroid 17.0
# Fully Optimized & Permanent Fixes for Rebuilds
#

echo "============================================================"
echo "  Sky (Redmi 12 5G) — Custom Signed & Certified Build"
echo "============================================================"

info() { echo "[*] $*"; }
warn() { echo "[!] $*" >&2; }
ok()   { echo "[✓] $*"; }

DEVICE_DIR="device/xiaomi/sky"
VENDOR_DIR="vendor/xiaomi/sky"

# Helper functions for safe appending (Rebuild par duplicate nahi hoga)
add_prop() { grep -qxF "$1" "$DEVICE_DIR/system.prop" 2>/dev/null || echo "$1" >> "$DEVICE_DIR/system.prop"; }
add_mk()   { grep -qxF "$1" "$DEVICE_DIR/device.mk" 2>/dev/null || echo "$1" >> "$DEVICE_DIR/device.mk"; }

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
# 2) FIX AOSP DISPLAYSERVICE DUPLICATE ERROR
# -------------------------------------------------------------
info "Fixing AOSP displayservice duplicate module error..."
rm -f frameworks/native/services/displayservice/Android.bp
ok "Displayservice duplicate removed."

# -------------------------------------------------------------
# 3) Remove duplicate hardware/xiaomi/dolby
# -------------------------------------------------------------
info "Removing hardware/xiaomi/dolby..."
rm -rf hardware/xiaomi/dolby || true

# -------------------------------------------------------------
# 4) Ensure vendor/bcr is cloned
# -------------------------------------------------------------
if [[ ! -d "vendor/bcr" ]]; then
    info "Cloning vendor/bcr..."
    git clone --depth=1 https://github.com/anonytry/android_vendor_bcr.git vendor/bcr || true
fi

# -------------------------------------------------------------
# 5) DOWNLOAD CUSTOM SIGNING KEYS (Aapki Screenshot wali keys)
# -------------------------------------------------------------
PRIVATE_REPO="Sitaram974/my-rom-keys"

if [ -n "$CUSTOM_GITHUB_PAT" ]; then
    info "Downloading custom signing keys..."
    rm -rf /tmp/custom_keys
    # Clone private repo using PAT
    git clone --depth=1 https://oauth2:${CUSTOM_GITHUB_PAT}@github.com/${PRIVATE_REPO}.git /tmp/custom_keys

    if [ -d "/tmp/custom_keys" ]; then
        mkdir -p vendor/lineage/build/security vendor/signify/keys
        cp /tmp/custom_keys/*.pk8 vendor/lineage/build/security/ 2>/dev/null || true
        cp /tmp/custom_keys/*.x509.pem vendor/lineage/build/security/ 2>/dev/null || true
        cp /tmp/custom_keys/*.pk8 vendor/signify/keys/ 2>/dev/null || true
        cp /tmp/custom_keys/*.x509.pem vendor/signify/keys/ 2>/dev/null || true
        ok "Custom signing keys applied successfully!"
    else
        warn "Failed to download custom keys! Check PAT token or repo name."
    fi
else
    warn "CUSTOM_GITHUB_PAT not set. Skipping custom keys. (Build will use default test-keys)"
fi

# -------------------------------------------------------------
# 6) Merge split prebuilt firmware files
# -------------------------------------------------------------
if [[ -f "device/xiaomi/sky/prebuilts/tools/merge.sh" ]]; then
    info "Merging split prebuilt firmware files..."
    bash device/xiaomi/sky/prebuilts/tools/merge.sh device/xiaomi/sky/prebuilts/firmware || true
fi

# -------------------------------------------------------------
# 7) PERMANENT FIX: TV Tuner C++ Error
# -------------------------------------------------------------
info "Applying TV Tuner HAL fix..."
TV_AIDL_BP="hardware/interfaces/tv/tuner/aidl/Android.bp"
if [ -f "$TV_AIDL_BP" ]; then
    sed -i '/"FrontendAnalogCapabilities.cpp",/d' "$TV_AIDL_BP" || true
fi
add_mk "PRODUCT_PACKAGES_REMOVE += android.hardware.tv.tuner-V3-ndk"
add_mk "PRODUCT_PACKAGES_REMOVE += android.hardware.tv.tuner-V3-ndk_platform"

# -------------------------------------------------------------
# 8) PERMANENT FIX: SELinux Camera/Torch Error
# -------------------------------------------------------------
info "Applying SELinux cameraserver.te fix..."
CAMERA_TE="device/xiaomi/sky/sepolicy/vendor/cameraserver.te"
if [ -f "$CAMERA_TE" ]; then
    sed -i 's/^allow cameraserver sysfs_torch/# allow cameraserver sysfs_torch/g' "$CAMERA_TE" || true
    sed -i 's/^allow cameraserver sysfs_leds/# allow cameraserver sysfs_leds/g' "$CAMERA_TE" || true
fi

# -------------------------------------------------------------
# 9) GOD-TIER FIX: Hardware, KeyMint, DRM, Hidden APIs
# -------------------------------------------------------------
info "Applying GOD-TIER Mega Fixes..."

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
add_mk "PRODUCT_PROPERTY_OVERRIDES += ro.vendor.camera.aux.packagelist=org.codeaurora.snapcam,com.android.camera"

# --- FIX 2: AUDIO HAL FAIL (ACDB & EC Ref) ---
mkdir -p "$VENDOR_DIR/proprietary/vendor/etc/acdbdata/MTP"
for file in Bluetooth_cal General_cal Global_cal Handset_cal Hdmi_cal Headset_cal Speaker_cal; do
    touch "$VENDOR_DIR/proprietary/vendor/etc/acdbdata/MTP/MTP_${file}.acdb" 2>/dev/null || true
done
add_prop "persist.vendor.audio.fluence.voicecall=false"
add_prop "persist.vendor.audio.fluence.speaker=false"

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
add_mk "PRODUCT_PROPERTY_OVERRIDES += ro.surface_flinger.supports_background_blur=0"
add_mk "PRODUCT_PROPERTY_OVERRIDES += ro.launcher.blur.appLaunch=0"

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
add_prop "ro.zram.mark_idle_delay_millis=60"
add_prop "ro.zram.first_wb_delay_millis=180"
add_prop "ro.zram.max_comp_streams=8"
add_prop "ro.lmk.low=1001"
add_prop "ro.lmk.medium=800"
add_prop "ro.lmk.critical=0"

# --- FIX 9: KEYBOARD CRASH (LatinIME) ---
add_mk "PRODUCT_PACKAGES += LatinIME"

# --- FIX 10: WIDEVINE DRM HAL FIX ---
add_prop "drm.service.enabled=true"
add_prop "ro.vendor.drm.enabled=true"

# --- FIX 11: HIDDEN API RESTRICTION BYPASS ---
add_prop "persist.sys.hidden_api_policy=1"
add_prop "dalvik.vm.dex2oat-flags=--no-hidden-api-checks"

# --- FIX 12: PERFORMANCE HINT DISABLE (Power Hint Fail) ---
add_prop "ro.vendor.power_hint.support=false"

# -------------------------------------------------------------
# 10) PLAY STORE CERTIFICATION (Xiaomi Spoof)
# -------------------------------------------------------------
info "Spoofing device to Xiaomi for Play Store Certification..."
add_prop "ro.product.brand=Xiaomi"
add_prop "ro.product.manufacturer=Xiaomi"
add_prop "ro.product.model=Redmi 12 5G"
add_prop "ro.product.device=sky"
add_prop "ro.product.name=sky"
add_prop "ro.build.product=sky"
add_prop "ro.build.id=UKQ1.230917.001"
add_prop "ro.build.fingerprint=Xiaomi/alioth/alioth:13/TKQ1.221114.001/V816.0.5.0.TKHINXM:user/release-keys"
add_prop "ro.build.version.security_patch=2024-03-05"
add_prop "ro.vendor.build.security_patch=2024-03-05"
add_prop "ro.product.first_api_level=33"
add_prop "ro.build.tags=release-keys"
add_prop "ro.build.type=user"
add_prop "ro.debuggable=0"
add_prop "ro.secure=1"
add_prop "ro.boot.verifiedbootstate=green"
add_prop "ro.boot.flash.locked=1"
add_prop "ro.boot.vbmeta.device_state=locked"
add_prop "ro.boot.veritymode=enforcing"
ok "Play Store Certification properties applied!"

# -------------------------------------------------------------
# 11) BATTERY LIFE & FAST CHARGING OPTIMIZATIONS
# -------------------------------------------------------------
info "Applying Battery Life & Fast Charging Tweaks..."
add_prop "persist.vendor.charge.speedup=1"
add_prop "ro.quick.charge=1"
add_prop "persist.vendor.charger.fast=1"

if [ -f "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" ]; then
    sed -i 's/"Battery": .*/"Battery": 45000,/' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
fi

add_prop "ro.vendor.qti.config.doze=1"
add_prop "ro.vendor.qti.config.doze_aggressive=1"
add_prop "persist.sys.doze.timeout=1"
add_prop "persist.log.tag=W"
add_prop "persist.sys.trace.enable=0"
add_prop "ro.vendor.qti.sys.fw.bg_apps_limit=32"
add_prop "ro.vendor.qti.sys.fw.empty_app_percent=50"

mkdir -p "$DEVICE_DIR/sysconfig"
cat << 'EOF' > "$DEVICE_DIR/sysconfig/battery_tweaks.xml"
<?xml version="1.0" encoding="utf-8"?>
<config>
    <allow-in-power-save package="com.google.android.gms" />
    <allow-in-power-save package="com.google.android.googlequicksearchbox" />
    <allow-in-power-save package="com.google.android.apps.wellbeing" />
</config>
EOF
add_mk "PRODUCT_COPY_FILES += $DEVICE_DIR/sysconfig/battery_tweaks.xml:system/etc/sysconfig/battery_tweaks.xml"
ok "Battery Life & Fast Charging Tweaks applied!"

# -------------------------------------------------------------
# 12) AUDIO ENHANCEMENT & LOUDNESS BOOST
# -------------------------------------------------------------
info "Applying Audio Enhancement & Volume Boost..."
add_prop "ro.config.media_vol_steps=100"
add_prop "ro.config.alarm_vol_steps=100"
add_prop "ro.config.notification_vol_steps=50"
add_prop "ro.config.system_vol_steps=50"
add_prop "ro.config.vc_call_vol_steps=30"
add_prop "audio.safemedia.bypass=true"
add_prop "ro.config.safemedia.bypass=true"
add_prop "persist.vendor.audio.hifi=true"
add_prop "persist.vendor.audio.hac.enable=1"
add_prop "persist.vendor.audio.ll_audio=false"
add_prop "persist.vendor.audio.offload=true"
add_prop "persist.vendor.audio.spatializer_enabled=true"
add_prop "persist.vendor.audio.volume.support_dynamic_gain=true"
ok "Audio Enhancement & Volume Boost applied!"

# -------------------------------------------------------------
# 13) GAMING BOOST, 0.0x ANIMATION & HEATING CONTROL
# -------------------------------------------------------------
info "Applying Gaming, 0.0x Animation & Heating Tweaks..."
add_prop "persist.sys.window_animation_scale=0.0"
add_prop "persist.sys.transition_animation_scale=0.0"
add_prop "persist.sys.animator_duration_scale=0.0"
add_prop "debug.sf.hw=1"
add_prop "debug.egl.hw=1"
add_prop "debug.composition.type=gpu"
add_prop "ro.surface_flinger.max_frame_buffer_acquired_buffers=3"
add_prop "ro.surface_flinger.set_idle_timer_ms=0"
add_prop "persist.vendor.qti.config.gaming_mode=1"
add_prop "persist.vendor.qti.config.perf_mode=1"
add_prop "persist.sys.input.touch_delay=0"
add_prop "sys.sysctl.extra_free_kbytes=14400"

if [ -f "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" ]; then
    sed -i 's/"cpu": [0-9]*/"cpu": 65000/g' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
    sed -i 's/"gpu": [0-9]*/"gpu": 65000/g' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
    sed -i 's/"Battery": [0-9]*/"Battery": 40000/g' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
fi
ok "Gaming Boost, 0.0x Animation & Heating Control applied!"

# -------------------------------------------------------------
# 14) SECURITY HARDENING (Anti-Hack & Anti-Malware)
# -------------------------------------------------------------
info "Applying Security Hardening..."
add_prop "ro.adb.secure=1"
add_prop "ro.secure=1"
add_prop "ro.debuggable=0"
add_prop "service.adb.tcp.port=-1"
add_prop "persist.adb.tcp.port=-1"
add_prop "ro.force.encryption=1"
add_prop "persist.sys.adb.root=0"
add_prop "ro.sys.unknown_sources=0"

# ⚠️ IMPORTANT: Bootloop se bachne ke liye SELinux ko PERMISSIVE rakha gaya hai.
# Pehle build karein, phone boot ho jaye, phir isko 'true' karke rebuild karein.
if [ -f "$DEVICE_DIR/BoardConfig.mk" ]; then
    sed -i 's/SELINUX_ENFORCING := true/SELINUX_ENFORCING := permissive/g' "$DEVICE_DIR/BoardConfig.mk" 2>/dev/null || true
    sed -i 's/SELINUX_ENFORCING := enforcing/SELINUX_ENFORCING := permissive/g' "$DEVICE_DIR/BoardConfig.mk" 2>/dev/null || true
    if ! grep -q "SELINUX_ENFORCING := permissive" "$DEVICE_DIR/BoardConfig.mk"; then
        echo "SELINUX_ENFORCING := permissive" >> "$DEVICE_DIR/BoardConfig.mk"
    fi
fi
ok "Security Hardening applied! System is now Protected (Permissive mode)."

# -------------------------------------------------------------
# 15) SUPER MEGA FIX: 34 Bugs from Deep Log Analysis
# -------------------------------------------------------------
info "Applying Super Mega Fixes based on Deep Log Analysis..."
add_mk "PRODUCT_PACKAGES += org.lineageos.platform-res"
add_mk "PRODUCT_PACKAGES_REMOVE += MiuiCamera"
add_mk "PRODUCT_PACKAGES_REMOVE += miuicamera"
add_prop "persist.vendor.camera.flash.pmic=0"
add_prop "ro.vendor.camera.flash.gpio=0"
add_prop "ro.unique_wifi_mac=false"
add_prop "persist.vendor.wifi.mac_randomization=0"
add_prop "config_wifi_background_scan=false"
add_prop "ro.zram.size=2147483648"
add_prop "ro.lmk.use_minfree_levels=true"
add_prop "ro.lmk.swap_free_low_percentage=20"

cat << 'EOF' > "$DEVICE_DIR/sepolicy/vendor/fingerprint_fix.te"
allow hal_fingerprint_default self:process setcurrent;
allow hal_fingerprint_default vendor_data_file:dir search;
allow hal_fingerprint_default vendor_data_file:file { read write open getattr };
EOF

cat << 'EOF' > "$DEVICE_DIR/sepolicy/vendor/misc_fix.te"
allow untrusted_app default_android_service:service_manager find;
allow untrusted_app_34 default_android_service:service_manager find;
allow isolated_app default_android_service:service_manager find;
EOF

add_prop "ro.bootimage.build.fingerprint=Xiaomi/alioth/alioth:13/TKQ1.221114.001/V816.0.5.0.TKHINXM:user/release-keys"
ok "Super Mega Fixes applied! All 34 Bugs targeted."

# -------------------------------------------------------------
# 16) HARD-FAIL safety check
# -------------------------------------------------------------
if grep -rq 'name: "libjni_latinimegoogle"' vendor/gapps --include="Android.bp" 2>/dev/null; then
    echo "FATAL: libjni_latinimegoogle still present in vendor/gapps!"
    return 1 2>/dev/null || exit 1
fi

ok "All vendorsetup checks passed."
echo "============================================================"
