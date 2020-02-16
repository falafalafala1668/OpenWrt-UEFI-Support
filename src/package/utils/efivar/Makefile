include $(TOPDIR)/rules.mk

PKG_NAME:=efivar
PKG_VERSION:=34
PKG_LICENSE:=LGPL-2.1+
PKG_MAINTAINER:=Alif M. Ahmad <alive4ever@live.com>
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rhboot/efivar.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=97e116549ac4d8fe44cf1db5e100808a36cebeb1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

MAKE_FLAGS:= \
	 CROSS_COMPILE="$(TARGET_CROSS)" \
	 CFLAGS="$(TARGET_CFLAGS)" \
	 CPPFLAGS="$(TARGET_CPPFLAGS)" \
	 PCDIR=$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig

include $(INCLUDE_DIR)/package.mk

define Package/efivar
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:= +libpopt +kmod-fs-efivarfs
  TITLE:=Manage UEFI variables
endef

define Package/efivar/description
   efivar provides a simple command line interface to access UEFI variable facility.
endef

define Build/Compile
	+$(MAKE) -C $(PKG_BUILD_DIR) \
		$(MAKE_FLAGS)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/include/efivar
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/efivar $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libefiboot.so.1.34 $(1)/usr/lib
	ln -sf libefiboot.so.1.34 $(1)/usr/lib/libefiboot.so.1
	ln -sf libefiboot.so.1.34 $(1)/usr/lib/libefiboot.so
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libefivar.so.1.34 $(1)/usr/lib
	ln -sf libefivar.so.1.34 $(1)/usr/lib/libefivar.so.1
	ln -sf libefivar.so.1.34 $(1)/usr/lib/libefivar.so
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig
endef

define Package/efivar/install
	$(MAKE) -C $(PKG_BUILD_DIR) prefix=/usr libdir=/usr/lib DESTDIR=$(PKG_INSTALL_DIR) install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/efivar $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libefiboot.so.1.34 $(1)/usr/lib
	ln -sf libefiboot.so.1.34 $(1)/usr/lib/libefiboot.so.1
	ln -sf libefiboot.so.1.34 $(1)/usr/lib/libefiboot.so
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libefivar.so.1.34 $(1)/usr/lib
	ln -sf libefivar.so.1.34 $(1)/usr/lib/libefivar.so.1
	ln -sf libefivar.so.1.34 $(1)/usr/lib/libefivar.so
endef

$(eval $(call BuildPackage,efivar))
