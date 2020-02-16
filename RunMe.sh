#!/bin/sh
restore_patch() {
    if [ -f .UEFIDone ]; then
      echo "###### Restoring Patches ######"
      patch -REp0 < $(currentdir)/Config-images.patch
      patch -REp0 < $(currentdir)/common.patch
      patch -REp0 < $(currentdir)/Image.patch
      patch -REp0 < $(currentdir)/tools.patch
      patch -REp0 < $(currentdir)/Grub-Makefile.patch

      rm -rf package/boot/grub2/grub2-efi package/boot/grub2/grub2
    #  rm -rf package/libs/gnuefi package/utils/efi* package/utils/sbsigntool
      rm -rf tools/gptfdisk tools/popt
      rm -rf target/linux/x86/image/gen_image_efi.sh
      rm -rf .UEFIDone
    else
        echo "Already Restored."
    fi
}

apply_patch() {
  if [ ! -f .UEFIDone ]; then
      echo "###### Applying patches ######"
      patch -p0 < $(currentdir)/Config-images.patch
      patch -p0 < $(currentdir)/common.patch
      patch -p0 < $(currentdir)/Image.patch
      patch -p0 < $(currentdir)/tools.patch
      patch -p0 < $(currentdir)/Grub-Makefile.patch

      echo "Copying necessary files..."
      cp -r $(currentdir)/src/package/boot/grub2/*
    #  cp -r $(currentdir)/src/package/libs/gnu-efi package/libs/
    #  cp -r $(currentdir)/src/package/utils/sbsigntool package/utils/
    #  cp -r $(currentdir)/src/package/utils/efi* package/utils/
      cp -r $(currentdir)/src/package/boot/grub2/grub2 package/boot/grub2/
      cp -r $(currentdir)/src/target/linux/x86/image/gen_image_efi.sh target/linux/x86/image/
      cp -r $(currentdir)/src/tools/gptfdisk tools/
      cp -r $(currentdir)/src/tools/popt tools
      touch .UEFIDone
      echo "Done."
  else
      echo "Already Patched."
  fi
}

update() {
  echo "###### Updating Patches ######"
  cd $(currentdir)
  git pull
  cd ..

}

generate_patch() {
  echo "###### Generating Patches ######"
  echo "Updating Openwrt source..."
  git pull
  diff -Naur config/Config-images.in $(currentdir)/src/config/Config-images.in > $(currentdir)/Config-images.patch
  diff -Naur package/base-files/files/lib/upgrade/common.sh $(currentdir)/src/package/base-files/files/lib/upgrade/common.sh > $(currentdir)/common.patch
  diff -Naur package/boot/grub2/Makefile $(currentdir)/src/package/boot/grub2/Makefile > $(currentdir)/Grub-Makefile.patch
  diff -Naur tools/Makefile $(currentdir)/src/tools/Makefile > $(currentdir)/tools.patch
  diff -Naur target/linux/x86/image/Makefile $(currentdir)/src/target/linux/x86/image/Makefile > $(currentdir)/Image.patch
}

currentdir() {
    SOURCE="$0"
    while [ -h "$SOURCE"  ]; do # resolve $SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    echo ${DIR##*/} 2>/dev/null
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
  restore_patch
  update
  apply_patch
  ;;
  *)
  echo "Please add parameter. Apply or Restore\n e.g: ./$(currentdir)/RunMe.sh apply"
  ;;
esac
