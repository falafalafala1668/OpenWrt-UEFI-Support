include $(TOPDIR)/rules.mk

PKG_NAME:=efibootmgr
PKG_VERSION:=15
PKG_LICENSE:=GPL-2.0+
PKG_MAINTAINER:=Alif M. Ahmad <alive4ever@live.com>
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rhboot/efibootmgr.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=2e018c08b92c800961ec010a6a4eeb34e8f3faa0
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DEPENDS:= efivar

MAKE_FLAGS:= \
	 CROSS_COMPILE="$(TARGET_CROSS)" \
	 CFLAGS="$(TARGET_CFLAGS)" \
	 CPPFLAGS="$(TARGET_CPPFLAGS)" \
	 PCDIR=$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig \

include $(INCLUDE_DIR)/package.mk

define Package/efibootmgr
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:= +efivar
  TITLE:=Manipulate EFI boot entries
endef

define Package/efibootmgr/description
  This applications allows user to create and destroy EFI boot entries, change
  the boot order, change the next running boot option, and more.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(MAKE_FLAGS) \
		EFIDIR=/boot/efi
endef

define Package/efibootmgr/install
	$(MAKE) -C $(PKG_BUILD_DIR) prefix=/usr libdir=/usr/lib DESTDIR=$(PKG_INSTALL_DIR) EFIDIR=/boot/efi install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/efibootmgr $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/efibootdump $(1)/usr/sbin
endef

$(eval $(call BuildPackage,efibootmgr))
