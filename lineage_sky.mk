#
# Copyright (C) 2023 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/sky

# Configure core_64_bit.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)

# Configure full_base_telephony.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit common Lineage / crDroid configurations
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit device configurations
$(call inherit-product, $(DEVICE_PATH)/device.mk)

# Inherit from the proprietary version
$(call inherit-product-if-exists, vendor/xiaomi/sky/sky-vendor.mk)

# Inherit In-Built GApps (MindTheGapps Android 17 / cinnamonbun)
WITH_GMS := true
$(call inherit-product-if-exists, vendor/gapps/arm64/arm64-vendor.mk)

# crDroid 17.0 Build Flags
TARGET_BOOT_ANIMATION_RES := 1080
TARGET_FACE_UNLOCK_SUPPORTED := true
TARGET_SUPPORTS_BLUR := true

# Maintainer Property
PRODUCT_PROPERTY_OVERRIDES += \
    ro.crdroid.maintainer=Sitaram974

## Device identifier
PRODUCT_DEVICE := sky
PRODUCT_NAME := lineage_sky
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Redmi 12 5G
PRODUCT_MANUFACTURER := Xiaomi

# GMS
PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
