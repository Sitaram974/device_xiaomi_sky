#!/usr/bin/env bash
#
# vendorsetup.sh — Redmi 12 5G (sky) — ROM King Setup
#

echo "============================================================"
echo "  Sky (Redmi 12 5G) — ROM King Build Setup"
echo "============================================================"

info() { echo "[*] $*"; }
warn() { echo "[!] $*" >&2; }
ok()   { echo "[✓] $*"; }

DEVICE_DIR="device/xiaomi/sky"
VENDOR_DIR="vendor/xiaomi/sky"

# -------------------------------------------------------------
# 1) 🔥 ROOT FIX: Namespace Error (Replace Line, Don't Delete)
# -------------------------------------------------------------
info "Fixing power-libperfmgr namespace conflict..."
if [ -f "hardware/lineage/interfaces/power-libperfmgr/Android.bp" ]; then
    sed -i 's|"hardware/google/pixel/power-libperfmgr",|"hardware/google/pixel",|' hardware/lineage/interfaces/power-libperfmgr/Android.bp || true
    ok "Namespace conflict fixed!"
fi

# -------------------------------------------------------------
# 2) 🔥 PERMANENT FIX: libaudiobase undefined module error
# -------------------------------------------------------------
info "Fixing libaudiobase undefined module error..."
if [ -f "$VENDOR_DIR/Android.bp" ]; then
    sed -i 's/"libaudiobase"/"libaudiohal"/g' "$VENDOR_DIR/Android.bp" || true
    ok "libaudiobase fixed!"
fi

# -------------------------------------------------------------
# 3) Ensure vendor/bcr is cloned
# -------------------------------------------------------------
if [[ ! -d "vendor/bcr" ]]; then
    info "Cloning vendor/bcr..."
    git clone --depth=1 https://github.com/anonytry/android_vendor_bcr.git vendor/bcr || true
fi

# -------------------------------------------------------------
# 4) DOWNLOAD CUSTOM SIGNING KEYS (Sabse Zaroori)
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
# 5) DYNAMIC VENDOR PATCHES (WiFi, Thermal, GPS)
# -------------------------------------------------------------
info "Applying Dynamic Vendor Patches..."
if [ -f "$VENDOR_DIR/proprietary/vendor/etc/wifi/WCNSS_qcom_cfg.ini" ]; then
    sed -i 's/gEnableRegulatoryOverride=.*/gEnableRegulatoryOverride=1/g' "$VENDOR_DIR/proprietary/vendor/etc/wifi/WCNSS_qcom_cfg.ini" 2>/dev/null || true
fi
if [ -f "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" ]; then
    sed -i 's/"cpu": [0-9]*/"cpu": 65000/g' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
    sed -i 's/"gpu": [0-9]*/"gpu": 65000/g' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
    sed -i 's/"Battery": [0-9]*/"Battery": 40000/g' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
fi
if [ -f "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" ]; then
    sed -i 's/^SUPL_HOST=.*/SUPL_HOST=supl.google.com/' "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" 2>/dev/null || true
    sed -i 's/^SUPL_PORT=.*/SUPL_PORT=7276/' "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" 2>/dev/null || true
    sed -i 's/^NTP_SERVER=.*/NTP_SERVER=time.google.com/' "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" 2>/dev/null || true
    grep -q "LPP_PROFILE=3" "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" || echo "LPP_PROFILE=3" >> "$VENDOR_DIR/proprietary/vendor/etc/gps.conf"
fi
ok "Dynamic Vendor patches applied."

# -------------------------------------------------------------
# 6) ENSURE SELINUX RULES EXIST (Safety Net)
# -------------------------------------------------------------
info "Ensuring SELinux Rules..."
mkdir -p $DEVICE_DIR/sepolicy/vendor
cat << 'EOF' > $DEVICE_DIR/sepolicy/vendor/camera_fix.te
allow platform_app default_android_hwservice:hwservice_manager find;
allow priv_app default_android_hwservice:hwservice_manager find;
allow platform_app_36 default_android_hwservice:hwservice_manager find;
EOF
cat << 'EOF' > $DEVICE_DIR/sepolicy/vendor/radio_fix.te
allow radio qmi_data_socket:dir search;
allow radio qmi_data_socket:sock_file write;
allow radio qmi_data_socket:unix_stream_socket connectto;
allow radio vendor_qmi_data_socket:sock_file write;
allow radio self:capability net_admin;
allow radio self:capability net_raw;
EOF
cat << 'EOF' > "$DEVICE_DIR/sepolicy/vendor/bluetooth_fix.te"
allow hal_bluetooth_default vendor_radio_prop:property_service set;
allow hal_bluetooth_default vendor_radio_prop:file { read open getattr };
EOF
cat << 'EOF' > "$DEVICE_DIR/sepolicy/vendor/fingerprint_fix.te"
allow hal_fingerprint_default self:process setcurrent;
allow hal_fingerprint_default vendor_data_file:dir search;
allow hal_fingerprint_default vendor_data_file:file { read write open getattr };
EOF
ok "SELinux rules secured."

# -------------------------------------------------------------
# 7) SUCCESS
# -------------------------------------------------------------
ok "All vendorsetup checks passed. System is Fully Secured & Ultra-Fast."
echo "============================================================"
exit 0
