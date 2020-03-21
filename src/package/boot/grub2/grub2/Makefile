include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=grub

include ../Makefile

PKG_BUILD_DEPENDS:=grub2/host

define Package/grub2
$(call Package/grub2/Default)
endef

define Package/grub2-editenv
  CATEGORY:=Utilities
  SECTION:=utils
  TITLE:=Grub2 Environment editor
  URL:=http://www.gnu.org/software/grub/
  DEPENDS:=@TARGET_x86
endef

define Package/grub2-editenv/description
	Edit grub2 environment files.
endef

define Host/Install
	$(call Host/Install/Default)

	$(INSTALL_DIR) $(STAGING_DIR_HOST)/lib/grub/grub2-generic
	$(STAGING_DIR_HOST)/bin/grub-mkimage \
		-d $(STAGING_DIR_HOST)/lib/grub/i386-pc \
		-p /boot/grub \
		-O i386-pc \
		-c ../files/grub-early.cfg \
		-o $(STAGING_DIR_HOST)/lib/grub/grub2-generic/core.img \
		at_keyboard biosdisk boot chain configfile ext2 linux ls part_msdos reboot serial vga

	$(INSTALL_DIR) $(STAGING_DIR_HOST)/lib/grub/grub2-iso
	$(STAGING_DIR_HOST)/bin/grub-mkimage \
		-d $(STAGING_DIR_HOST)/lib/grub/i386-pc \
		-p /boot/grub \
		-O i386-pc \
		-c ../files/grub-early.cfg \
		-o $(STAGING_DIR_HOST)/lib/grub/grub2-iso/eltorito.img \
		at_keyboard biosdisk boot chain configfile iso9660 linux ls part_msdos reboot serial vga

	$(INSTALL_DIR) $(STAGING_DIR_HOST)/lib/grub/grub2-legacy
	$(STAGING_DIR_HOST)/bin/grub-mkimage \
		-d $(STAGING_DIR_HOST)/lib/grub/i386-pc \
		-p /boot/grub \
		-O i386-pc \
		-c ../files/grub-early.cfg \
		-o $(STAGING_DIR_HOST)/lib/grub/grub2-legacy/core.img \
		biosdisk boot chain configfile ext2 linux ls part_msdos reboot serial vga
endef

# define Package/grub2/install
# 	$(INSTALL_DIR) $(1)/usr/sbin
# 	$(INSTALL_BIN) $(PKG_BUILD_DIR)/grub-bios-setup $(1)/usr/sbin/
# endef

define Package/grub2-editenv/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/grub-editenv $(1)/usr/sbin/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,grub2))
$(eval $(call BuildPackage,grub2-editenv))
