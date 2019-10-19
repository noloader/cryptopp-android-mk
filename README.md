## Crypto++ Android

This repository contains Android build files for Wei Dai's [Crypto++](http://github.com/weidai11/cryptopp). It supplies `Android.mk` and `Application.mk` for Crypto++ for those who want to use Android build tools.

The purpose of Crypto++ Android build is two-fold:

1. better support Android distributions
2. supplement the GNUmakefile which is reaching its limits with repsect to GNUmake-based configuration

The initial `Android.mk` and `Application.mk` based on Alex Afanasyev's pull request at http://github.com/weidai11/cryptopp/pull/3.

There is a wiki page available that discusses the Android build system and the Crypto++ project files in more detail at [Android.mk (Command Line)](https://www.cryptopp.com/wiki/Android.mk_(Command_Line)).

## Testing

The Android build files are a work in progress, so use them at your own risk. With that said <tt>cryptest-android.sh</tt> is used to test the build system.

In September 2016 the library added <tt>cryptest-android.sh</tt> to help test the Android.mk gear. The script is located in Crypto++'s <tt>TestScripts</tt> directory. The script downloads the Android.mk project files and builds the library.

If you want to use <tt>cryptest-android.sh</tt> to drive things then perform the following steps.

```
cd cryptopp
cp TestScripts/cryptest-android.sh .
./cryptest-android.sh
```

## Workflow
The general workflow is clone Wei Dai's crypto++, fetch the Android files, and then build using `ndk-build`:

    git clone http://github.com/weidai11/cryptopp.git
    cd cryptopp
    
    wget -O Android.mk https://raw.githubusercontent.com/noloader/cryptopp-android/master/Android.mk
    wget -O Application.mk https://raw.githubusercontent.com/noloader/cryptopp-android/master/Application.mk
    wget -O make_neon.sh https://raw.githubusercontent.com/noloader/cryptopp-android/master/make_neon.sh

    ndk-build NDK_PROJECT_PATH=... NDK_APPLICATION_MK=...

## ZIP Files

If you are working from a Crypto++ release zip file, then you should download the same cryptopp-android release zip file. Both Crypto++ and this project use the same release tags, such as CRYPTOPP_8_0_0.

If you mix and match Master with a release zip file then things may not work as expected. You may find the build project files reference a source file that is not present in the Crypto++ release.

## Prerequisites

Before running the Android project please ensure you have the following installed:

1. Android NDK
2. Android SDK
3. `ANDROID_NDK_ROOT` envar set
4. `ANDROID_SDK_ROOT` envar set

`ANDROID_NDK_ROOT` and `ANDROID_SDK_ROOT` are NDK and SDK environmental variables used by the Android tools. They should be set whenever you use Android's command line tools. The project does not use environmental variables from Eclipse or Android Studio like `ANDROID_HOME` or `ANDROID_SDK_HOME`. Also see [Recommended NDK Directory?](http://groups.google.com/group/android-ndk/browse_thread/thread/a998e139aca71d77) on the Android NDK mailing list.

## Integration
The Android build files require an unusal filesystem layout. Your Crypto++ source files will be located in a folder like `<project root>/cryptopp-7.1`. `Android.mk` and `Application.mk` will be located in a folder like `<project root>/jni`. You must set `CRYPTOPP_ROOT` in `Android.mk` to a value like `../cryptopp-7.1/`. The trailing slash is important because the build system uses GNU Make's `addprefix` which is a simple concatenation.

To run the script issue `ndk-build` with several NDK build variables set. `NDK_PROJECT_PATH` and `NDK_APPLICATION_MK` are required when not using Android default paths like `jni/`.

    cd cryptopp
    ndk-build V=1 NDK_PROJECT_PATH="$PWD" NDK_APPLICATION_MK="$PWD/Application.mk"

According to [NDK Build](http://developer.android.com/ndk/guides/ndk-build) you should set `NDK_DEBUG=1` for debug builds and `NDK_DEBUG=0` for release builds. You can also set `NDK_LOG=1` and `V=1` for verbose NDK builds which should help with diagnostics.

## Collaboration
We would like all maintainers to be collaborators on this repo. If you are a maintainer then please contact us so we can send you an invite.

If you are a collaborator then make changes as you see fit. You don't need to ask for permission to make a change. Noloader is not an Android expert so there are probably lots of opportunities for improvement.

Keep in mind other folks may be using the files, so try not to break things for the other guy. We have to be mindful of different versions of the NDK and API versions.

Everything in this repo is release under Public Domain code. If the license or terms is unpalatable for you, then don't feel obligated to commit.
