## Application.mk - Android build file for Crypto++.

## Written and placed in public domain by Jeffrey Walton. This
## Android.mk is based on Alex Afanasyev (GitHub @cawka) PR #3,
## https://github.com/weidai11/cryptopp/pull/3.
##
## The Android build system is a wrapper around GNU Make and is
## documented https://developer.android.com/ndk/guides/android_mk.
## The CPU Features library provides caps and is documented at
## https://developer.android.com/ndk/guides/cpu-features.
##
## For a list of Android Platforms and API levels see
## https://developer.android.com/ndk/guides/stable_apis.
## Android 4.3 is android-18, and Android 5 is android-21.
##
## Android recommends c++_shared for NDK version 16.0 and
## above. Android will be removing other runtime libraries
## as early as NDK version 18. Also see
## https://developer.android.com/ndk/guides/cpp-support.

APP_ABI := all
APP_PLATFORM := android-23

# APP_STL := gnustl_shared
APP_STL := c++_shared

CRYPTOPP_ROOT := $(call my-dir)
NDK_PROJECT_PATH := $(CRYPTOPP_ROOT)
APP_BUILD_SCRIPT := $(CRYPTOPP_ROOT)/Android.mk

GREP ?= grep
NDK_r16_OR_LATER := $(shell $(GREP) -i -c -E "Pkg.Revision = (1[6-9]|[2-9][0-9]\.)" "$$ANDROID_NDK_ROOT/source.properties")
ifneq ($(NDK_r16_OR_LATER),0)
  ifneq ($(APP_STL),c++_shared)
    $(info Crypto++: NDK r16 or later. Use c++_shared instead of $(APP_STL))
  endif
endif

ifeq ($(NDK_LOG),1)
    $(info Crypto++: ANDROID_NDK_ROOT is $(ANDROID_NDK_ROOT))
    $(info Crypto++: NDK_PROJECT_PATH is $(NDK_PROJECT_PATH))
    $(info Crypto++: APP_BUILD_SCRIPT is $(APP_BUILD_SCRIPT))
endif

