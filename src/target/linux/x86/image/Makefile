#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

export PATH=$(TARGET_PATH):/sbin

GRUB2_MODULES = biosdisk boot chain configfile ext2 linux ls part_msdos reboot serial vga
GRUB2_MODULES_ISO = biosdisk boot chain configfile iso9660 linux ls part_msdos reboot serial vga
GRUB_TERMINALS =
GRUB_SERIAL_CONFIG =
GRUB_TERMINAL_CONFIG =
GRUB_CONSOLE_CMDLINE =
GRUB_ROOT = hd0,msdos1

USE_ATKBD = generic 64

ifneq ($(strip $(foreach subtarget,$(USE_ATKBD),$(CONFIG_TARGET_x86_$(subtarget)))),)
  GRUB2_MODULES += at_keyboard
  GRUB2_MODULES_ISO += at_keyboard
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

SIGNATURE:=$(shell perl -e 'printf("%08x", rand(0xFFFFFFFF))')
EFI_SIGNATURE:=$(strip $(shell uuidgen | sed "s/[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]$$/0002/" | tr '[a-z]' '[A-Z]'))
ROOTPART:=$(call qstrip,$(CONFIG_TARGET_ROOTFS_PARTNAME))
ROOTPART:=$(if $(ROOTPART),$(ROOTPART),PARTUUID=$(SIGNATURE)-02)
EFI_ROOTPART:=$(call qstrip,$(CONFIG_TARGET_ROOTFS_PARTNAME))
EFI_ROOTPART:=$(if $(EFI_ROOTPART),$(EFI_ROOTPART),PARTUUID=$(EFI_SIGNATURE))
GRUB_TIMEOUT:=$(call qstrip,$(CONFIG_GRUB_TIMEOUT))

ifneq ($(CONFIG_TARGET_x86_xen_domu),)
  GRUB_ROOT = xen/xvda,msdos1
endif
BOOTOPTS:=$(call qstrip,$(CONFIG_GRUB_BOOTOPTS))

define Image/cmdline/ext4
  root=$(ROOTPART) rootfstype=ext4 rootwait
endef

define Image/cmdline/squashfs
  root=$(ROOTPART) rootfstype=squashfs rootwait
endef

# UEFI Start
ifneq ($(CONFIG_EFI_IMAGES),)

define Image/cmdline/efi
$(subst $(SIGNATURE)-02,$2,$(call Image/cmdline/$(1)))
endef

define Image/Build/efi

	# Build the efi grub version
	rm -rf $(KDIR)/grub2.efi/ || true
	$(INSTALL_DIR) $(KDIR)/grub2.efi/efi/boot/

	# Copy the EFI grub binary
	$(CP) $(PKG_BUILD_DIR)grub-efi-2.02/boot$(if $(CONFIG_x86_64),x64,ia32).efi $(KDIR)/grub2.efi/efi/boot/

	$(INSTALL_DIR) $(KDIR)/grub2.efi/boot/grub $(KDIR)/grub2
	$(CP) $(KDIR)/bzImage $(KDIR)/grub2.efi/boot/vmlinuz
	echo '(hd0) $(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.img' > $(KDIR)/grub2/device.map
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@GPT_ROOTPART@#$(call Image/cmdline/efi,$(1),$(EFI_SIGNATURE))#g' \
		-e 's#@CMDLINE@#$(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE)#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		./grub-efi.cfg > $(KDIR)/grub2.efi/boot/grub/grub.cfg

	SIGNATURE="$(EFI_SIGNATURE)" PATH="$(TARGET_PATH)" ./gen_image_efi.sh \
		$(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.img \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $(KDIR)/grub2.efi \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(KDIR)/root.$(1) \
		256

	# Convert the MBR partition to GPT and set EFI ROOTFS signature
	dd if=/dev/zero of="$(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.img" bs=512 count=34 conv=notrunc oflag=append
	sgdisk -g "$(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.img"
	sgdisk -t 1:EF00 "$(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.img"
	sgdisk -u 2:$(EFI_SIGNATURE) "$(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.img"

	echo -e -n "\xeb\x63\x99" | dd of="$(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.img" bs=4 conv=notrunc

endef
endif

ifneq ($(CONFIG_GRUB_IMAGES),)
  define Image/Build/grub2
	# left here because the image builder doesnt need these
	$(INSTALL_DIR) $(KDIR)/root.grub/boot/grub $(KDIR)/grub2
	$(CP) $(KDIR)/bzImage $(KDIR)/root.grub/boot/vmlinuz
	grub-mkimage \
		-p /boot/grub \
		-d $(STAGING_DIR_HOST)/lib/grub/i386-pc \
		-o $(KDIR)/grub2/core.img \
		-O i386-pc \
		-c ./grub-early.cfg \
		$(GRUB2_MODULES)
		$(CP) $(STAGING_DIR_HOST)/lib/grub/i386-pc/*.img $(KDIR)/grub2/
	echo '(hd0) $(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img' > $(KDIR)/grub2/device.map
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@CMDLINE@#$(strip $(call Image/cmdline/$(1)) $(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE))#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		-e 's#@ROOT@#$(GRUB_ROOT)#g' \
		./grub.cfg > $(KDIR)/root.grub/boot/grub/grub.cfg
	-$(CP) $(STAGING_DIR_ROOT)/boot/. $(KDIR)/root.grub/boot/
	PADDING="$(CONFIG_TARGET_IMAGES_PAD)" SIGNATURE="$(SIGNATURE)" PATH="$(TARGET_PATH)" $(SCRIPT_DIR)/gen_image_generic.sh \
		$(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $(KDIR)/root.grub \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(KDIR)/root.$(1) \
		256
	grub-bios-setup \
		--device-map="$(KDIR)/grub2/device.map" \
		-d "$(KDIR)/grub2" \
		-r "hd0,msdos1" \
		"$(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img"
  endef
endif

define Image/Build/squashfs
	dd if=/dev/zero bs=128k count=1 >> $(KDIR)/root.squashfs
endef

define Image/Build/iso
	$(INSTALL_DIR) $(KDIR)/root.grub/boot/grub $(KDIR)/grub2
	$(CP) $(KDIR)/bzImage $(KDIR)/root.grub/boot/vmlinuz
	grub-mkimage \
		-p /boot/grub \
		-d $(STAGING_DIR_HOST)/lib/grub/i386-pc \
		-o $(KDIR)/grub2/eltorito.img \
		-O i386-pc \
		-c ./grub-early.cfg \
		$(GRUB2_MODULES_ISO)
	cat \
		$(STAGING_DIR_HOST)/lib/grub/i386-pc/cdboot.img \
		$(KDIR)/grub2/eltorito.img \
		> $(KDIR)/root.grub/boot/grub/eltorito.img
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@CMDLINE@#root=/dev/sr0 rootfstype=iso9660 rootwait $(strip $(call Image/cmdline/$(1)) $(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE))#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		./grub-iso.cfg > $(KDIR)/root.grub/boot/grub/grub.cfg
	-$(CP) $(STAGING_DIR_ROOT)/boot/. $(KDIR)/root.grub/boot/
	mkisofs -R -b boot/grub/eltorito.img -no-emul-boot -boot-info-table \
		-o $(KDIR)/root.iso $(KDIR)/root.grub $(TARGET_DIR)
endef

ifneq ($(CONFIG_VDI_IMAGES),)
  define Image/Build/vdi
	rm $(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).vdi || true
	qemu-img convert -f raw -O vdi \
		$(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img \
		$(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).vdi
	# XXX: VBoxManage insists on setting perms to 0600
	chmod 0644 $(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).vdi
  endef
  define Image/Build/vdi_efi
	rm $(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.vdi || true
	qemu-img convert -f raw -O vdi \
		$(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.img \
		$(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.vdi
	# XXX: VBoxManage insists on setting perms to 0600
	chmod 0644 $(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.vdi
  endef
endif

ifneq ($(CONFIG_VMDK_IMAGES),)
  define Image/Build/vmdk
	rm $(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).vmdk || true
	qemu-img convert -f raw -O vmdk \
		$(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img \
		$(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).vmdk
  endef
  define Image/Build/vmdk_efi
	rm $(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.vmdk || true
	qemu-img convert -f raw -O vmdk \
		$(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.img \
		$(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.vmdk
  endef
endif

define Image/Build/gzip
	gzip -f9n $(BIN_DIR)/$(IMG_PREFIX)-rootfs-$(1).img
ifneq ($(CONFIG_GRUB_IMAGES),)
	gzip -f9n $(BIN_DIR)/$(IMG_PREFIX)-combined-$(1).img
endif
ifneq ($(CONFIG_EFI_IMAGES),)
	gzip -f9n $(BIN_DIR)/$(IMG_PREFIX)-$(1)-combined-efi.img
endif
endef

ifneq ($(CONFIG_TARGET_IMAGES_GZIP),)
  define Image/Build/gzip/ext4
	$(call Image/Build/gzip,ext4)
  endef
  define Image/Build/gzip/squashfs
	$(call Image/Build/gzip,squashfs)
  endef
endif

define Image/BuildKernel
	$(CP) $(KDIR)/bzImage $(BIN_DIR)/$(IMG_PREFIX)-vmlinuz
endef

define Image/Prepare
	$(call Image/Prepare/grub2)
endef

define Image/Build/Initramfs
	$(CP) $(KDIR)/bzImage-initramfs $(BIN_DIR)/$(IMG_PREFIX)-ramfs.bzImage
endef

define Image/Build
	$(call Image/Build/$(1))
  ifneq ($(1),iso)
    ifneq ($(CONFIG_GRUB_IMAGES),)
	$(call Image/Build/grub2,$(1))
	$(call Image/Build/vdi,$(1))
	$(call Image/Build/vmdk,$(1))
    endif
    ifneq ($(CONFIG_EFI_IMAGES),)
	$(call Image/Build/efi,$(1))
	$(call Image/Build/vdi_efi,$(1))
	$(call Image/Build/vmdk_efi,$(1))
    endif
	$(CP) $(KDIR)/root.$(1) $(BIN_DIR)/$(IMG_PREFIX)-rootfs-$(1).img
  else
	$(CP) $(KDIR)/root.iso $(BIN_DIR)/$(IMG_PREFIX).iso
  endif
	$(CP) $(KDIR)/bzImage $(BIN_DIR)/$(IMG_PREFIX)-vmlinuz
	$(call Image/Build/gzip/$(1))
ifeq ($(CONFIG_TARGET_ROOTFS_INITRAMFS),y)
	$(call Image/Build/Initramfs)
endif
endef

$(eval $(call BuildImage))
