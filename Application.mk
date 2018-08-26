## Application.mk - Android build file for Crypto++. Written and
##                  placed in public domain by Jeffrey Walton.
##
##            The Android make uses GNU Make and is documented at
##            https://developer.android.com/ndk/guides/android_mk
##
##            For a list of Android Platforms and API levels see
##            https://developer.android.com/ndk/guides/stable_apis
##            Below Android 4.3 is android-18

APP_ABI := all
APP_PLATFORM := android-18
APP_STL := gnustl_shared

CRYPTOPP_PATH := $(call my-dir)
NDK_PROJECT_PATH := $(CRYPTOPP_PATH)
APP_BUILD_SCRIPT := $(CRYPTOPP_PATH)/Android.mk

ifeq ($(NDK_LOG),1)
    $(info Crypto++: NDK_PROJECT_PATH is $(NDK_PROJECT_PATH))
    $(info Crypto++: APP_BUILD_SCRIPT is $(APP_BUILD_SCRIPT))
endif
