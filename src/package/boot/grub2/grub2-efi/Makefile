include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=grub-efi

include ../Makefile

TAR_OPTIONS:= --transform 's/grub-${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}/' $(TAR_OPTIONS)

PKG_BUILD_DEPENDS:=grub2-efi/host

CONFIGURE_ARGS += --with-platform=efi
HOST_CONFIGURE_ARGS += --with-platform=efi --program-suffix=-efi
HOST_BUILD_DIR := $(BUILD_DIR_HOST)/$(PKG_NAME)-$(PKG_VERSION)

define Package/grub2-efi
  $(call Package/grub2/Default)
  HIDDEN:=1
  TITLE += (with EFI support)
endef

define Package/grub2-efi/install
	sed 's#msdos1#gpt1#g' ../files/grub-early.cfg > $(PKG_BUILD_DIR)/grub-early.cfg
	test -d "$(PKG_BUILD_DIR)" || mkdir "$(PKG_BUILD_DIR)"
	$(STAGING_DIR_HOST)/bin/grub-mkimage \
		-d $(PKG_BUILD_DIR)/grub-core \
		-p /boot/grub \
		-O $(CONFIG_ARCH)-efi \
		-c $(PKG_BUILD_DIR)/grub-early.cfg \
		-o $(PKG_BUILD_DIR)/boot$(if $(CONFIG_x86_64),x64,ia32).efi \
		boot chain configfile ext2 linux ls part_msdos reboot serial part_gpt part_msdos search fat exfat ext2 efi_gop efi_uga gfxterm
endef


$(eval $(call HostBuild))
$(eval $(call BuildPackage,grub2-efi))
