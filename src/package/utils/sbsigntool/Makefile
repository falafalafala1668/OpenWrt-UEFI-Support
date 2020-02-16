include $(TOPDIR)/rules.mk

PKG_NAME:=sbsigntool
PKG_VERSION:=0.9.3
PKG_LICENSE:=GPL-3.0+ OpenSSL
PKG_MAINTAINER:=Alif M. Ahmad <alive4ever@live.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.kernel.org/pub/scm/linux/kernel/git/jejb/sbsigntools.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=fe88da5f66241d959b7aeca7502d401ad88df410
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DEPENDS:=gnu-efi binutils sbsigntool/host
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

HOST_BUILD_DEPENDS:=gnu-efi/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/sbsigntool
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:= +libuuid +libopenssl
  DEPENDS+= @(x86_64||i386)
  TITLE:=Tools to manipulate signatures on UEFI binaries and drivers
endef

define Package/sbsigntool/description
  This package installs tools which can cryptographically sign EFI binaries
  and drivers.
endef

define Build/Prepare
$(call Build/Prepare/Default)
	sed -i -E 's#\$$$$path/crt0-efi#$(STAGING_DIR)/\$$$$path/crt0-efi#' \
	$(PKG_BUILD_DIR)/configure.ac
	sed -i "s#-I/usr/include/efi#-I$(STAGING_DIR)/usr/include/efi#g" \
	$(PKG_BUILD_DIR)/configure.ac
	(cd $(PKG_BUILD_DIR) && \
	./lib/ccan.git/tools/create-ccan-tree \
                --build-type=automake lib/ccan \
		"talloc read_write_all build_assert array_size endian list" && \
	cd - )
	( cd $(PKG_BUILD_DIR) && NOCONFIGURE=1 ./autogen.sh && cd - )
endef

define Package/sbsigntool/install
$(call Build/Install/Default,install-exec)
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
endef

define Host/Prepare
$(call Host/Prepare/Default)
	sed -i -E 's#\$$$$path/crt0-efi#$(STAGING_DIR)/\$$$$path/crt0-efi#' \
	$(HOST_BUILD_DIR)/configure.ac
	sed -i "s#-I/usr/include/efi#-I$(STAGING_DIR)/usr/include/efi#g" \
	$(HOST_BUILD_DIR)/configure.ac
	(cd $(HOST_BUILD_DIR) && \
	./lib/ccan.git/tools/create-ccan-tree \
                --build-type=automake lib/ccan \
		"talloc read_write_all build_assert array_size endian list" && \
	cd - )
	( cd $(HOST_BUILD_DIR) && NOCONFIGURE=1 ./autogen.sh && cd - )
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOST)/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/src/{sbattach,sbkeysync,sbsiglist,sbsign,sbvarsign,sbverify} $(STAGING_DIR_HOST)/bin
endef

$(eval $(call HostBuild,sbsigntool))
$(eval $(call BuildPackage,sbsigntool))
