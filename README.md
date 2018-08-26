# Crypto++ Android

This repository contains Android build files for Wei Dai's Crypto++ (http://github.com/weidai11/cryptopp). It supplies `Android.mk` and `Application.mk` for Crypto++ for those who want to use Android build tools. Android's build system is officialy unsupported, so use it at your own risk.

The purpose of Crypto++ Android build is three-fold:

1. better support Android distributions
2. supplement the GNUmakefile which is reaching its limits with repsect to GNUmake-based configuration
3. utilize compiler feature probes that produce better results on x86, ARM, and MIPS

The initial `Android.mk` and `Application.mk` based on Alex Afanasyev's pull request at http://github.com/weidai11/cryptopp/pull/3.

The Android build files are a work in progress, so use it at your own risk. The head notes in `Android.mk` list some outstanding items. Please feel free to make pull requests to fix problems.

# Workflow
The general workflow is clone Wei Dai's crypto++, add Android as a submodule, and then copy the files of interest into the Crypto++ directory:

    git clone http://github.com/weidai11/cryptopp.git
    cd cryptopp
    git submodule add http://github.com/noloader/cryptopp-android.git android
    git submodule update --remote

    cp "$PWD/android/Android.mk" "$PWD"
    cp "$PWD/android/Application.mk" "$PWD"

To update the library and the submodule perform the following. The `make clean` is needed because reconfigure'ing does not invalidate the previously built objects or artifacts.

    cd cryptopp
    git pull
    git submodule update --remote

    cp "$PWD/android/Android.mk" "$PWD"
    cp "$PWD/android/Application.mk" "$PWD"

Despite our efforts we have not been able to add the submodule to Crypto++ for seamless integration. If anyone knows how to add the submodule directly to the Crypto++ directory, then please provide the instructions.

# Prerequisites

Before running the Autotools project please ensure you have the following installed:

1. Android NDK
2. Android SDK
3. ANDROID_NDK_ROOT envar set
4. ANDROID_SDK_ROOT envar set

`ANDROID_NDK_ROOT` and `ANDROID_SDK_ROOT` are NDK and SDK variables used by the tools. They should be set whenever you use Android's command line tools. The project does not use environmental variables used by Eclipse or Android Studio. Also see http://groups.google.com/group/android-ndk/browse_thread/thread/a998e139aca71d77 .

# Integration
The Android build files require an unusal filesystem layout. Your Crypto++ source files will be located in a folder like `<project root>/cryptopp-7.1`. `Android.mk` and `Application.mk` will be located in a folder like `<project root>/jni`. You must set `CRYPTOPP_ROOT` in `Android.mk` to a value like `../cryptopp-7.1/`. The trailing slash is important because is uses GNU Make's `addprefix` which is a simple concatenation.

To run the script issue `ndk-build` with several NDK build variables set. `NDK_PROJECT_PATH` and `NDK_APPLICATION_MK` are required when not using Android default paths.

    cd cryptopp
    ndk-build V=1 NDK_PROJECT_PATH="$PWD" NDK_APPLICATION_MK="$PWD/Application.mk"

According to [NDK Build](http://developer.android.com/ndk/guides/ndk-build) you should set `NDK_DEBUG=1` for debug builds and `NDK_DEBUG=0` for release builds. You can also set `NDK_LOG=1` and V=1` for verbose NDK builds which to help with diagnostics.

# Collaboration
We would like all maintainers to be collaborators on this repo. If you are a maintainer then please contact us so we can send you an invite.

If you are a collaborator then make changes as you see fit. You don't need to ask for permission to make a change. Noloader is not an Android expert so there are probably lots of opportunities for improvement.

Keep in mind other folks may be using the files, so try not to break things for the other guy. We have to be mindful of different versions of the NDK and API versions.

Everything in this repo is release under Public Domain code. If the license or terms is unpalatable for you, then don't feel obligated to commit.

# Future
The Android project files are separate at the moment for several reason, like avoiding Git log pollution with Android branch experiments. We also need to keep a logical separation because GNUmake is the official build system, and not the Android project files.

Eventually we would like to do two things. First, we would like to move this project from Jeff Walton's GitHub to Wei Dai's GitHub to provide stronger assurances on provenance. Second, we would like to provide an `android.zip` and place it in the Crypto++ `TestScripts/` directory to make it easier for folks to use Android.
