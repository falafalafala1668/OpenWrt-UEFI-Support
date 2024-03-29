# OpenWrt UEFI Support (19.07 Branch, Unofficial Support)
### IMPORTANT

**Openwrt has officially supported UEFI, but v19.07 and v18.06 not. So v19.07 and v18.06 will continue to update.** 

---
Since OpenWrt Project has not yet accepted any UEFI-Boot approach, extract based on the original jow.git and modify it to be compatible with the current version.

These patches are for the convenience of quickly adding UEFI startup support and these are **temporary solutions**.

Tested in Openwrt 19.07.8

![](https://github.com/falafalafala1668/OpenWrt-UEFI-Support/blob/master/src/Screenshots/2.png)

# Usage
Before clone the patches, please check your OpenWrt source branch:

**19.07**
```
git clone https://github.com/falafalafala1668/OpenWrt-UEFI-Support.git -b openwrt-19.07
```

**18.06**
```
git clone https://github.com/falafalafala1668/OpenWrt-UEFI-Support.git -b openwrt-18.06
```

then, in your OpenWrt source dir, enter:

```
./OpenWrt-UEFI-Support/RunMe.sh apply
```

After patches, run make menuconfig.

Go to **Target Images** and make sure that **Build EFI grub images** option is checked.

![](https://github.com/falafalafala1668/OpenWrt-UEFI-Support/blob/master/src/Screenshots/1.png)

## Update

Before update, Please ensure that the following folder or files have not been modified.
```
config/Config-images.in
package/base-files/files/lib/upgrade/common.sh
package/boot/grub2
tools/Makefile
target/linux/x86/base-files/lib/upgrade/platform.sh
target/linux/x86/image/Makefile
```

If the patch has been applied, restore it:
```
./OpenWrt-UEFI-Support/RunMe.sh restore
```

then enter:

```
./OpenWrt-UEFI-Support/RunMe.sh update
```

Finally apply the patch:
```
./OpenWrt-UEFI-Support/RunMe.sh apply
```

## Restore

```
./OpenWrt-UEFI-Support/RunMe.sh restore
```

# Known Issues

Booting UEFI Image on PVE will be panic or freeze because on graphic card driver issue.(Thanks reporter [#2](https://github.com/falafalafala1668/OpenWrt-UEFI-Support/issues/2))

### Solution

Add ``nomodeset`` to stop using the graphic card driver (``Target Images -> Extra kernel boot options``).

# Advanced Settings
If you OpenWrt isn't official sources, or you have been modified these folder or files. You can generate patches by yourself.

```
config/Config-images.in
package/base-files/files/lib/upgrade/common.sh
package/boot/grub2
tools/Makefile
target/linux/x86/base-files/lib/upgrade/platform.sh
target/linux/x86/image/Makefile
```

then enter:

```
./OpenWrt-UEFI-Support/RunMe.sh generate
```
then apply the patches
```
./OpenWrt-UEFI-Support/RunMe.sh apply
```

# Acknowledgement
[OpenWrt Project](https://github.com/openwrt/openwrt.git)

[Jo-Philipp Wich](https://git.openwrt.org/openwrt/staging/jow.git)

[Alif M. Ahmad](https://github.com/alive4ever/openwrt)

# Reference
[OpenWrt on UEFI based x86 systems](https://openwrt.org/docs/guide-developer/uefi-bootable-image)
