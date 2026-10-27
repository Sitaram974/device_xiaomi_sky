# GPS High Accuracy & Fast Lock Fix (Vendor Level)
if [ -f "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" ]; then
    info "Boosting GPS Performance..."
    sed -i 's/^SUPL_HOST=.*/SUPL_HOST=supl.google.com/' "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" 2>/dev/null || true
    sed -i 's/^SUPL_PORT=.*/SUPL_PORT=7276/' "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" 2>/dev/null || true
    sed -i 's/^NTP_SERVER=.*/NTP_SERVER=time.google.com/' "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" 2>/dev/null || true
    # Force High Accuracy LPP Profile
    grep -q "LPP_PROFILE=3" "$VENDOR_DIR/proprietary/vendor/etc/gps.conf" || echo "LPP_PROFILE=3" >> "$VENDOR_DIR/proprietary/vendor/etc/gps.conf"
fi
