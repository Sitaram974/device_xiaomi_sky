#
# Copyright (C) 2023 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/lineage_sky.mk

# 🔥 ROOT FIX: Android 17 (Lineage 24.0) ka naya Lunch Format
# Ab aap lunch lineage_sky-cp2a-userdebug bhi use kar sakte hain
COMMON_LUNCH_CHOICES := \
    lineage_sky-cp2a-userdebug \
    lineage_sky-cp2a-user \
    lineage_sky-cp2a-eng \
    lineage_sky-bp1a-userdebug \
    lineage_sky-bp1a-user \
    lineage_sky-bp1a-eng \
    lineage_sky-userdebug \
    lineage_sky-user \
    lineage_sky-eng
