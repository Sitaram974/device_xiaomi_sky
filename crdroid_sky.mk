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

# Inherit common crDroid configurations (crDroid keeps its vendor repo at vendor/lineage)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Reserved size config (path differs between ROMs, pick whichever exists)
ifneq ($(wildcard vendor/crdroid/config/BoardConfigReservedSize.mk),)
$(call inherit-product, vendor/crdroid/config/BoardConfigReservedSize.mk)
else ifneq ($(wildcard vendor/lineage/config/BoardConfigReservedSize.mk),)
$(call inherit-product, vendor/lineage/config/BoardConfigReservedSize.mk)
endif

# Inherit device configurations
$(call inherit-product, $(DEVICE_PATH)/device.mk)

# Inherit from the proprietary version
$(call inherit-product, vendor/xiaomi/sky/sky-vendor.mk)

# crDroid flags
TARGET_BOOT_ANIMATION_RES := 1080

## Device identifier
PRODUCT_DEVICE := sky
PRODUCT_NAME := crdroid_sky
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := 23076RN4BI
PRODUCT_MANUFACTURER := Xiaomi

$(call inherit-product, $(DEVICE_PATH)/common.mk)
