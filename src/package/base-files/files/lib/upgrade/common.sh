#!/bin/sh

RAM_ROOT=/tmp/root

export BACKUP_FILE=sysupgrade.tgz	# file extracted by preinit

[ -x /usr/bin/ldd ] || ldd() { LD_TRACE_LOADED_OBJECTS=1 $*; }
libs() { ldd $* 2>/dev/null | sed -r 's/(.* => )?(.*) .*/\2/'; }

install_file() { # <file> [ <file> ... ]
	local target dest dir
	for file in "$@"; do
		if [ -L "$file" ]; then
			target="$(readlink -f "$file")"
			dest="$RAM_ROOT/$file"
			[ ! -f "$dest" ] && {
				dir="$(dirname "$dest")"
				mkdir -p "$dir"
				ln -s "$target" "$dest"
			}
			file="$target"
		fi
		dest="$RAM_ROOT/$file"
		[ -f "$file" -a ! -f "$dest" ] && {
			dir="$(dirname "$dest")"
			mkdir -p "$dir"
			cp "$file" "$dest"
		}
	done
}

install_bin() {
	local src files
	src=$1
	files=$1
	[ -x "$src" ] && files="$src $(libs $src)"
	install_file $files
}

run_hooks() {
	local arg="$1"; shift
	for func in "$@"; do
		eval "$func $arg"
	done
}

ask_bool() {
	local default="$1"; shift;
	local answer="$default"

	[ "$INTERACTIVE" -eq 1 ] && {
		case "$default" in
			0) echo -n "$* (y/N): ";;
			*) echo -n "$* (Y/n): ";;
		esac
		read answer
		case "$answer" in
			y*) answer=1;;
			n*) answer=0;;
			*) answer="$default";;
		esac
	}
	[ "$answer" -gt 0 ]
}

v() {
	[ "$VERBOSE" -ge 1 ] && echo "$@"
}

json_string() {
	local v="$1"
	v="${v//\\/\\\\}"
	v="${v//\"/\\\"}"
	echo "\"$v\""
}

rootfs_type() {
	/bin/mount | awk '($3 ~ /^\/$/) && ($5 !~ /rootfs/) { print $5 }'
}

get_image() { # <source> [ <command> ]
	local from="$1"
	local cmd="$2"

	if [ -z "$cmd" ]; then
		local magic="$(dd if="$from" bs=2 count=1 2>/dev/null | hexdump -n 2 -e '1/1 "%02x"')"
		case "$magic" in
			1f8b) cmd="zcat";;
			425a) cmd="bzcat";;
			*) cmd="cat";;
		esac
	fi

	cat "$from" 2>/dev/null | $cmd
}

get_magic_word() {
	(get_image "$@" | dd bs=2 count=1 | hexdump -v -n 2 -e '1/1 "%02x"') 2>/dev/null
}

get_magic_long() {
	(get_image "$@" | dd bs=4 count=1 | hexdump -v -n 4 -e '1/1 "%02x"') 2>/dev/null
}

get_magic_gpt() {
	(get_image "$@" | dd bs=8 count=1 skip=64) 2>/dev/null
}

get_magic_vfat() {
	(get_image "$@" | dd bs=3 count=1 skip=18) 2>/dev/null
}

get_magic_fat32() {
	(get_image "$@" | dd bs=1 count=5 skip=82) 2>/dev/null
}

part_magic_efi() {
	local magic=$(get_magic_gpt "$@")
	[ "$magic" = "EFI PART" ]
}

part_magic_fat() {
	local magic=$(get_magic_vfat "$@")
	local magic_fat32=$(get_magic_fat32 "$@")
	[ "$magic" = "FAT" ] || [ "$magic_fat32" = "FAT32" ]
}

export_bootdevice() {
	local cmdline bootdisk rootpart uuid blockdev uevent line class
	local MAJOR MINOR DEVNAME DEVTYPE

	if read cmdline < /proc/cmdline; then
		case "$cmdline" in
			*block2mtd=*)
				bootdisk="${cmdline##*block2mtd=}"
				bootdisk="${bootdisk%%,*}"
			;;
			*root=*)
				rootpart="${cmdline##*root=}"
				rootpart="${rootpart%% *}"
			;;
		esac

		case "$bootdisk" in
			/dev/*)
				uevent="/sys/class/block/${bootdisk##*/}/uevent"
			;;
		esac

		case "$rootpart" in
			PARTUUID=????????-????-????-????-????????0002)
				uuid="${rootpart#PARTUUID=}"
				for blockdev in $(find /dev -type b); do
					set -- $(dd if=$blockdev bs=1 skip=1168 count=16 2>/dev/null | hexdump -v -e '8/1 "%02X "" "2/1 "%02X""-"6/1 "%02X"')
					if [ "$4$3$2$1-$6$5-$8$7-$9" = "$uuid" ]; then
						blockdev=${blockdev##*/}
						uevent="/sys/class/block/${blockdev%[0-9]}/uevent"
						export UPGRADE_OPT_SAVE_PARTITIONS="0"
						break
					fi
				done

			;;
			PARTUUID=[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]-[a-f0-9][a-f0-9])
				uuid="${rootpart#PARTUUID=}"
				uuid="${uuid%-[a-f0-9][a-f0-9]}"
				for blockdev in $(find /dev -type b); do
					set -- $(dd if=$blockdev bs=1 skip=440 count=4 2>/dev/null | hexdump -v -e '4/1 "%02x "')
					if [ "$4$3$2$1" = "$uuid" ]; then
						uevent="/sys/class/block/${blockdev##*/}/uevent"
						break
					fi
				done
			;;
			/dev/*)
				uevent="/sys/class/block/${rootpart##*/}/../uevent"
			;;
			0x[a-f0-9][a-f0-9][a-f0-9] | 0x[a-f0-9][a-f0-9][a-f0-9][a-f0-9] | \
			[a-f0-9][a-f0-9][a-f0-9] | [a-f0-9][a-f0-9][a-f0-9][a-f0-9])
				rootpart=0x${rootpart#0x}
				for class in /sys/class/block/*; do
					while read line; do
						export -n "$line"
					done < "$class/uevent"
					if [ $((rootpart/256)) = $MAJOR -a $((rootpart%256)) = $MINOR ]; then
						uevent="$class/../uevent"
					fi
				done
			;;
		esac

		if [ -e "$uevent" ]; then
			while read line; do
				export -n "$line"
			done < "$uevent"
			export BOOTDEV_MAJOR=$MAJOR
			export BOOTDEV_MINOR=$MINOR
			return 0
		fi
	fi

	return 1
}

export_partdevice() {
	local var="$1" offset="$2"
	local uevent line MAJOR MINOR DEVNAME DEVTYPE

	for uevent in /sys/class/block/*/uevent; do
		while read line; do
			export -n "$line"
		done < "$uevent"
		if [ $BOOTDEV_MAJOR = $MAJOR -a $(($BOOTDEV_MINOR + $offset)) = $MINOR -a -b "/dev/$DEVNAME" ]; then
			export "$var=$DEVNAME"
			return 0
		fi
	done

	return 1
}

hex_le32_to_cpu() {
	[ "$(echo 01 | hexdump -v -n 2 -e '/2 "%x"')" = "3031" ] && {
		echo "${1:0:2}${1:8:2}${1:6:2}${1:4:2}${1:2:2}"
		return
	}
	echo "$@"
}

get_partitions() { # <device> <filename>
	local disk="$1"
	local filename="$2"

	if [ -b "$disk" -o -f "$disk" ]; then
		v "Reading partition table from $filename..."

		local magic=$(dd if="$disk" bs=2 count=1 skip=255 2>/dev/null)
		if [ "$magic" != $'\x55\xAA' ]; then
			v "Invalid partition table on $disk"
			exit
		fi

		rm -f "/tmp/partmap.$filename"

		local part
		for part in 1 2 3 4; do
			part_magic_efi "$disk" && {
				case $(hexdump -v -n 16 -s "$(( 0x380 + $part * 128 ))" -e '4/4 "%08X"' "$disk") in
					"0FC63DAF47728483693D798EE47D47D8")
						gptTypeID="0x00000083"
						;;
					"C12A732811D2F81FA0004BBA3BC93EC9")
						gptTypeID="0x000000EE"
						;;
					*)
						gptTypeID="0x00000000"
						;;
				esac

				gptLBA=$(hexdump -v -n 4 -s $(( 0x3A0 + $part * 128 )) -e '1/4 "0x%08X"' "$disk")
				gptNUM=$(hexdump -v -n 4 -s $(( 0x3A8 + $part * 128 )) -e '1/4 "0x%08X"' "$disk")
				set -- $gptTypeID $gptLBA $gptNUM
			} || {
				set -- $(hexdump -v -n 12 -s "$((0x1B2 + $part * 16))" -e '3/4 "0x%08X "' "$disk")
			}

			local type="$(( $(hex_le32_to_cpu $1) % 256))"
			local lba="$(( $(hex_le32_to_cpu $2) ))"
			local num="$(( $(hex_le32_to_cpu $3) ))"

			[ $type -gt 0 ] || continue

			printf "%2d %5d %7d\n" $part $lba $num >> "/tmp/partmap.$filename"
		done
	fi
}

indicate_upgrade() {
	. /etc/diag.sh
	set_state upgrade
}

# Flash firmware to MTD partition
#
# $(1): path to image
# $(2): (optional) pipe command to extract firmware, e.g. dd bs=n skip=m
default_do_upgrade() {
	sync
	if [ -n "$UPGRADE_BACKUP" ]; then
		get_image "$1" "$2" | mtd $MTD_ARGS $MTD_CONFIG_ARGS -j "$UPGRADE_BACKUP" write - "${PART_NAME:-image}"
	else
		get_image "$1" "$2" | mtd $MTD_ARGS write - "${PART_NAME:-image}"
	fi
	[ $? -ne 0 ] && exit 1
}
