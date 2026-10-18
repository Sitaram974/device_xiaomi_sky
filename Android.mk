LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),sky)
    include $(call all-makefiles-under,$(LOCAL_PATH))
endif
