#!/bin/bash

GN_OUT_PATH=$1

IPHONE_SYSROOT=$(grep 'Developer/SDKs/iPhoneOS' ${GN_OUT_PATH}/obj/pc/peerconnection.ninja | awk '{ print $31 }')
TV_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/AppleTVOS.platform/Developer/SDKs/AppleTVOS.sdk

IPHONE_SYSROOT_SED=$(echo "${IPHONE_SYSROOT//\//\\/}")
TV_SYSROOT_SED=$(echo "${TV_SYSROOT//\//\\/}")

ninjas=`find ${GN_OUT_PATH} -name '*.ninja'`
ninjas=$(echo "$ninjas" | tr ' ' '\n' | sort -u | tr '\n' ' ')

for ninja in $ninjas; do
    sed -i -- "s/${IPHONE_SYSROOT_SED}/${TV_SYSROOT_SED}/g" $ninja
    sed -i -- "s/iphoneos-version/appletvos-version/g" $ninja
done
