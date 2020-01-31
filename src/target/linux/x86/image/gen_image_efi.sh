#!/usr/bin/env bash
set -x
[ $# == 5 -o $# == 6 ] || {
    echo "SYNTAX: $0 <file> <efi size> <efi image> <rootfs size> <rootfs image> [<align>]"
    exit 1
}

OUTPUT="$1"
EFISIZE="$2"
EFIIMAGE="$3"
ROOTFSSIZE="$4"
ROOTFSIMAGE="$5"
ALIGN="$6"

rm -f "$OUTPUT"

head=16
sect=63

cyl=$(( ($EFISIZE + $ROOTFSSIZE) * 1024 * 1024 / ($head * $sect * 512) ))

# create partition table
set `ptgen -o "$OUTPUT" -h $head -s $sect -p ${EFISIZE}m -p ${ROOTFSSIZE}m ${ALIGN:+-l $ALIGN} ${SIGNATURE:+-S 0x$SIGNATURE}`


EFIOFFSET="$(($1 / 512))"
EFISIZE="$2"
ROOTFSOFFSET="$(($3 / 512))"
ROOTFSSIZE="$(($4 / 512))"

dd if=/dev/zero of="$OUTPUT" bs=512 seek="$ROOTFSOFFSET" conv=notrunc count="$ROOTFSSIZE"
dd if="$ROOTFSIMAGE" of="$OUTPUT" bs=512 seek="$ROOTFSOFFSET" conv=notrunc
dd if="$EFIIMAGE" of="$OUTPUT" bs=512 seek="$EFIOFFSET" conv=notrunc
