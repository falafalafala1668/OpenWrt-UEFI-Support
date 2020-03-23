#
# Copyright (C) 2006-2020 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

GRUB2_VARIANT =
GRUB_TERMINALS =
GRUB_SERIAL_CONFIG =
GRUB_TERMINAL_CONFIG =
GRUB_CONSOLE_CMDLINE =

ifneq ($(strip $(foreach subtarget,$(USE_ATKBD),$(CONFIG_TARGET_x86_$(subtarget)))),)
  GRUB2_VARIANT := generic
else
  GRUB2_VARIANT := legacy
endif

ifneq ($(CONFIG_GRUB_CONSOLE),)
  GRUB_CONSOLE_CMDLINE += console=tty0
  GRUB_TERMINALS += console
endif

GRUB_SERIAL:=$(call qstrip,$(CONFIG_GRUB_SERIAL))

ifneq ($(GRUB_SERIAL),)
  GRUB_CONSOLE_CMDLINE += console=$(GRUB_SERIAL),$(CONFIG_GRUB_BAUDRATE)n8$(if $(CONFIG_GRUB_FLOWCONTROL),r,)
  GRUB_SERIAL_CONFIG := serial --unit=0 --speed=$(CONFIG_GRUB_BAUDRATE) --word=8 --parity=no --stop=1 --rtscts=$(if $(CONFIG_GRUB_FLOWCONTROL),on,off)
  GRUB_TERMINALS += serial
endif

ifneq ($(GRUB_TERMINALS),)
  GRUB_TERMINAL_CONFIG := terminal_input $(GRUB_TERMINALS); terminal_output $(GRUB_TERMINALS)
endif

EFI_SIGNATURE:=$(strip $(shell uuidgen | tr '[a-z]' '[A-Z]'))
ROOTPART:=$(call qstrip,$(CONFIG_TARGET_ROOTFS_PARTNAME))
ROOTPART:=$(if $(ROOTPART),$(ROOTPART),PARTUUID=$(IMG_PART_SIGNATURE)-02)

GRUB_TIMEOUT:=$(call qstrip,$(CONFIG_GRUB_TIMEOUT))
GRUB_TITLE:=$(call qstrip,$(CONFIG_GRUB_TITLE))

BOOTOPTS:=$(call qstrip,$(CONFIG_GRUB_BOOTOPTS))

define Build/efi
	$(CP) $(KDIR)/$(KERNEL_NAME) $@.boot/boot/vmlinuz
	-$(CP) $(STAGING_DIR_ROOT)/boot/. $@.boot/boot/

	SIGNATURE="$(EFI_SIGNATURE)" PATH="$(TARGET_PATH)" ./gen_image_efi.sh \
		$@ \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) \
		1 $@.grub2/kernel.efi \
		256

	# Convert the MBR partition to GPT and set EFI ROOTFS signature
	dd if=/dev/zero of=$@ bs=512 count=34 conv=notrunc oflag=append
	sgdisk -g $@
	sgdisk -t 3:EF00 $@
	sgdisk -u 2:$(EFI_SIGNATURE) $@

	echo -e -n "\xeb\x63\x99" | dd of=$@  bs=4 conv=notrunc
endef

define Build/combined
	$(CP) $(KDIR)/$(KERNEL_NAME) $@.boot/boot/vmlinuz
	-$(CP) $(STAGING_DIR_ROOT)/boot/. $@.boot/boot/
	PADDING="$(CONFIG_TARGET_IMAGES_PAD)" SIGNATURE="$(IMG_PART_SIGNATURE)" $(SCRIPT_DIR)/gen_image_generic.sh \
		$@ \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) \
		256
endef

define Build/grub-efi-config
	rm -fR $@.boot
	$(INSTALL_DIR) $@.boot/boot/grub
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@ROOTPART@#root=PARTUUID=$(EFI_SIGNATURE) rootwait#g' \
		-e 's#@CMDLINE@#$(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE)#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		-e 's#@TITLE@#$(GRUB_TITLE)#g' \
		-e 's#set root.*#search --file /boot/grub/$(IMG_PART_SIGNATURE).cfg --set=root#g' \
		./grub-$(1).cfg > $@.boot/boot/grub/grub.cfg
	$(CP) $@.boot/boot/grub/grub.cfg $@.boot/boot/grub/$(IMG_PART_SIGNATURE).cfg
	echo "search --file /boot/grub/$(IMG_PART_SIGNATURE).cfg --set=root" > $(STAGING_DIR_HOST)/lib/grub/grub2.efi/efi/boot/grub.cfg
	echo "configfile /boot/grub/grub.cfg" >> $(STAGING_DIR_HOST)/lib/grub/grub2.efi/efi/boot/grub.cfg
endef

define Build/grub-config
	rm -fR $@.boot
	$(INSTALL_DIR) $@.boot/boot/grub
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@ROOTPART@#root=$(ROOTPART) rootwait#g' \
		-e 's#@CMDLINE@#$(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE)#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		-e 's#@TITLE@#$(GRUB_TITLE)#g' \
		./grub-$(1).cfg > $@.boot/boot/grub/grub.cfg
endef

define Build/grub-install
	rm -fR $@.grub2
	$(INSTALL_DIR) $@.grub2
	$(CP) $(STAGING_DIR_HOST)/lib/grub/i386-pc/*.img \
		$(STAGING_DIR_HOST)/lib/grub/grub2-$(GRUB2_VARIANT)/core.img \
		$@.grub2/
	echo '(hd0) $@' > $@.grub2/device.map
	$(STAGING_DIR_HOST)/bin/grub-bios-setup \
		-m "$@.grub2/device.map" \
		-d "$@.grub2" \
		-r "hd0,msdos1" \
		$@
endef

define Build/efi-partition
	rm -fR $@.grub2
	$(INSTALL_DIR) $@.grub2
	$(CP) $(STAGING_DIR_HOST)/lib/grub/i386-pc/*.img \
		$(STAGING_DIR_HOST)/lib/grub/grub2-$(GRUB2_VARIANT)/core.img \
		$@.grub2/
	mkfs.fat -C $@.grub2/kernel.efi -S 512 1024
	mcopy -s -i $@.grub2/kernel.efi $(STAGING_DIR_HOST)/lib/grub/grub2.efi/* ::/
endef

define Build/grub-efi-install
	rm $@.grub2/kernel.efi
	echo '(hd0) $@' > $@.grub2/device.map
	$(STAGING_DIR_HOST)/bin/grub-bios-setup-efi \
		--device-map="$@.grub2/device.map" \
		-d "$@.grub2" \
		-r "hd0,gpt1" \
		$@
endef

define Build/iso-efi
	# xxx
endef

define Build/iso
	$(CP) $(KDIR)/$(KERNEL_NAME) $@.boot/boot/vmlinuz
	cat \
		$(STAGING_DIR_HOST)/lib/grub/i386-pc/cdboot.img \
		$(STAGING_DIR_HOST)/lib/grub/grub2-iso/eltorito.img \
		> $@.boot/boot/grub/eltorito.img
	-$(CP) $(STAGING_DIR_ROOT)/boot/. $@.boot/boot/
	mkisofs -R -b boot/grub/eltorito.img -no-emul-boot -boot-info-table \
		-o $@ $@.boot $(TARGET_DIR)
endef

DEVICE_VARS += GRUB2_VARIANT
define Device/Default
  ARTIFACT/image.iso := grub-config iso | iso
  IMAGE/combined.img := append-rootfs | pad-extra 128k | grub-config pc | combined | grub-install
  IMAGE/combined.img.gz := append-rootfs | pad-extra 128k | grub-config pc | combined | grub-install | gzip
  IMAGE/combined.vdi := append-rootfs | pad-extra 128k | grub-config pc | combined | grub-install | qemu-image vdi
  IMAGE/combined.vmdk := append-rootfs | pad-extra 128k | grub-config pc | combined | grub-install | qemu-image vmdk
  IMAGE/combined.qcow2 := append-rootfs | pad-extra 128k | grub-config pc | combined | grub-install | qemu-image qcow2
  IMAGE/uefi-gpt.img := append-rootfs | pad-extra 128k | grub-efi-config pc | efi-partition | efi
  IMAGE/uefi-gpt.img.gz := append-rootfs | pad-extra 128k | grub-efi-config pc | efi-partition | efi | gzip
  IMAGE/uefi-gpt.vdi := append-rootfs | pad-extra 128k | grub-efi-config pc | efi-partition | efi | qemu-image vdi
  IMAGE/uefi-gpt.vmdk := append-rootfs | pad-extra 128k | grub-efi-config pc | efi-partition | efi | qemu-image vmdk
  IMAGE/uefi-gpt.qcow2 := append-rootfs | pad-extra 128k | grub-efi-config pc | efi-partition | efi | qemu-image qcow2
  ifeq ($(CONFIG_TARGET_IMAGES_GZIP),y)
    ifeq ($(CONFIG_GRUB_IMAGES)$(CONFIG_EFI_IMAGES),yy)
		IMAGES := uefi-gpt.img.gz
		IMAGES += combined.img.gz
    else
      ifeq ($(CONFIG_GRUB_IMAGES),y)
        IMAGES := combined.img.gz
      endif
      ifeq ($(CONFIG_EFI_IMAGES),y)
        IMAGES := uefi-gpt.img.gz
      endif
    endif
  else
    ifeq ($(CONFIG_GRUB_IMAGES)$(CONFIG_EFI_IMAGES),yy)
		IMAGES := uefi-gpt.img
		IMAGES += combined.img
    else
	    ifeq ($(CONFIG_GRUB_IMAGES),y)
	      IMAGES := combined.img
	    endif
	    ifeq ($(CONFIG_EFI_IMAGES),y)
	      IMAGES := uefi-gpt.img
	    endif
    endif
  endif
  KERNEL := kernel-bin
  KERNEL_INSTALL := 1
  KERNEL_NAME := bzImage
  ifeq ($(CONFIG_ISO_IMAGES),y)
    ARTIFACTS := image.iso
  endif
  ifeq ($(CONFIG_VDI_IMAGES),y)
    ifeq ($(CONFIG_EFI_IMAGES),y)
      IMAGES += uefi-gpt.vdi
    endif
    ifeq ($(CONFIG_GRUB_IMAGES),y)
      IMAGES += combined.vdi
    endif
  endif
  ifeq ($(CONFIG_VMDK_IMAGES),y)
    ifeq ($(CONFIG_EFI_IMAGES),y)
      IMAGES += uefi-gpt.vmdk
    endif
    ifeq ($(CONFIG_GRUB_IMAGES),y)
      IMAGES += combined.vmdk
    endif
  endif
  ifeq ($(CONFIG_QCOW2_IMAGES),y)
    ifeq ($(CONFIG_EFI_IMAGES),y)
      IMAGES += uefi-gpt.qcow2
    endif
    ifeq ($(CONFIG_GRUB_IMAGES),y)
      IMAGES += combined.qcow2
  endif
  endif
endef

$(eval $(call Image/gzip-ext4-padded-squashfs))

ifeq ($(SUBTARGET),64)
  include 64.mk
endif

ifeq ($(SUBTARGET),generic)
  include generic.mk
endif

ifeq ($(SUBTARGET),legacy)
  include legacy.mk
endif

$(eval $(call BuildImage))
