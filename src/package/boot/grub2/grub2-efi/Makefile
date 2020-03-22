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

define Host/Install
	$(call Host/Install/Default)

	$(INSTALL_DIR) $(STAGING_DIR_HOST)/lib/grub/grub2.efi/efi/boot/
	$(STAGING_DIR_HOST)/bin/grub-mkimage-efi \
		-d $(STAGING_DIR_HOST)/lib/grub/x86_64-efi \
		-p /efi/boot \
		-O x86_64-efi \
		-c ./files/grub-early.cfg \
		-o $(STAGING_DIR_HOST)/lib/grub/grub2.efi/efi/boot/bootx64.efi \
		at_keyboard boot chain configfile ext2 linux ls part_msdos reboot serial part_gpt part_msdos search fat exfat ext2 efi_gop efi_uga gfxterm

	# $(INSTALL_DIR) $(STAGING_DIR_HOST)/lib/grub/grub2.efi-iso/efi/boot/
	# $(STAGING_DIR_HOST)/bin/grub-mkimage-efi \
	# 	-d $(STAGING_DIR_HOST)/lib/grub/x86_64-efi \
	# 	-p /efi/boot \
	# 	-O x86_64-efi \
	# 	-c ./files/grub-early.cfg \
	# 	-o $(STAGING_DIR_HOST)/lib/grub/grub2.efi/efi/boot/bootx64.efi \
	# 	at_keyboard boot chain configfile iso9660 linux ls part_gpt part_msdos reboot serial search fat exfat ext2 efi_gop efi_uga gfxterm

endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,grub2-efi))
