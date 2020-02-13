# OpenWrt UEFI Support (19.07 Branch)
Since OpenWrt Project has not yet accepted any UEFI-Boot approach, extract based on the original jow.git and modify it to be compatible with the current version.

Tested in Openwrt Master & 19.07 source branches.

![](https://github.com/falafalafala1668/OpenWrt-UEFI-Support/blob/master/src/Screenshots/2.png)

**UEFI Secure Boot Coming Soon.**

# Usage
Before clone the patches, please check your OpenWrt source branch:

**Master**
```
git clone https://github.com/falafalafala1668/OpenWrt-UEFI-Support.git
```

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

**Update**

Before update, Please ensure that the following files have not been modified.
```
config/Config-images.in
package/base-files/files/lib/upgrade/common.sh
package/base-files/files/sbin/sysupgrade
package/boot/grub2/Makefile
tools/Makefile
target/linux/x86/base-files/lib/upgrade/platform.sh
target/linux/x86/image/Makefile
```

then enter:

```
./OpenWrt-UEFI-Support/RunMe.sh update
```

**Restore**

```
./OpenWrt-UEFI-Support/RunMe.sh restore
```

# Advanced Settings
If you OpenWrt isn't official sources, or you have been modified these files.You can generate patches by yourself.

```
config/Config-images.in
package/base-files/files/lib/upgrade/common.sh
package/base-files/files/sbin/sysupgrade
package/boot/grub2/Makefile
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

# Thanks
[OpenWrt Project](https://github.com/openwrt/openwrt.git)

[Jo-Philipp Wich](https://git.openwrt.org/openwrt/staging/jow.git)

# Reference
[OpenWrt on UEFI based x86 systems](https://openwrt.org/docs/guide-developer/uefi-bootable-image)
