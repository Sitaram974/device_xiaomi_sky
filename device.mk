#
# Copyright (C) 2023 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/sky

# Inherit virtual_ab_ota_product.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Installs gsi keys into ramdisk, to boot a developer GSI with verified boot.
$(call inherit-product, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)

# Enforce generic ramdisk allow list
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Call the proprietary setup.
$(call inherit-product, vendor/xiaomi/sky/sky-vendor.mk)

# Add common definitions for Qualcomm
$(call inherit-product, hardware/qcom-caf/common/common.mk)

# Project ID Quota.
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

TARGET_SUPPORTS_OMX_SERVICE := false
QCV_FAMILY_SKUS := parrot ravelin

# Disable VINTF Kernel Check
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

# AAPT
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# ART
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true
DONT_DEXPREOPT_PREBUILTS := true

# Audio
SOONG_CONFIG_NAMESPACES += android_hardware_audio
SOONG_CONFIG_android_hardware_audio += run_64bit
SOONG_CONFIG_android_hardware_audio_run_64bit := true

PRODUCT_PACKAGES += \
    android.hardware.audio@7.0-impl:64 \
    android.hardware.audio.effect@7.0-impl:64 \
    android.hardware.audio.service \
    android.hardware.soundtrigger@2.3-impl:64 \
    vendor.qti.hardware.AGMIPC@1.0-service

PRODUCT_PACKAGES += \
    audio.bluetooth.default:64 \
    audio.primary.parrot:64 \
    audio.r_submix.default:64 \
    audio.usb.default:64 \
    sound_trigger.primary.parrot:64

PRODUCT_PACKAGES += \
    audioadsprpcd

PRODUCT_PACKAGES += \
    lib_bt_aptx:64 \
    lib_bt_ble:64 \
    lib_bt_bundle:64 \
    libagm_compress_plugin:64 \
    libagm_mixer_plugin:64 \
    libagm_pcm_plugin:64 \
    libbatterylistener:64 \
    libfmpal:64 \
    libpalclient:64 \
    libqcompostprocbundle:64 \
    libqcomvisualizer:64 \
    libqcomvoiceprocessing:64 \
    libvolumelistener:64

PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration_7_0.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.audio.pro.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.pro.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

PRODUCT_COPY_FILES += \
    hardware/qcom-caf/sm8450/audio/primary-hal/configs/common/codec2/media_codecs_c2_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_c2_audio.xml \
    hardware/qcom-caf/sm8450/audio/primary-hal/configs/common/codec2/service/1.0/c2audio.vendor.base-arm64.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/c2audio.vendor.base-arm64.policy \
    hardware/qcom-caf/sm8450/audio/primary-hal/configs/common/codec2/service/1.0/c2audio.vendor.ext-arm64.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/c2audio.vendor.ext-arm64.policy \
    hardware/qcom-caf/sm8450/audio/primary-hal/configs/parrot/card-defs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/card-defs.xml \
    hardware/qcom-caf/sm8450/audio/primary-hal/configs/parrot/microphone_characteristics.xml:$(TARGET_COPY_OUT_VENDOR)/etc/microphone_characteristics.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_ravelin/audio_effects.xml \
    $(LOCAL_PATH)/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_ravelin/audio_policy_configuration.xml \
    $(LOCAL_PATH)/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_ravelin_qssi/audio_policy_configuration.xml \
    $(LOCAL_PATH)/configs/audio/mixer_paths_ravelin_qrd.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_ravelin/mixer_paths_ravelin_qrd.xml \
    $(LOCAL_PATH)/configs/audio/resourcemanager_ravelin_qrd.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_ravelin/resourcemanager_ravelin_qrd.xml \
    $(LOCAL_PATH)/configs/audio/usecaseKvManager.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usecaseKvManager.xml

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth.audio-impl:64

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml

# Boot animation
TARGET_BOOT_ANIMATION_RES := 1080

# Boot control
PRODUCT_PACKAGES += \
    android.hardware.boot-service.qti \
    android.hardware.boot-service.qti.recovery

# Camera & MIUI Camera (sky)
$(call inherit-product-if-exists, device/xiaomi/miuicamera-sky/device.mk)
$(call inherit-product-if-exists, vendor/xiaomi/miuicamera-sky/miuicamera-vendor.mk)

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
# but also allow explicit overriding for testing and development.
SYSTEM_OPTIMIZE_JAVA := true
SYSTEMUI_OPTIMIZE_JAVA := true

# Device Settings
PRODUCT_PACKAGES += \
    XiaomiParts

PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.lcd.cabc_mode=1

# Display
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@4.0-impl-qti-display \
    vendor.qti.hardware.display.allocator-service \
    vendor.qti.hardware.display.composer-service

PRODUCT_PACKAGES += \
    init.qti.display_boot.rc \
    init.qti.display_boot.sh

PRODUCT_COPY_FILES += \
    hardware/qcom-caf/sm8450/display/config/snapdragon_color_libs_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/snapdragon_color_libs_config.xml

# Dolby
$(call inherit-product-if-exists, hardware/dolby/dolby.mk)

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm-service.clearkey

# Debloat
PRODUCT_PACKAGES += \
    RemovePackagesSky

# Fastbootd
PRODUCT_PACKAGES += \
    fastbootd

# Fingerprint
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint-service.xiaomi

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml

# FM
PRODUCT_PACKAGES += \
    FM2 \
    qcom.fmradio

# GPS
PRODUCT_PACKAGES += \
    android.hardware.gnss@2.1-impl-qti:64 \
    android.hardware.gnss-aidl-impl-qti:64 \
    android.hardware.gnss-aidl-service-qti

PRODUCT_PACKAGES += \
    libbatching:64 \
    libgeofencing:64 \
    libgnss:64

PRODUCT_PACKAGES += \
    apdr.conf \
    batching.conf \
    gnss_antenna_info.conf \
    gps.conf \
    izat.conf \
    lowi.conf \
    sap.conf

PRODUCT_PACKAGES += \
    gnss@2.0-base.policy \
    gnss@2.0-xtra-daemon.policy

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute-0.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-1.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_1.xml \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2021-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml \
    frameworks/native/data/etc/android.software.vulkan.deqp.level-2021-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml

# Health
PRODUCT_PACKAGES += \
    android.hardware.health-service.qti \
    android.hardware.health-service.qti_recovery

# Hotword Enrollement
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/privapp-permissions-hotword.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp-permissions-hotword.xml

# Input
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/idc/uinput-fpc.idc:$(TARGET_COPY_OUT_SYSTEM)/usr/idc/uinput-fpc.idc \
    $(DEVICE_PATH)/configs/idc/uinput-goodix.idc:$(TARGET_COPY_OUT_SYSTEM)/usr/idc/uinput-goodix.idc \
    $(DEVICE_PATH)/configs/keylayout/uinput-fpc.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/uinput-fpc.kl \
    $(DEVICE_PATH)/configs/keylayout/uinput-goodix.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/uinput-goodix.kl

# IPACM
PRODUCT_PACKAGES += \
    ipacm \
    IPACM_cfg.xml \
    IPACM_Filter_cfg.xml

# IR
PRODUCT_PACKAGES += \
    android.hardware.ir-service.lineage

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.consumerir.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.consumerir.xml

# Keymaster
PRODUCT_PACKAGES += \
    android.hardware.keymaster@4.1.vendor \
    libkeymaster_messages.vendor

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.keystore.app_attest_key.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.keystore.app_attest_key.xml

# Lineage Health
PRODUCT_PACKAGES += \
    vendor.lineage.health-service.default

$(call soong_config_set_bool,lineage_health,charging_control_supports_bypass,false)
$(call soong_config_set,lineage_health,charging_control_charging_path,/sys/class/qcom-battery/input_suspend)
$(call soong_config_set,lineage_health,charging_control_charging_enabled,0)
$(call soong_config_set,lineage_health,charging_control_charging_disabled,1)

# Logging
SPAMMY_LOG_TAGS := \
    AiAiEcho \
    MiStcImpl \
    SDM \
    SDM-histogram \
    SRE \
    WifiHAL \
    cnss-daemon \
    libsensor-displayalgo \
    libsensor-parseRGB \
    libsensor-ssccalapi \
    sensors \
    sensors-hal \
    vendor.qti.hardware.display.composer-service \

ifneq ($(TARGET_BUILD_VARIANT),eng)
PRODUCT_VENDOR_PROPERTIES += \
    $(foreach tag,$(SPAMMY_LOG_TAGS),log.tag.$(tag)=E)
endif

# NFC
PRODUCT_PACKAGES += \
    android.hardware.nfc-service.nxp \
    com.android.nfc_extras

NFC_SKUS := sku_hcesim sku_hcesim1 sku_hcesim1ese sku_hcesimese sku_hceese
PRODUCT_COPY_FILES += $(foreach sku,$(NFC_SKUS), \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/$(sku)/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/$(sku)/android.hardware.nfc.hcef.xml \
    frameworks/native/data/etc/android.hardware.nfc.uicc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/$(sku)/android.hardware.nfc.uicc.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/$(sku)/android.hardware.nfc.xml \
    frameworks/native/data/etc/com.android.nfc_extras.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/$(sku)/com.android.nfc_extras.xml \
    frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/$(sku)/com.nxp.mifare.xml)

PRODUCT_COPY_FILES += $(foreach sku,sku_hcesim1ese sku_hcesimese sku_hceese, \
    frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/$(sku)/android.hardware.nfc.ese.xml)

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml

# Media
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/media/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media/media_codecs.xml \
    $(LOCAL_PATH)/configs/media/media_codecs_c2_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media/media_codecs_c2_audio.xml \
    $(LOCAL_PATH)/configs/media/media_codecs_ravelin.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media/media_codecs_ravelin.xml \
    $(LOCAL_PATH)/configs/media/media_profiles.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media/media_profiles.xml \
    $(LOCAL_PATH)/configs/media/media_profiles_ravelin.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media/media_profiles_ravelin.xml \
    $(LOCAL_PATH)/configs/media/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media/media_profiles_V1_0.xml

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/overlay-lineage

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Partitions
PRODUCT_PACKAGES += \
    vendor_bt_firmware_mountpoint \
    vendor_dsp_mountpoint \
    vendor_firmware_mnt_mountpoint

# Power
PRODUCT_PACKAGES += \
    android.hardware.power-service.lineage-libperfmgr \
    libqti-perfd-client

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

# Properties
PRODUCT_PACKAGES += \
    sky_sku_properties

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88018AA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88018AA1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88018EA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88018EA1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88018OA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88018OA1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88018PA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88018PA1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88018XA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88018XA1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88019BA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88019BA1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88019BP1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88019BP1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88019EA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88019EA1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88019EP1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88019EP1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88019KA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88019KA1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88019OA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88019OA1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88019TA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88019TA1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88029AA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88029AA1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88029EA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88029EA1.prop \
    $(LOCAL_PATH)/configs/properties/vendor_sku/build_S88029JA1.prop:$(TARGET_COPY_OUT_VENDOR)/build_S88029JA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88018AA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88018AA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88018EA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88018EA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88018OA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88018OA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88018PA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88018PA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88018XA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88018XA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88019BA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88019BA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88019BP1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88019BP1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88019EA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88019EA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88019EP1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88019EP1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88019KA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88019KA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88019OA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88019OA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88019TA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88019TA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88029AA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88029AA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88029EA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88029EA1.prop \
    $(LOCAL_PATH)/configs/properties/product_sku/build_S88029JA1.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/build_S88029JA1.prop

# Rootdir
PRODUCT_PACKAGES += \
    charger_fw_fstab.qti \
    fstab.default \
    init.class_main.sh \
    init.kernel.post_boot.sh \
    init.sky.rc \
    init.qcom.class_core.sh \
    init.qcom.early_boot.sh \
    init.qcom.post_boot.sh \
    init.qcom.rc \
    init.qcom.sh \
    init.target.rc \
    ueventd.qcom.rc \
    ueventd-odm.rc

# RRO Overlays
PRODUCT_PACKAGES += \
    CarrierConfigRes \
    FrameworksResCommon \
    FrameworksResTarget \
    LauncherOverlayTarget \
    SettingsProviderCommon \
    SettingsProviderRedmi125G \
    SettingsProviderPocoM6Pro5G \
    SettingsProviderRedmi12R \
    SettingsProviderRedmiNote12R \
    SettingsResCommon \
    SystemUIResCommon \
    TelephonyResCommon \
    WifiResCommon \
    WifiResTarget \
    WifiOverlayRedmi125G \
    WifiOverlayPocoM6Pro \
    WifiOverlayRedmi12R \
    WifiOverlayRedmiNote12R

# Secure element
PRODUCT_COPY_FILES += $(foreach sku,sku_hceese sku_hcesim1ese sku_hcesimese, \
    frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/$(sku)/android.hardware.se.omapi.ese.xml)

PRODUCT_COPY_FILES += $(foreach sku,sku_hceese sku_hcesim sku_hcesim1 sku_hcesim1ese sku_hcesimese, \
    frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/$(sku)/android.hardware.se.omapi.uicc.xml)

# Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensors-service.xiaomi-multihal

# Shim
PRODUCT_PACKAGES += \
    libmisightjson_shim

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/sku_ravelin/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/sku_ravelin/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/sku_ravelin/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/sku_ravelin/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/sku_ravelin/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/sku_ravelin/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/sku_ravelin/android.hardware.sensor.stepdetector.xml

# SHIPPING API
PRODUCT_SHIPPING_API_LEVEL := 33

# Soong namespaces
# 🔥 FIXED: Removed hardware/google/pixel/power-libperfmgr to fix build error
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH) \
    hardware/lineage/interfaces/power-libperfmgr \
    hardware/google \
    hardware/google/interfaces \
    hardware/google/pixel/pixelstats \
    hardware/qcom-caf/common/libqti-perfd-client \
    hardware/xiaomi

# Task Profiles
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/task_profiles.json:$(TARGET_COPY_OUT_VENDOR)/etc/task_profiles.json \
    $(LOCAL_PATH)/configs/cgroups.json:$(TARGET_COPY_OUT_VENDOR)/etc/cgroups.json

# Telephony
PRODUCT_PACKAGES += \
    extphonelib \
    extphonelib-product \
    extphonelib.xml \
    extphonelib_product.xml \
    ims-ext-common \
    ims_ext_common.xml \
    qti-telephony-hidl-wrapper \
    qti-telephony-hidl-wrapper-prd \
    qti_telephony_hidl_wrapper.xml \
    qti_telephony_hidl_wrapper_prd.xml \
    qti-telephony-utils \
    qti-telephony-utils-prd \
    qti_telephony_utils.xml \
    qti_telephony_utils_prd.xml \
    telephony-ext \
    xiaomi-telephony-stub

PRODUCT_PACKAGES += \
    qcrilNrDb_vendor

PRODUCT_BOOT_JARS += \
    telephony-ext \
    xiaomi-telephony-stub

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.cdma.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.cdma.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal-service.qti

# Touchscreen
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml

# Update engine
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

# USB
PRODUCT_PACKAGES += \
    android.hardware.usb-service.qti \
    android.hardware.usb.gadget-service.qti

PRODUCT_PACKAGES += \
    init.qcom.usb.rc \
    init.qcom.usb.sh \
    usb_compositions.conf

PRODUCT_SOONG_NAMESPACES += vendor/qcom/opensource/usb/etc

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml

# VENDOR API
BOARD_SHIPPING_API_LEVEL := 31

# Vendor service manager
PRODUCT_PACKAGES += \
    vndservicemanager

# Verified boot
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml

# Vibrator
PRODUCT_PACKAGES += \
    vendor.qti.hardware.vibrator.service

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/excluded-input-devices.xml:$(TARGET_COPY_OUT_VENDOR)/etc/excluded-input-devices.xml

# VNDK
PRODUCT_PACKAGES += \
    libstdc++_vendor

# Wi-Fi
PRODUCT_PACKAGES += \
    android.hardware.wifi-service \
    android.hardware.wifi.hostapd@1.0.vendor \
    wpa_cli \
    libwpa_client:64 \
    hostapd \
    libwifi-hal-qcom:64 \
    wpa_supplicant \
    wpa_supplicant.conf

# WiFi firmware symlinks
PRODUCT_PACKAGES += \
    symlink_wlan_cfg_adrastea \
    symlink_wlan_fw_adrastea

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/WCNSS_qcom_cfg.ini:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/adrastea/WCNSS_qcom_cfg.ini

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.aware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.aware.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml

# WiFi Display
PRODUCT_PACKAGES += \
    libnl \
    libwfdaac_vendor

# Extra (GApps, Prebuilts, BCR, Signing Keys)
$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)
$(call inherit-product-if-exists, vendor/extras/prebuilts.mk)
$(call inherit-product-if-exists, vendor/bcr/bcr.mk)
$(call inherit-product-if-exists, vendor/signify/keys/keys.mk)

# =========================================================
# 🔥 PERMANENT SECURITY, PERFORMANCE & SPOOFING FIXES
# =========================================================

# Security Hardening
PRODUCT_PACKAGES_REMOVE += su
PRODUCT_SYSTEM_PROPERTIES += \
    ro.debuggable=0 \
    ro.secure=1 \
    ro.adb.secure=1 \
    persist.sys.usb.config=mtp \
    persist.adb.notify=0 \
    ro.force.encryption=1 \
    ro.crypto.state=encrypted \
    ro.crypto.type=file \
    ro.sys.unknown_sources=0 \
    ro.force.app.security=true \
    ro.hardware.keystore=on \
    ro.control_privapp_permissions=enforce

# Play Integrity / Stock Spoofing (Fixes banking apps & certification)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.product.brand=Xiaomi \
    ro.product.manufacturer=Xiaomi \
    ro.product.model=23076RN4BI \
    ro.product.device=sky \
    ro.product.name=sky_global \
    ro.build.product=sky \
    ro.build.id=UKQ1.230917.001 \
    ro.build.fingerprint=Xiaomi/sky_global/sky:14/UKQ1.230917.001/V816.0.2.0.UMHINXM:user/release-keys \
    ro.build.version.security_patch=2025-01-05 \
    ro.vendor.build.security_patch=2025-01-05 \
    ro.build.tags=release-keys \
    ro.build.type=user \
    ro.boot.verifiedbootstate=green \
    ro.boot.flash.locked=1 \
    ro.boot.vbmeta.device_state=locked \
    ro.boot.veritymode=enforcing

# Extreme Performance & Smoothness
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.window_animation_scale=0.0 \
    persist.sys.transition_animation_scale=0.0 \
    persist.sys.animator_duration_scale=0.0 \
    debug.sf.gpu_comp_mode=force-gpu \
    dalvik.vm.dex2oat-filter=speed \
    dalvik.vm.image-dex2oat-filter=speed \
    debug.sf.hw=1 \
    debug.egl.hw=1 \
    debug.composition.type=gpu \
    debug.sf.enable_hwc_vds=1 \
    debug.sf.latch_unsignaled=1 \
    debug.sf.enable_gl_backpressure=1 \
    ro.hwui.render_ahead=2 \
    ro.surface_flinger.max_frame_buffer_acquired_buffers=3 \
    ro.surface_flinger.set_idle_timer_ms=0 \
    persist.vendor.qti.config.gaming_mode=1 \
    persist.vendor.qti.config.perf_mode=1 \
    persist.sys.input.touch_delay=0 \
    sys.sysctl.extra_free_kbytes=14400 \
    ro.config.low_ram=false \
    ro.config.disable_energy_aware_sched=true

# 🔥 NAYA ADD KIYA: HWUI Caches (UI Smoothness & Fast App Loading)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.hwui.texture_cache_size=96.0 \
    ro.hwui.layer_cache_size=48.0 \
    ro.hwui.path_cache_size=32.0 \
    ro.hwui.disable_vsync=true

# 🔥 NAYA ADD KIYA: Camera JPEG Quality 100%
PRODUCT_SYSTEM_PROPERTIES += \
    ro.media.enc.jpeg.quality=100

# Audio & Battery
PRODUCT_SYSTEM_PROPERTIES += \
    persist.vendor.audio.fluence.voicecall=false \
    persist.vendor.audio.fluence.speaker=false \
    ro.config.media_vol_steps=100 \
    ro.config.alarm_vol_steps=100 \
    persist.vendor.charge.speedup=1 \
    ro.quick.charge=1 \
    persist.vendor.charger.fast=1

# Bug Fixes
PRODUCT_PACKAGES += \
    org.lineageos.platform-res \
    LatinIME
PRODUCT_PACKAGES_REMOVE += \
    android.hardware.tv.tuner-V3-ndk \
    android.hardware.tv.tuner-V3-ndk_platform
PRODUCT_SYSTEM_PROPERTIES += \
    persist.vendor.camera.flash.pmic=0 \
    ro.vendor.camera.flash.gpio=0 \
    ro.unique_wifi_mac=false \
    persist.vendor.wifi.mac_randomization=0 \
    config_wifi_background_scan=false

# Extreme Battery Life & Deep Sleep
PRODUCT_SYSTEM_PROPERTIES += \
    ro.vendor.qti.config.doze=1 \
    ro.vendor.qti.config.doze_aggressive=1 \
    persist.sys.doze.timeout=1 \
    ro.vendor.qti.sys.fw.bg_apps_limit=60 \
    ro.vendor.qti.sys.fw.empty_app_percent=50 \
    ro.zram.size=2147483648 \
    ro.lmk.use_minfree_levels=true \
    ro.lmk.swap_free_low_percentage=20 \
    persist.sys.trace.enable=0

# GApps Wakelock Fix (Background battery drain stop)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/sysconfig/battery_tweaks.xml:system/etc/sysconfig/battery_tweaks.xml

# =========================================================
# 👑 ROM KING PRO-TIER TWEAKS (Ultimate Smoothness & Stability)
# =========================================================

# 1. Display & UI Smoothness (Force 120Hz & Prevent Frame Drops)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.sf.native_mode=1 \
    debug.sf.enable_phase_offsets=1 \
    debug.sf.use_phase_offsets_as_durations=1 \
    ro.surface_flinger.set_touch_timer_ms=200 \
    ro.surface_flinger.use_content_detection_for_refresh_rate=true

# 2. Network & VoLTE (Jio/Airtel 5G Stability)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.dbg.volte_avail_ovr=1 \
    persist.dbg.vt_avail_ovr=1 \
    persist.dbg.wfc_avail_ovr=1 \
    ro.telephony.default_network=33 \
    ro.telephony.default_cdma_sub=0

# 🔥 NAYA ADD KIYA: VoWiFi Stability (WiFi Calling Drop Fix)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.vendor.data.iwlan.enable=true

# 3. Google OTA Block & System Protection (Stop Background Updates)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.com.google.clientidbase=android-google \
    ro.com.google.gmsversion=14_202401 \
    ro.sys.fw.dex2oat_max_execution_time=0 \
    persist.sys.disable_rescue=true \
    ro.config.enable_rescueparty=false

# 4. Camera Auxiliary Lenses (Unlock All Lenses)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.vendor.camera.privapp.list=com.android.camera,com.miui.camera \
    ro.vendor.camera.aux.packagelist=com.android.camera,com.miui.camera,org.codeaurora.snapcam \
    persist.vendor.camera.expose.aux=1

# 5. Audio Magic (Deep Buffer & High-Res)
PRODUCT_SYSTEM_PROPERTIES += \
    audio.offload.disable=0 \
    audio.offload.buffer.size.kb=32 \
    audio.offload.pcm.16bit.enable=true \
    audio.offload.pcm.24bit.enable=true \
    persist.vendor.audio.ras.enabled=false \
    vendor.audio.feature.dynamic_ecns.enable=true

# 6. Extreme Memory (Keep apps alive forever)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.config.max_starting_bg=8 \
    ro.sys.fw.bg_apps_limit=60 \
    ro.config.free_memory=8192

# =========================================================
# 📡 5G NETWORK & GPS TURBO BOOST
# =========================================================

# 5G Preferred Mode (Fastest Network)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.vendor.radio.5g_mode_pref=1 \
    persist.radio.nr.mode=1 \
    persist.vendor.radio.enable_5g_sa=1 \
    persist.vendor.radio.enable_5g_nsa=1 \
    persist.radio.allow_5g_roaming=1

# GPS High-Accuracy & Instant Lock (AGPS)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.vendor.gps.lpp_profile=2 \
    persist.vendor.gps.supl_host=supl.google.com \
    persist.vendor.gps.supl_port=7276 \
    persist.vendor.gps.debug_level=3 \
    persist.vendor.gps.nmea=1 \
    ro.gps.agps_provider=1

# =========================================================
# 🛡️ ANTI-THEFT TRACKING & ULTRA-STRONG CONNECTION
# =========================================================

# 1. Anti-Theft Tracking (Find My Device Force ON)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.com.google.locationfeatures=1 \
    ro.com.google.networklocation=1 \
    ro.allow.mock.location=1 \
    persist.sys.gps.power=1 \
    ro.kernel.android.checkjni=0 \
    persist.sys.background_apps_limit=100

# 2. Ultra-Strong Calling & Network (Modem Keep-Alive)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.radio.calls.on.ims=1 \
    persist.radio.jbims=1 \
    persist.radio.vrte_logic=1 \
    persist.vendor.radio.data_con_rprt=1 \
    persist.vendor.radio.apm_sim_not_pwdn=1 \
    persist.vendor.radio.add_power_save=0 \
    persist.dbg.ims_volte_avail_ovr=1

# =========================================================
# 🚀 PRO-LEVEL ADVANCED FEATURES (Custom ROM King)
# =========================================================

# 1. Camera Pro (GCam RAW Support & Aux Lenses)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.camera.HAL3.enabled=1 \
    persist.vendor.camera.HAL3.enabled=1 \
    persist.camera.aux.packagelist=com.google.android.GoogleCamera,org.codeaurora.snapcam,com.android.camera \
    persist.vendor.camera.expose.aux=1 \
    persist.vendor.camera.raw.support=1 \
    vendor.camera.aux.packagelist=com.google.android.GoogleCamera,org.codeaurora.snapcam

# 2. Network Speed & Gaming (TCP BBR & DNS)
PRODUCT_SYSTEM_PROPERTIES += \
    net.tcp.sec.default=1 \
    net.tcp.buffersize.default=4096,87380,524288,4096,16384,110208 \
    net.tcp.buffersize.wifi=524288,1048576,2097152,262144,524288,1048576 \
    persist.sys.dns.probe=1 \
    ro.config.combined_signal=true

# 3. Gaming Touch & Display (240Hz Touch Sampling)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.input.touch_rate=240 \
    persist.sys.input.max_events_per_sec=400

# 4. Storage & RAM Pro Tweaks (I/O & VM)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.sys.fw.bg_apps_limit=60 \
    ro.config.free_memory=8192 \
    vm.heapminfree=2m \
    vm.heapmaxfree=8m \
    vm.heaptargetutilization=0.75 \
    persist.sys.mm.enable_swap=1

# 5. Bluetooth Hi-Res Audio (LDAC & aptX)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.bluetooth.a2dp_offload.cap=LDAC,APTX_HD,APTX,AAC,SBC \
    persist.bluetooth.avrcp_version=1.6 \
    ro.bluetooth.ldac=true \
    ro.bluetooth.aptx=true

# 6. Bypass Charging for Gaming (Heat reduction)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.vendor.charge.bypass=1 \
    persist.vendor.charger.usb_5v=1 \
    ro.vendor.usb.bypass_charging=true

# =========================================================
# 💎 THE FINAL HIDDEN GEMS (Ultimate Custom ROM King)
# =========================================================

# 1. Native Call Recording & VoWiFi (WiFi Calling)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.call_recording.enabled=1 \
    ro.com.android.call_recording=1 \
    persist.dbg.wfc_avail_ovr=1 \
    persist.vendor.radio.wfc_enabled=1 \
    ro.telephony.wfc.force=1

# 2. System OTA Block (Stop accidental bootloops)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.ota.disabled=1 \
    ro.build.ota.disabled=1 \
    lineage.updater.enabled=0

# 3. UI Blur & Premium Look (No Lag due to GPU)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.surface_flinger.supports_background_blur=1 \
    ro.launcher.blur.appLaunch=1 \
    ro.launcher.blur.appClose=1

# 4. Audio Ducking Disable (Uninterrupted Music)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.audio.ducking=false \
    ro.config.audio.ducking=0

# 5. Deep VM Tweaks (Extreme Storage & RAM Fluidity)
PRODUCT_SYSTEM_PROPERTIES += \
    vm.swappiness=60 \
    vm.vfs_cache_pressure=100 \
    vm.dirty_ratio=20 \
    vm.dirty_background_ratio=5 \
    dalvik.vm.usejit=true \
    dalvik.vm.usejitprofiles=true

# =========================================================
# 🔮 HYPER-ADVANCED SYSTEM TWEAKS (The True King)
# =========================================================

# 1. Zygote Preload & Fast Boot (Instant Boot)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.zygote.preload=1 \
    persist.sys.zygote_preload=1 \
    ro.config.zygote_max=4

# 2. Wi-Fi & Bluetooth Battery Saver (Scan Throttling)
PRODUCT_SYSTEM_PROPERTIES += \
    wifi.scan_interval_ms=60000 \
    wifi.supplicant_scan_interval=180 \
    persist.vendor.bt.scan_interval=120

# 3. Sensor Offload (Battery Save during Workout)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.vendor.sensors.offload_step_counter=1 \
    ro.vendor.sensors.offload_activity=1 \
    ro.vendor.sensors.offload_gesture=1

# 4. Widevine L1 Force (Netflix / Amazon Prime HD)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.netflix.bsp_rev=Q855-16947-1 \
    persist.sys.widevine.level=1

# 5. CPU & GPU Governor Tuning (For Maximum FPS)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.vendor.qti.config.power_save=0 \
    persist.sys.cpu.min_freq=300000 \
    persist.sys.gpu.governor=msm-adreno-tz

# 6. Ext4/F2FS File System Tweaks (Instant File Reading)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.config.f2fs_optimize=1 \
    persist.sys.fs.trim=1

# =========================================================
# 🏁 THE FINAL TOUCH (Micro-Tuning for Perfect ROM)
# =========================================================

# 1. Touch & UI Fluid Response
PRODUCT_SYSTEM_PROPERTIES += \
    ro.input.resampling=1 \
    ro.input.touch.prediction=1 \
    persist.sys.ui.hw=1

# 2. F2FS & File System (Storage Speed)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.vold.secure_dirs=1

# 3. RAM & Zygote (Instant App Loading)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.device_config.runtime_native_boot.enable_apex_image=true

# =========================================================
# 🏁 THE ABSOLUTE FINAL TWEAKS (Micro-Details)
# =========================================================

# 1. OTG & USB Speed Boost (Pendrive/External HDD Fast Data Transfer)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.usb.ffs.max_read=2097152 \
    persist.sys.usb.ffs.max_write=2097152

# 2. Wide Color Gamut (Screen Colors ko aur vibrant karega)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.sf.wide_color_mode=1 \
    ro.surface_flinger.has_wide_color_display=true

# 3. Kill Background Logs (CPU load kam karega)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.logd.size=64K \
    logd.statistics=0 \
    persist.sys.logd.statistics=0

# =========================================================
# 🛡️ KERNEL & SYSTEM LEVEL SECURITY HARDENING (The Fortress)
# =========================================================

# 1. Kernel & Memory Protection (Block Rootkits & Memory Hacking)
PRODUCT_SYSTEM_PROPERTIES += \
    kernel.kptr_restrict=2 \
    kernel.dmesg_restrict=1 \
    net.ipv4.conf.all.rp_filter=1 \
    net.ipv4.tcp_syncookies=1

# 2. Block Google System Background Updates (Save RAM/CPU)
PRODUCT_SYSTEM_PROPERTIES += \
    ro.config.enable_mainline_updates=false \
    ro.config.disable_play_system_update=1

# 3. Strict Sandboxing (Apps ko aapas mein baat karne se rokna)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.app_sandbox_enforce=1 \
    ro.config.enforce_ipc_sandbox=1

# 4. USB Port Security (MTP enabled for rescue)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.usb.secure_lockdown=1

# =========================================================
# ⚡ ELITE KERNEL & ART OPTIMIZATIONS (No Compromise)
# =========================================================

# 1. ART Garbage Collector Tuning (Heavy Games ke liye RAM free rakhega)
PRODUCT_SYSTEM_PROPERTIES += \
    dalvik.vm.heapgrowthlimit=256m \
    dalvik.vm.heapsize=512m \
    dalvik.vm.heapstartsize=8m \
    dalvik.vm.heaptargetutilization=0.75

# 2. Sustained Performance Mode (Gaming ke dauran thermal throttle ko control karega)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.sustained_performance=1

# 3. Wi-Fi Channel Bonding (WiFi Speed Double)
PRODUCT_SYSTEM_PROPERTIES += \
    wifi.interface=wlan0 \
    wifi.supplicant_scan_interval=180 \
    net.tcp.buffersize.wifi=524288,1048576,2097152,262144,524288,1048576

# 4. Zygote Multi-threading (Fast Boot)
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.zygote_max=8
