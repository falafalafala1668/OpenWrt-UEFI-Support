#!/usr/bin/env bash
set -x
[ $# == 5 -o $# == 6 ] || {
    echo "SYNTAX: $0 <file> <kernel size> <kernel directory> <rootfs size> <rootfs image> [<align>]"
    exit 1
}

OUTPUT="$1"
KERNELSIZE="$2"
KERNELDIR="$3"
ROOTFSSIZE="$4"
ROOTFSIMAGE="$5"
ALIGN="$6"

rm -f "$OUTPUT"

head=16
sect=63

cyl=$(( ($KERNELSIZE + $ROOTFSSIZE) * 1024 * 1024 / ($head * $sect * 512) ))

# create partition table
set `ptgen -o "$OUTPUT" -h $head -s $sect -p ${KERNELSIZE}m -p ${ROOTFSSIZE}m ${ALIGN:+-l $ALIGN} ${SIGNATURE:+-S 0x$SIGNATURE}`

KERNELOFFSET="$(($1 / 512))"
KERNELSIZE="$2"
ROOTFSOFFSET="$(($3 / 512))"
ROOTFSSIZE="$(($4 / 512))"


dd if=/dev/zero of="$OUTPUT" bs=512 seek="$ROOTFSOFFSET" conv=notrunc count="$ROOTFSSIZE"
dd if="$ROOTFSIMAGE" of="$OUTPUT" bs=512 seek="$ROOTFSOFFSET" conv=notrunc

rm -rf ${KERNELDIR%/*}/kernel.efi || true
mkfs.fat -C ${KERNELDIR%/*}/kernel.efi -S 512 "$((KERNELSIZE / 1024))"
mcopy -s -i "${KERNELDIR%/*}/kernel.efi" "$KERNELDIR"/* ::/
dd if="${KERNELDIR%/*}/kernel.efi" of="$OUTPUT" bs=512 seek="$KERNELOFFSET" conv=notrunc
