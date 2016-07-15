#!/bin/bash

###
#
#            Name:  create_pkg.sh
#     Description:  This script automatically creates a pkg file that you can
#                   use to deploy the Casper Check script/LaunchDaemon
#                   pair to your managed clients.
#   Ripped off by:  David West 
#          Author:  Elliot Jordan <elliot@lindegroup.com>
#         Created:  2015-09-18
#   Last Modified:  2016-07-15
#         Version:  1.0
#
###

cd "$(dirname "$0")"

if [[ ! -f "./script/caspercheck.sh" ||
      ! -f "./LaunchDaemon/com.company.caspercheck.plist" ||
      ! -f "./pkg_scripts/postinstall" ]]; then
    echo "[ERROR] At least one required file is missing. Ensure that the following files exist in the correct folders:"
    echo "    script/caspercheck.sh"
    echo "    LaunchDaemon/com.company.caspercheck.plist"
    echo "    pkg_scripts/postinstall"
    exit 1
fi

script_md5=$(md5 -q ./script/caspercheck.sh)
if [[ "$script_md5" == "7b1cc4afd0f53484ca772c0ac06ee786" ]]; then
    echo "[ERROR] It looks like you haven't customized the caspercheck.sh script yet. Please do that now, then run create_pkg.sh again."
    exit 2
fi

echo "Great! Sounds like you're good to go."

TMP_PKGROOT="/private/tmp/caspercheck/pkgroot"
echo "Building package root in /tmp folder..."
mkdir -p "$TMP_PKGROOT/Library/LaunchDaemons" "$TMP_PKGROOT/Library/Scripts"

echo "Copying the files to the package root..."
cp "./LaunchDaemon/com.company.caspercheck.plist" "$TMP_PKGROOT/Library/LaunchDaemons/"
cp "./script/caspercheck.sh" "$TMP_PKGROOT/Library/Scripts/"

echo "Setting mode and permissions..."
chown -R root:wheel "$TMP_PKGROOT"
chmod +x "$TMP_PKGROOT/Library/Scripts/caspercheck.sh"

echo "Building the package..."
pkgbuild --root "/tmp/caspercheck/pkgroot" \
         --scripts "./pkg_scripts" \
         --identifier "com.company.caspercheck.plist" \
         --version "2.0" \
         --install-location "/" \
         "./caspercheck-$(date "+%Y%m%d").pkg"

exit 0
