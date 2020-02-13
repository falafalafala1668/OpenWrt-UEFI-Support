#!/bin/sh
restore_patch() {
  echo "###### Restoring Patches ######"
  patch -REp0 < OpenWrt-UEFI-Support/Config-images.patch
  patch -REp0 < OpenWrt-UEFI-Support/common.patch
  patch -REp0 < OpenWrt-UEFI-Support/sysupgrade.patch
  patch -REp0 < OpenWrt-UEFI-Support/platform.patch
  patch -REp0 < OpenWrt-UEFI-Support/Image.patch
  patch -REp0 < OpenWrt-UEFI-Support/tools.patch
  patch -REp0 < OpenWrt-UEFI-Support/Grub-Makefile.patch

  rm -rf package/boot/grub2/grub2-efi package/boot/grub2/grub2
  rm -rf tools/gptfdisk tools/popt
  rm -rf target/linux/x86/image/gen_image_efi.sh
}

apply_patch() {
  echo "###### Applying patches ######"
  patch -p0 < OpenWrt-UEFI-Support/Config-images.patch
  patch -p0 < OpenWrt-UEFI-Support/common.patch
  patch -p0 < OpenWrt-UEFI-Support/sysupgrade.patch
  patch -p0 < OpenWrt-UEFI-Support/platform.patch
  patch -p0 < OpenWrt-UEFI-Support/Image.patch
  patch -p0 < OpenWrt-UEFI-Support/tools.patch
  patch -p0 < OpenWrt-UEFI-Support/Grub-Makefile.patch

  cp -r OpenWrt-UEFI-Support/src/package/boot/grub2/grub2-efi package/boot/grub2/
  cp -r OpenWrt-UEFI-Support/src/package/boot/grub2/grub2 package/boot/grub2/
  cp -r OpenWrt-UEFI-Support/src/target/linux/x86/image/gen_image_efi.sh target/linux/x86/image/
  cp -r OpenWrt-UEFI-Support/src/tools/gptfdisk tools/
  cp -r OpenWrt-UEFI-Support/src/tools/popt tools/
}

update() {
  echo "###### Updating Patches ######"
  cd OpenWrt-UEFI-Support
  git pull
  cd ..

}

generate_patch() {
  echo "###### Generating Patches ######"
  diff -Naur config/Config-images.in OpenWrt-UEFI-Support/src/config/Config-images.in > OpenWrt-UEFI-Support/Config-images.patch
  diff -Naur package/base-files/files/lib/upgrade/common.sh OpenWrt-UEFI-Support/src/package/base-files/files/lib/upgrade/common.sh > OpenWrt-UEFI-Support/common.patch
  diff -Naur package/base-files/files/sbin/sysupgrade OpenWrt-UEFI-Support/src/package/base-files/files/sbin/sysupgrade > OpenWrt-UEFI-Support/sysupgrade.patch
  diff -Naur package/boot/grub2/Makefile OpenWrt-UEFI-Support/src/package/boot/grub2/Makefile > OpenWrt-UEFI-Support/Grub-Makefile.patch
  diff -Naur tools/Makefile OpenWrt-UEFI-Support/src/tools/Makefile > OpenWrt-UEFI-Support/tools.patch
  diff -Naur target/linux/x86/base-files/lib/upgrade/platform.sh OpenWrt-UEFI-Support/src/target/linux/x86/base-files/lib/upgrade/platform.sh > OpenWrt-UEFI-Support/platform.patch
  diff -Naur target/linux/x86/image/Makefile OpenWrt-UEFI-Support/src/target/linux/x86/image/Makefile > OpenWrt-UEFI-Support/Image.patch
}

case "$1" in
  "apply")
  apply_patch
  ;;
  "restore")
  restore_patch
  ;;
  "generate")
  generate_patch
  ;;
  "update")
  update
  restore_patch
  apply_patch
  ;;
  *)
  echo "Please add parameter. Apply or Restore\n e.g: ./OpenWrt-UEFI-Support/RunMe.sh apply"
  ;;
esac
