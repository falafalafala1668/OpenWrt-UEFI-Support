#!/bin/sh
restore_patch() {
  patch -REp0 < OpenWrt-UEFI-Support/Config-images.patch
#  patch -p0 < OpenWrt-UEFI-Support/common.patch
  patch -REp0 < OpenWrt-UEFI-Support/Image.patch
  patch -REp0 < OpenWrt-UEFI-Support/tools.patch
  patch -REp0 < OpenWrt-UEFI-Support/Grub-Makefile.patch
}

update() {
  echo "###### Updating patches ######"
  cd OpenWrt-UEFI-Support
  git pull
  cd ..
}

generate_patch() {
  diff -Naur package/boot/grub2/Makefile OpenWrt-UEFI-Support/src/package/boot/grub2/Makefile > OpenWrt-UEFI-Support/Grub-Makefile.patch
  diff -Naur config/Config-images.in OpenWrt-UEFI-Support/src/config/Config-images.in > OpenWrt-UEFI-Support/Config-images.patch
  diff -Naur tools/Makefile OpenWrt-UEFI-Support/src/tools/Makefile > OpenWrt-UEFI-Support/tools.patch
  diff -Naur target/linux/x86/image/Makefile OpenWrt-UEFI-Support/src/target/linux/x86/image/Makefile > OpenWrt-UEFI-Support/Image.patch
}

case "$1" in
  "apply")
  echo "###### Applying patches ######"
  patch -p0 < OpenWrt-UEFI-Support/Config-images.patch
#  patch -p0 < OpenWrt-UEFI-Support/common.patch
  patch -p0 < OpenWrt-UEFI-Support/Image.patch
  patch -p0 < OpenWrt-UEFI-Support/tools.patch
  patch -p0 < OpenWrt-UEFI-Support/Grub-Makefile.patch
  mv package/boot/grub2/patches/400-R_X86_64_PLT32.patch package/boot/grub2/patches/400-R_X86_64_PLT32.patch.bak
  cp -r OpenWrt-UEFI-Support/src/package/boot/grub2/grub2-efi package/boot/grub2/
  cp -r OpenWrt-UEFI-Support/src/package/boot/grub2/grub2 package/boot/grub2/
  cp -r OpenWrt-UEFI-Support/src/target/linux/x86/image/gen_image_efi.sh target/linux/x86/image/
  cp -r OpenWrt-UEFI-Support/src/tools/gptfdisk tools/
  cp -r OpenWrt-UEFI-Support/src/tools/popt tools/
  ;;
  "restore")
  restore_patch
  mv package/boot/grub2/patches/400-R_X86_64_PLT32.patch.bak package/boot/grub2/patches/400-R_X86_64_PLT32.patch
  rm -rf package/boot/grub2/grub2-efi package/boot/grub2/grub2
  rm -rf tools/gptfdisk tools/popt
  rm -rf target/linux/x86/image/gen_image_efi.sh
  ;;
  "generate")
  generate_patch
  ;;
  "update")
  update
  ;;
  *)
  echo "Please add parameter. Apply or Restore\n e.g: ./OpenWrt-UEFI-Support/RunMe.sh apply"
  ;;
esac
