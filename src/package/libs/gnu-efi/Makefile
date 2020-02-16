include $(TOPDIR)/rules.mk

PKG_NAME:=gnu-efi
PKG_VERSION:=3.0.6
PKG_LICENSE:=GPL-2.0+
PKG_MAINTAINER:=Alif M. Ahmad <alive4ever@live.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/$(PKG_NAME)
PKG_HASH:=21515902d80fbea23328a61d70d3d51a47204abd1507ebfa27550a7b9bf22c91

PKG_INSTALL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS+= INSTALLROOT=$(PKG_INSTALL_DIR) PREFIX="/usr"

MAKE_INSTALL_FLAGS = $(MAKE_FLAGS)

HOST_MAKE_FLAGS+= INSTALLROOT=$(STAGING_DIR_HOST) PREFIX="/"

define Package/gnu-efi
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A library for building UEFI applications using GNU toolchain
  URL:=https://sourceforge.net/projects/gnu-efi
  DEPENDS:=@(x86_64||i386)
endef

define Package/gnu-efi/description
 GNU toolchain for building applications that can run in the
 environment presented by UEFI (Unified Extensible Firmware
 Interface).
endef

define Build/Compile
$(call Build/Compile/Default,mkvars)
$(call Build/Compile/Default,lib)
$(call Build/Compile/Default,gnuefi)
$(call Build/Compile/Default,inc)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/gnu-efi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Host/Compile
$(call Host/Compile/Default,mkvars)
$(call Host/Compile/Default,lib)
$(call Host/Compile/Default,gnuefi)
$(call Host/Compile/Default,inc)
endef

$(eval $(call HostBuild,gnu-efi))
$(eval $(call BuildPackage,gnu-efi))
