# OpenWrt UEFI Support
Since OpenWrt Project has not yet accepted any UEFI-Boot approach, extract based on the original jow.git and modify it to be compatible with the current version.

Tested in Openwrt 19.07 source branch.

!()[https://raw.githubusercontent.com/falafalafala1668/OpenWrt-UEFI-Support/master/src/Screenshots/2.png]

**UEFI Secure Boot Coming Soon.**

# Usage
In your OpenWrt source dir, enter:

```
git clone https://github.com/falafalafala1668/OpenWrt-UEFI-Support.git
chmod +x ./openwrt-uefi-support/RunMe.sh
./openwrt-uefi-support/RunMe.sh apply
```

After merging the branch or checking out openwrt-uefi-support repository, run make menuconfig.

Go to **Target Images** and make sure that **Build EFI grub images** option is checked.

!()[https://raw.githubusercontent.com/falafalafala1668/OpenWrt-UEFI-Support/master/src/Screenshots/1.png]

**Restore**

```
./openwrt-uefi-support/RunMe.sh restore
```

# Thanks
[OpenWrt Project](https://github.com/openwrt/openwrt.git)

[Jo-Philipp Wich](https://git.openwrt.org/openwrt/staging/jow.git)

# Reference
[OpenWrt on UEFI based x86 systems](https://openwrt.org/docs/guide-developer/uefi-bootable-image)
