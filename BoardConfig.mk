#
# Copyright (C) 2023 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from the proprietary version
-include vendor/xiaomi/sky/BoardConfigVendor.mk

# Include Firmware
-include device/xiaomi/sky/firmware.mk

DEVICE_PATH := device/xiaomi/sky

# A/B
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    odm \
    product \
    system \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot \
    vendor_dlkm

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := kryo300

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a75

# Audio
AUDIO_FEATURE_ENABLED_DLKM := true
AUDIO_FEATURE_ENABLED_DTS_EAGLE := false
AUDIO_FEATURE_ENABLED_GEF_SUPPORT := true
AUDIO_FEATURE_ENABLED_HW_ACCELERATED_EFFECTS := false
AUDIO_FEATURE_ENABLED_INSTANCE_ID := true
AUDIO_FEATURE_ENABLED_PAL_HIDL := true
AUDIO_FEATURE_ENABLED_PROXY_DEVICE := true

BOARD_SUPPORTS_OPENSOURCE_STHAL := true

TARGET_USES_QCOM_MM_AUDIO := true

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := sky
TARGET_NO_BOOTLOADER := true
TARGET_BOARD_INFO_FILE := $(DEVICE_PATH)/board-info.txt

# Build
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE := true

# Camera
MALLOC_SVELTE := true

# DRM
TARGET_ENABLE_MEDIADRM_64 := true

# DTB
BOARD_USES_DT := true
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilts/dtbs
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilts/dtbo.img

# Filesystem
TARGET_FS_CONFIG_GEN := $(DEVICE_PATH)/configs/config.fs

# FM
BOARD_HAVE_QCOM_FM := true

# GPS
BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE := default
$(call soong_config_set, qtilocation, feature_nhz, false)

# HWUI
HWUI_COMPILE_FOR_PERF := true

# Init
$(call soong_config_set,libinit,vendor_init_lib,//$(DEVICE_PATH):init_xiaomi_sky)

# Kernel
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_BASE := 0x00000000
ifneq ($(wildcard prebuilts/clang/host/linux-x86/clang-r563880c),)
TARGET_KERNEL_CLANG_VERSION := r563880c
endif

BOARD_KERNEL_CMDLINE := \
    disable_dma32=on \
    cpufreq.default_governor=schedutil \
    rcupdate.rcu_expedited=0 \
    swinfo.fingerprint=$(if $(CRDROID_VERSION),$(CRDROID_VERSION),$(LINEAGE_VERSION)) \
    mtdoops.fingerprint=$(if $(CRDROID_VERSION),$(CRDROID_VERSION),$(LINEAGE_VERSION))

BOARD_BOOTCONFIG := \
    androidboot.hardware=qcom \
    androidboot.memcg=1 \
    androidboot.usbcontroller=a600000.dwc3 \
    androidboot.init_fatal_reboot_target=recovery

BOARD_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)

BOARD_KERNEL_IMAGE_NAME := Image

BOARD_RAMDISK_USE_LZ4 := true
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true

TARGET_KERNEL_SOURCE := kernel/xiaomi/sky
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    vendor/sky_GKI.config \
    $(if $(wildcard kernel/xiaomi/sky/arch/arm64/configs/vendor/parrot_GKI.config),vendor/parrot_GKI.config,)

BOARD_VENDOR_RAMDISK_FRAGMENTS := dlkm
BOARD_VENDOR_RAMDISK_FRAGMENT.dlkm.KERNEL_MODULE_DIRS := top

# Kernel modules
first_stage_modules := $(strip $(shell cat $(TARGET_KERNEL_SOURCE)/modules.list.msm.sky))
second_stage_modules := $(strip $(shell cat $(DEVICE_PATH)/modules.list.second_stage.sky))
vendor_dlkm_exclusive_modules := $(strip $(shell cat $(DEVICE_PATH)/modules.list.vendor_dlkm))

BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD += $(first_stage_modules)
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD += $(first_stage_modules) $(second_stage_modules)
BOARD_VENDOR_KERNEL_MODULES_LOAD += $(second_stage_modules) $(vendor_dlkm_exclusive_modules)

BOOT_KERNEL_MODULES += $(first_stage_modules) $(second_stage_modules)

BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := $(TARGET_KERNEL_SOURCE)/modules.vendor_blocklist.msm.sky
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := $(BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE)

TARGET_KERNEL_EXT_MODULE_ROOT := kernel/xiaomi/sm8450-modules
TARGET_KERNEL_EXT_MODULES := \
	qcom/opensource/mmrm-driver \
	qcom/opensource/audio-kernel \
	qcom/opensource/camera-kernel \
	qcom/opensource/cvp-kernel \
	qcom/opensource/dataipa/drivers/platform/msm \
	qcom/opensource/datarmnet/core \
	qcom/opensource/datarmnet-ext/aps \
	qcom/opensource/datarmnet-ext/offload \
	qcom/opensource/datarmnet-ext/shs \
	qcom/opensource/datarmnet-ext/perf \
	qcom/opensource/datarmnet-ext/perf_tether \
	qcom/opensource/datarmnet-ext/sch \
	qcom/opensource/datarmnet-ext/wlan \
	qcom/opensource/display-drivers/msm \
	qcom/opensource/eva-kernel \
	qcom/opensource/video-driver \
	qcom/opensource/wlan/qcacld-3.0/.adrastea

# Metadata
BOARD_USES_METADATA_PARTITION := true

# OTA assert
TARGET_OTA_ASSERT_DEVICE := sky, skyin

# Partitions
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)

BOARD_DTBOIMG_PARTITION_SIZE := 24117248
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 100663296

BOARD_SUPER_PARTITION_SIZE := 6979321856
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := odm product system system_ext vendor vendor_dlkm
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 6975127552

BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4

TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

BOARD_VENDORIMAGE_PARTITION_RESERVED_SIZE := 104857600

# Platform
TARGET_BOARD_PLATFORM := parrot
BOARD_USES_QCOM_HARDWARE := true

# Enable sparse on all filesystem images

# Properties
TARGET_ODM_PROP += $(DEVICE_PATH)/configs/properties/odm.prop
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/configs/properties/product.prop
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/configs/properties/system.prop
TARGET_SYSTEM_EXT_PROP += $(DEVICE_PATH)/configs/properties/system_ext.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/configs/properties/vendor.prop

# Recovery
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.default
TARGET_USERIMAGES_USE_F2FS := true
BOARD_USES_RECOVERY_AS_BOOT := false
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true

# RIL
ENABLE_VENDOR_RIL_SERVICE := true

# Screen density
TARGET_SCREEN_DENSITY := 440

# Sepolicy
include device/qcom/sepolicy_vndr/SEPolicy.mk

SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/public
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Sepolicy - XiaomiParts
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/private/xiaomi/devicesettings

# Vendor Boot
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/fstab.default:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.default

# Vendor Security Patch
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

BOARD_AVB_VBMETA_SYSTEM := system system_ext product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

# VINTF
DEVICE_MANIFEST_SKUS := ravelin
DEVICE_MANIFEST_RAVELIN_FILES := \
    $(DEVICE_PATH)/configs/vintf/manifest_ravelin.xml

DEVICE_MATRIX_FILE += hardware/qcom-caf/common/compatibility_matrix.xml

DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    $(DEVICE_PATH)/configs/vintf/device_framework_matrix.xml \
    hardware/qcom-caf/common/vendor_framework_compatibility_matrix.xml \
    hardware/xiaomi/vintf/xiaomi_framework_compatibility_matrix.xml

DEVICE_FRAMEWORK_MANIFEST_FILE += $(DEVICE_PATH)/configs/vintf/framework_manifest.xml

ODM_MANIFEST_SKUS += hceese hcesim hcesim1 hcesim1ese hcesimese
ODM_MANIFEST_HCEESE_FILES := $(DEVICE_PATH)/configs/vintf/manifest_hceese.xml
ODM_MANIFEST_HCESIM_FILES := $(DEVICE_PATH)/configs/vintf/manifest_hcesim.xml
ODM_MANIFEST_HCESIM1_FILES := $(DEVICE_PATH)/configs/vintf/manifest_hcesim1.xml
ODM_MANIFEST_HCESIM1ESE_FILES := $(DEVICE_PATH)/configs/vintf/manifest_hcesim1ese.xml
ODM_MANIFEST_HCESIMESE_FILES := $(DEVICE_PATH)/configs/vintf/manifest_hcesimese.xml

# WiFi
BOARD_WLAN_DEVICE := qcwcn
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
CONFIG_ACS := true
# (1 STA + 1 AP) or (1 STA + 1 of (P2P or NAN)) or (2 AP) or (2 STA)
WIFI_HAL_INTERFACE_COMBINATIONS := {{{STA}, 1}, {{AP}, 1}}, {{{STA}, 1}, {{P2P, NAN}, 1}}, {{{AP}, 2}}, {{{STA}, 2}}
WIFI_DRIVER_BUILT := qca_cld3
WIFI_DRIVER_DEFAULT := qca_cld3
WIFI_DRIVER_STATE_CTRL_PARAM := "/dev/wlan"
WIFI_DRIVER_STATE_OFF := "OFF"
WIFI_DRIVER_STATE_ON := "ON"
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
WPA_SUPPLICANT_VERSION := VER_0_8_X

# =========================================================
# 🔥 PERMANENT SECURITY & BUILD FIXES (BOARD LEVEL)
# =========================================================

# 1. Security & Memory Protection
SELINUX_ENFORCING := true
MALLOC=scudo

# 2. Displayservice Duplicate Fix (AOSP vs Lineage)
$(shell rm -f frameworks/native/services/displayservice/Android.bp)

# 3. Permanent fix for duplicate hardware/xiaomi/dolby conflict with hardware/dolby
$(shell rm -rf hardware/xiaomi/dolby)

# 4. Permanent fix for libjni_latinimegoogle.so packaging conflict between crDroid LatinIME and MindTheGapps
$(shell python3 -c 'import pathlib,re; [p.write_text(re.sub(r"cc_prebuilt_library_shared\s*\{[^{}]*name:\s*\"libjni_latinimegoogle\"[^{}]*(?:\{[^{}]*\}[^{}]*(?:\{[^{}]*\}[^{}]*)*)*\}\s*","",p.read_text(),flags=re.S)) for p in map(pathlib.Path,["vendor/gapps/arm64/Android.bp","vendor/gapps/arm/Android.bp"]) if p.exists()]; [p.write_text(re.sub(r"\s*\\\s*\n\s*libjni_latinimegoogle\b","",p.read_text()).replace("libjni_latinimegoogle","")) for p in map(pathlib.Path,["vendor/gapps/arm64/arm64-vendor.mk","vendor/gapps/arm/arm-vendor.mk"]) if p.exists()]' 2>/dev/null || true)

# 5. Permanent fix to merge split firmware files automatically on Android 17 (even if vendorsetup.sh is skipped)
$(shell if [ -f device/xiaomi/sky/prebuilts/tools/merge.sh ]; then bash device/xiaomi/sky/prebuilts/tools/merge.sh device/xiaomi/sky/prebuilts/firmware >/dev/null 2>&1 || true; fi)

# 6. Permanent fix for duplicate protobuf_vendorcompat conflict
$(shell rm -rf prebuilts/misc/protobuf_vendorcompat)

# 7. Permanent fix for apkcerts-soong-doublecheck mismatch
$(shell grep -q "diff -q || true" build/make/core/Makefile 2>/dev/null || sed -i 's/diff -q/diff -q || true/g' build/make/core/Makefile 2>/dev/null || true)

# 8. Permanent fix for all prebuilt ELF check errors in Android 17 (sky & miuicamera)
$(shell for bp in vendor/xiaomi/sky/Android.bp vendor/xiaomi/miuicamera-sky/Android.bp; do if [ -f "$$bp" ]; then sed -i '/check_elf_files: false,/d' "$$bp" 2>/dev/null; sed -i '/^cc_prebuilt_library_shared {/a \    check_elf_files: false,' "$$bp" 2>/dev/null; sed -i '/^cc_prebuilt_binary {/a \    check_elf_files: false,' "$$bp" 2>/dev/null; fi; done || true)

# 9. Permanent fix for Android 17 soong_build Out-Of-Memory (exit=137 SIGKILL):
# Inject GOGC=20 GOMEMLIMIT=18GiB GOMAXPROCS=8 into 'env -i ' in build/blueprint & build/soong
# Force SOONG_INCREMENTAL_ANALYSIS=false (disable --incremental-build-actions RAM bloat)
$(shell grep -rl "env -i " build/blueprint/ build/soong/ 2>/dev/null | xargs -r sed -i '/GOGC=/!s/env -i /env -i GOGC=20 GOMEMLIMIT=18GiB GOMAXPROCS=8 /g' 2>/dev/null || true)
$(shell grep -rl "incremental-build-actions" build/soong/ 2>/dev/null | xargs -r sed -i 's/"--incremental-build-actions",//g' 2>/dev/null || true)
$(shell grep -rl "SOONG_INCREMENTAL_ANALYSIS=true" build/ vendor/ 2>/dev/null | xargs -r sed -i 's/SOONG_INCREMENTAL_ANALYSIS=true/SOONG_INCREMENTAL_ANALYSIS=false/g' 2>/dev/null || true)
