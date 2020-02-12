# OpenWrt UEFI Support
Since OpenWrt Project has not yet accepted any UEFI-Boot approach, extract based on the original jow.git and modify it to be compatible with the current version.

Tested in Openwrt 19.07 source branch.

![](https://github.com/falafalafala1668/OpenWrt-UEFI-Support/blob/master/src/Screenshots/2.png)

**UEFI Secure Boot Coming Soon.**

# Usage
In your OpenWrt source dir, enter:

```
git clone https://github.com/falafalafala1668/OpenWrt-UEFI-Support.git
chmod +x ./OpenWrt-UEFI-Support/RunMe.sh
./OpenWrt-UEFI-Support/RunMe.sh apply
```

After patches, run make menuconfig.

Go to **Target Images** and make sure that **Build EFI grub images** option is checked.

![](https://github.com/falafalafala1668/OpenWrt-UEFI-Support/blob/master/src/Screenshots/1.png)

**Restore**

```
./OpenWrt-UEFI-Support/RunMe.sh restore
```
# Known issues

Using `sysupgrade` and `luci` upgrade new UEFI Image will show error or damaged,Because I have removed hybrid boot support to avoid some partition table issues.

**Temporary Solution:**

IMPORTANT: It will make your system corrupt,Please check your image before upgrade!!!
```
sysupgrade with "-F" parameter
luci use Force Update
```

# Thanks
[OpenWrt Project](https://github.com/openwrt/openwrt.git)

[Jo-Philipp Wich](https://git.openwrt.org/openwrt/staging/jow.git)

# Reference
[OpenWrt on UEFI based x86 systems](https://openwrt.org/docs/guide-developer/uefi-bootable-image)
