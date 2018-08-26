## Application.mk - Android build file for Crypto++. Written and
##                  placed in public domain by Jeffrey Walton.
##
##            The Android make uses GNU Make and is documented at
##            https://developer.android.com/ndk/guides/android_mk
##
##            For a list of Android Platforms and API levels see
##            https://developer.android.com/ndk/guides/stable_apis
##            Android 4.3 is android-18, and Android 5 is android-21.
##
##            Android recommends c++_shared for NDK version 16.0 and
##            above. Android will be removing other runtime libraries
##            as early as NDK version 18. Also see
##            https://developer.android.com/ndk/guides/cpp-support.

APP_ABI := all
APP_PLATFORM := android-21

# APP_STL := gnustl_shared
APP_STL := c++_shared

CRYPTOPP_ROOT := $(call my-dir)
NDK_PROJECT_PATH := $(CRYPTOPP_ROOT)
APP_BUILD_SCRIPT := $(CRYPTOPP_ROOT)/Android.mk

ifeq ($(NDK_LOG),1)
    $(info Crypto++: NDK_PROJECT_PATH is $(NDK_PROJECT_PATH))
    $(info Crypto++: APP_BUILD_SCRIPT is $(APP_BUILD_SCRIPT))
endif
