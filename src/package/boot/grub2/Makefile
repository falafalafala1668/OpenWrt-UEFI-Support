#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=grub
PKG_CPE_ID:=cpe:/a:gnu:grub2
PKG_VERSION:=2.04
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/grub
PKG_HASH:=e5292496995ad42dabe843a0192cf2a2c502e7ffcc7479398232b10a472df77d

HOST_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=grub2/host

PKG_ASLR_PIE:=0
PKG_SSP:=0

PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/grub2/Default
  CATEGORY:=Boot Loaders
  SECTION:=boot
  TITLE:=GRand Unified Bootloader ($(1))
  URL:=http://www.gnu.org/software/grub/
  DEPENDS:=@TARGET_x86
  VARIANT:=$(1)
endef

Package/grub2=$(call Package/grub2/Default,pc)
Package/grub2-efi=$(call Package/grub2/Default,efi)

define Package/grub2-editenv
  CATEGORY:=Utilities
  SECTION:=utils
  SUBMENU:=Boot Loaders
  TITLE:=Grub2 Environment editor
  URL:=http://www.gnu.org/software/grub/
  DEPENDS:=@TARGET_x86
  VARIANT:=pc
endef

define Package/grub2-editenv/description
	Edit grub2 environment files.
endef

HOST_BUILD_PREFIX := $(STAGING_DIR_HOST)

CONFIGURE_VARS += \
	grub_build_mkfont_excuse="don't want fonts"

CONFIGURE_ARGS += \
	--target=$(REAL_GNU_TARGET_NAME) \
	--disable-werror \
	--disable-nls \
	--disable-device-mapper \
	--disable-libzfs \
	--disable-grub-mkfont \
	--with-platform=$(BUILD_VARIANT)

HOST_CONFIGURE_VARS += \
	grub_build_mkfont_excuse="don't want fonts"

HOST_CONFIGURE_ARGS += \
	--disable-grub-mkfont \
	--target=$(REAL_GNU_TARGET_NAME) \
	--sbindir="$(STAGING_DIR_HOST)/bin" \
	--disable-werror \
	--disable-libzfs \
	--disable-nls \
	--with-platform=none

HOST_MAKE_FLAGS += \
	TARGET_RANLIB=$(TARGET_RANLIB) \
	LIBLZMA=$(STAGING_DIR_HOST)/lib/liblzma.a

TARGET_CFLAGS := $(filter-out -fno-plt,$(TARGET_CFLAGS))

define Host/Configure
	$(SED) 's,(RANLIB),(TARGET_RANLIB),' $(HOST_BUILD_DIR)/grub-core/Makefile.in
	$(Host/Configure/Default)
endef

define Package/grub2/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/grub-bios-setup $(1)/usr/sbin/
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)/grub2
	$(CP) $(PKG_BUILD_DIR)/grub-core/boot.img $(STAGING_DIR_IMAGE)/grub2/
	$(CP) $(PKG_BUILD_DIR)/grub-core/cdboot.img $(STAGING_DIR_IMAGE)/grub2/
endef

define Package/grub2-efi/install
	sed 's#msdos1#gpt1#g' ./files/grub-early.cfg > $(PKG_BUILD_DIR)/grub-early.cfg
	test -d "$(STAGING_DIR_IMAGE)" || mkdir -p "$(STAGING_DIR_IMAGE)/grub2"
	$(STAGING_DIR_HOST)/bin/grub-mkimage \
		-d $(PKG_BUILD_DIR)/grub-core \
		-p /boot/grub \
		-O $(CONFIG_ARCH)-efi \
		-c $(PKG_BUILD_DIR)/grub-early.cfg \
		-o $(STAGING_DIR_IMAGE)/grub2/boot$(if $(CONFIG_x86_64),x64,ia32).efi \
		at_keyboard boot chain configfile fat linux ls part_gpt reboot serial efi_gop efi_uga
endef

define Package/grub2-editenv/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/grub-editenv $(1)/usr/sbin/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,grub2))
$(eval $(call BuildPackage,grub2-efi))
$(eval $(call BuildPackage,grub2-editenv))
