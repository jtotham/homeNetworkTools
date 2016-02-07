#!/bin/bash
set -e

PATH="${PATH}:/usr/sbin"
export PATH

## LVM
TMPFILE_LVM="${TMPDIR:-/tmp}/lvm-backup-$$${RANDOM}${RANDOM}${RANDOM}"

vgcfgbackup -f "${TMPFILE_LVM}"

### Re-write UUIDs in LVM configuration
file_depth="0"
cat "${TMPFILE_LVM}" | while IFS='' read -r line; do
    cmd="$(echo "${line}" | awk '{ print $1 }')"
    if echo "${line}" | grep '{$' >/dev/null 2>/dev/null; then
        file_depth="$[${file_depth} + 1]"

        last_open[${file_depth}]="${cmd}"
    fi

    if echo "${line}" | grep '}$' >/dev/null 2>/dev/null; then
        file_depth="$[${file_depth} - 1]"
    fi

    if [ "${cmd}" = "id" ]; then
	if [ "${last_open[2]}" != "physical_volumes" ]; then
	    old_uuid="$(echo "${line}" | sed 's@^.*id = "@@;s@"$@@')"
	    new_uuid="$(cat /proc/sys/kernel/random/uuid)"
	    echo "${line}" | sed 's@id =.*$@id = "'"${new_uuid}"'"@'
	    continue
	    fi
	fi

    echo "${line}"
done > "${TMPFILE_LVM}.new"
mv "${TMPFILE_LVM}.new" "${TMPFILE_LVM}"

### Restore each volume group
for volgroup in $(vgcfgrestore -l -f "${TMPFILE_LVM}" | sed 's@^ *VG name: *@@;t x;d;:x'); do
    vgcfgrestore -f "${TMPFILE_LVM}" "${volgroup}"
done

### Rewrite physical volume UUIDs
pvchange --all --uuid
vgchange --uuid

### Create new OS backup of LVM configuration
vgcfgbackup

rm -f "${TMPFILE_LVM}"

