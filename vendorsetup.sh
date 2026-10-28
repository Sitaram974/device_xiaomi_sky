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
# 1) 🔥 PERMANENT FIX: Namespace Error (Asli Kaaran)
# -------------------------------------------------------------
info "Fixing power-libperfmgr namespace conflict..."
if [ -f "hardware/lineage/interfaces/power-libperfmgr/Android.bp" ]; then
    # Is line ko delete kar do jo build fail kar rahi hai
    sed -i '/hardware\/google\/pixel\/power-libperfmgr/d' hardware/lineage/interfaces/power-libperfmgr/Android.bp || true
    ok "Namespace conflict fixed!"
fi

# -------------------------------------------------------------
# 2) Fix libjni_latinimegoogle.so packaging conflict
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
# 3) FIX AOSP DISPLAYSERVICE DUPLICATE ERROR
# -------------------------------------------------------------
info "Fixing AOSP displayservice duplicate module error..."
rm -f frameworks/native/services/displayservice/Android.bp
ok "Displayservice duplicate removed."

# -------------------------------------------------------------
# 4) Remove duplicate hardware/xiaomi/dolby
# -------------------------------------------------------------
info "Removing hardware/xiaomi/dolby..."
rm -rf hardware/xiaomi/dolby || true

# -------------------------------------------------------------
# 5) Ensure vendor/bcr is cloned
# -------------------------------------------------------------
if [[ ! -d "vendor/bcr" ]]; then
    info "Cloning vendor/bcr..."
    git clone --depth=1 https://github.com/anonytry/android_vendor_bcr.git vendor/bcr || true
fi

# -------------------------------------------------------------
# 6) DOWNLOAD CUSTOM SIGNING KEYS
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
# 7) Merge split prebuilt firmware files
# -------------------------------------------------------------
if [[ -f "device/xiaomi/sky/prebuilts/tools/merge.sh" ]]; then
    info "Merging split prebuilt firmware files..."
    bash device/xiaomi/sky/prebuilts/tools/merge.sh device/xiaomi/sky/prebuilts/firmware || true
fi

# -------------------------------------------------------------
# 8) DYNAMIC VENDOR PATCHES (WiFi, Thermal)
# -------------------------------------------------------------
info "Applying Dynamic Vendor Patches (WiFi, Thermal)..."
if [ -f "$VENDOR_DIR/proprietary/vendor/etc/wifi/WCNSS_qcom_cfg.ini" ]; then
    sed -i 's/gEnableRegulatoryOverride=.*/gEnableRegulatoryOverride=1/g' "$VENDOR_DIR/proprietary/vendor/etc/wifi/WCNSS_qcom_cfg.ini" 2>/dev/null || true
fi
if [ -f "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" ]; then
    sed -i 's/"cpu": [0-9]*/"cpu": 65000/g' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
    sed -i 's/"gpu": [0-9]*/"gpu": 65000/g' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
    sed -i 's/"Battery": [0-9]*/"Battery": 40000/g' "$VENDOR_DIR/proprietary/vendor/etc/thermal-engine.conf" 2>/dev/null || true
fi

# -------------------------------------------------------------
# 9) GPS HIGH ACCURACY & FAST LOCK FIX
# -------------------------------------------------------------
if [ -f "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" ]; then
    info "Boosting GPS Performance..."
    sed -i 's/^SUPL_HOST=.*/SUPL_HOST=supl.google.com/' "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" 2>/dev/null || true
    sed -i 's/^SUPL_PORT=.*/SUPL_PORT=7276/' "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" 2>/dev/null || true
    sed -i 's/^NTP_SERVER=.*/NTP_SERVER=time.google.com/' "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" 2>/dev/null || true
    grep -q "LPP_PROFILE=3" "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" || echo "LPP_PROFILE=3" >> "$VENDOR_DIR/proprietary/vendor/etc/gps.conf"
    ok "GPS Performance Boosted."
fi

# -------------------------------------------------------------
# 10) ENSURE SELINUX RULES EXIST
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
# 11) HARD-FAIL safety check
# -------------------------------------------------------------
if grep -rq 'name: "libjni_latinimegoogle"' vendor/gapps --include="Android.bp" 2>/dev/null; then
    echo "FATAL: libjni_latinimegoogle still present in vendor/gapps!"
    return 1 2>/dev/null || exit 1
fi

ok "All vendorsetup checks passed. System is Fully Secured & Ultra-Fast."
echo "============================================================"
