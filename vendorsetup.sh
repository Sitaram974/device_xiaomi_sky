#!/usr/bin/env bash
#
# vendorsetup.sh — Redmi 12 5G (sky) — crDroid / LineageOS 17.0 (Android 17)
#
# Runs automatically on `lunch` / `breakfast lineage_sky`.
# All steps are idempotent — safe to run on every build.
#
# Steps:
#   1. Fix libjni_latinimegoogle.so packaging conflict (AOSP LatinIME vs GApps)
#   2. Remove duplicate hardware/xiaomi/dolby (use hardware/dolby instead)
#   3. Ensure vendor/bcr (Basic Call Recorder) is cloned
#   4. Run Signify to generate signing keys
#   5. Merge split prebuilt firmware files (dsp.img, modem.img)
#   6. HARD-FAIL check: abort build if libjni fix did not apply
#

echo "============================================================"
echo "  Sky (Redmi 12 5G) — vendorsetup.sh"
echo "============================================================"

info() { echo "[*] $*"; }
warn() { echo "[!] $*" >&2; }
ok()   { echo "[✓] $*"; }

# -------------------------------------------------------------
# 1) Fix libjni_latinimegoogle.so packaging conflict
#    Cause: AOSP LatinIME and GApps both install the same .so
#           to /product/lib{64}/libjni_latinimegoogle.so.
#    Fix:   Strip the GApps prebuilt module + its PRODUCT_PACKAGES
#           reference so only the AOSP-built copy is packaged.
# -------------------------------------------------------------
info "Fixing libjni_latinimegoogle.so conflict (GApps vs AOSP LatinIME)..."

python3 - <<'PYEOF'
import pathlib, re, sys

TOKEN = "libjni_latinimegoogle"
ROOT  = pathlib.Path("vendor/gapps")


def strip_module_from_bp(bp_path):
    """Remove the cc_prebuilt_library_shared module providing TOKEN."""
    p = pathlib.Path(bp_path)
    if not p.exists():
        return False
    lines = p.read_text().split('\n')
    out, i, removed = [], 0, False
    while i < len(lines):
        s = lines[i].lstrip()
        if s.startswith('cc_prebuilt_library_shared'):
            start, depth, has_token, j = i, 0, False, i
            while j < len(lines):
                depth += lines[j].count('{') - lines[j].count('}')
                if f'name: "{TOKEN}"' in lines[j]:
                    has_token = True
                if j > start and depth <= 0:
                    break
                j += 1
            if has_token:
                removed = True
                i = j + 1
                continue
        out.append(lines[i])
        i += 1
    if removed:
        p.write_text('\n'.join(out))
    return removed


def strip_token_from_mk(mk_path):
    """Remove TOKEN references from a makefile PRODUCT_PACKAGES list."""
    p = pathlib.Path(mk_path)
    if not p.exists():
        return False
    original = p.read_text()
    if TOKEN not in original:
        return False
    esc = re.escape(TOKEN)
    new = original
    new = re.sub(r'^[ \t]*' + esc + r'[ \t]*\\?[ \t]*\r?\n', '', new, flags=re.MULTILINE)
    new = re.sub(r'^[ \t]*' + esc + r'[ \t]*\\?[ \t]*\Z', '', new, flags=re.MULTILINE)
    new = re.sub(r'[ \t]+' + esc + r'(?=[ \t\\]|\r?$)', '', new, flags=re.MULTILINE)
    if new == original:
        return False
    p.write_text(new)
    return True


removed_bps, removed_mks = [], []

if ROOT.exists():
    for bp in sorted(ROOT.rglob("Android.bp")):
        if strip_module_from_bp(str(bp)):
            removed_bps.append(str(bp))
    for mk in sorted(ROOT.rglob("*.mk")):
        try:
            if TOKEN in mk.read_text(errors='ignore'):
                if strip_token_from_mk(str(mk)):
                    removed_mks.append(str(mk))
        except Exception as e:
            print(f"  [warn] {mk}: {e}", file=sys.stderr)
else:
    print(f"  [warn] {ROOT} does not exist, skipping libjni fix.", file=sys.stderr)

if removed_bps or removed_mks:
    for f in removed_bps:
        print(f"  [bp] removed module  -> {f}")
    for f in removed_mks:
        print(f"  [mk] removed token   -> {f}")
else:
    print("  [warn] No libjni_latinimegoogle reference was removed.")
    print("         If build still fails with packaging conflict, inspect vendor/gapps manually.")
PYEOF

# Verify
info "Verifying libjni fix..."
if grep -rq 'name: "libjni_latinimegoogle"' vendor/gapps --include="Android.bp" 2>/dev/null; then
    warn "libjni_latinimegoogle STILL present in vendor/gapps Android.bp files:"
    grep -rn 'name: "libjni_latinimegoogle"' vendor/gapps --include="Android.bp" 2>/dev/null | head -5
else
    ok "No libjni_latinimegoogle module in vendor/gapps (fix OK)"
fi

# -------------------------------------------------------------
# 2) Remove duplicate hardware/xiaomi/dolby
#    Only hardware/dolby should be used on this device.
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
else
    info "vendor/bcr already present, skipping clone."
fi

# -------------------------------------------------------------
# 4) Run Signify to generate signing keys
# -------------------------------------------------------------
info "Running Signify..."
KEYS_DIR="vendor/signify/keys" \
SKIP_OTA=true \
    bash <(curl -s https://raw.githubusercontent.com/TopexGuy/Signify/main/signify.sh) --auto \
    || warn "Signify failed (non-fatal)"

# -------------------------------------------------------------
# 5) Merge split prebuilt firmware files
# -------------------------------------------------------------
if [[ -f "device/xiaomi/sky/prebuilts/tools/merge.sh" ]]; then
    info "Merging split prebuilt firmware files for sky..."
    bash device/xiaomi/sky/prebuilts/tools/merge.sh device/xiaomi/sky/prebuilts/firmware \
        || warn "firmware merge failed (non-fatal)"
else
    info "firmware merge.sh not found, skipping."
fi

# -------------------------------------------------------------
# 6) HARD-FAIL safety check
#    If libjni_latinimegoogle is still present, ninja will fail
#    later with a confusing "packaging conflict" error.
#    Abort early with a clear message instead.
# -------------------------------------------------------------
if grep -rq 'name: "libjni_latinimegoogle"' vendor/gapps --include="Android.bp" 2>/dev/null; then
    echo ""
    echo "############################################################"
    echo "# FATAL: libjni_latinimegoogle still present in vendor/gapps!"
    echo "# Build would fail with soong packaging conflict at:"
    echo "#   product/lib*/libjni_latinimegoogle.so"
    echo "#"
    echo "# Fix vendorsetup.sh before proceeding."
    echo "# Manual check:"
    echo "#   grep -rn 'libjni_latinimegoogle' vendor/gapps"
    echo "############################################################"
    echo ""
    # Return non-zero from sourced script (lunch aborts)
    return 1 2>/dev/null || exit 1
fi

ok "All vendorsetup checks passed."
echo "============================================================"
