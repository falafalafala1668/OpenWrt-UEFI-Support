#!/bin/sh
if [ "$1" = apply ]; then
  patch -p0 < openwrt-uefi-support/Config-images.patch
  patch -p0 < openwrt-uefi-support/common.patch
  patch -p0 < openwrt-uefi-support/Image.patch
  patch -p0 < openwrt-uefi-support/tools.patch
  mv package/boot/grub2/Makefile package/boot/grub2/Makefile.bak
  cp -r openwrt-uefi-support/src/package/boot/grub2/* package/boot/grub2/
  cp -r openwrt-uefi-support/src/target/linux/x86/image/gen_image_efi.sh target/linux/x86/image/
  cp -r openwrt-uefi-support/src/tools/gptfdisk tools/
  cp -r openwrt-uefi-support/src/tools/popt tools/
elif [ "$1" = "restore" ]; then
  patch -p0 -R < openwrt-uefi-support/Config-images.patch
  patch -p0 -R < openwrt-uefi-support/common.patch
  patch -p0 -R < openwrt-uefi-support/Image.patch
  patch -p0 -R < openwrt-uefi-support/tools.patch
  rm -rf package/boot/grub2/grub2-efi package/boot/grub2/common.mk
  rm -rf tools/gptfdisk tools/popt
  rm -rf target/linux/x86/image/gen_image_efi.sh
  mv package/boot/grub2/Makefile.bak package/boot/grub2/Makefile
else
  echo "Please add parameter. Apply or Restore\n e.g: ./openwrt-uefi-support/RunMe.sh apply"
fi
