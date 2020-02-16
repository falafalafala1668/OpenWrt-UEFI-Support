include $(TOPDIR)/rules.mk

PKG_NAME:=efitools
PKG_VERSION:=1.8.1
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Alif M. Ahmad <alive4ever@live.com>
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.kernel.org/pub/scm/linux/kernel/git/jejb/efitools.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=28687de80b18b3b35271de1d70769eac3c0b1ab4
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_DEPENDS:=openssl gnu-efi perl-file-slurp/host

include $(INCLUDE_DIR)/package.mk

define Package/efitools
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:= +libopenssl +mount-utils +kmod-fs-efivarfs
  TITLE:=Manipulate EFI system variables
endef

define Package/efitools/description
  This package installs a variety of tools for manipulating keys and binary
  signatures on UEFI secure boot platforms. The tools provide access to the keys
  and certificates stored in the secure variables of the UEFI firmware, usually
  in the NVRAM area.
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	( cd $(PKG_BUILD_DIR) && rm -f PreLoader.c LockDown.c && cd -)
endef

define Build/Compile
	$(call Build/Compile/Default,all)
endef

define Package/efitools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/efitools/efi
	for bin in \
		cert-to-efi-hash-list cert-to-efi-sig-list efi-readvar \
		efi-updatevar mkusb.sh flash-var \
		hash-to-efi-sig-list sig-list-to-certs sign-efi-sig-list ; do \
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/$$$$bin $(1)/usr/bin ; done
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/*.efi $(1)/usr/share/efitools/efi/
endef

$(eval $(call BuildPackage,efitools))
