#!/bin/bash
# Author: JuanJo Ciarlante <jjo@canonical.com>
# Copyright: Canonical Ltd. 2012
# License: GPLv2
#
# juju storage common shell library
# 

#------------------------------
# Returns a mount point from passed vol-id, e.g. /srv/juju/vol-000012345
#
# @param  $1             volume id
# @echoes mntpoint-path  eg /srv/juju/vol-000012345
#------------------------------
_mntpoint_from_volid() {
  local volid=${1?missing volid}
  [[ ${volid} != "" ]] && echo /srv/juju/${volid} || echo ""
}


#------------------------------
# Assert that passed mount points hold different filesystems
#
# @param  $1     mntpoint1
# @param  $2     mntpoint2
# @return  0     different FS
#          1     same FS
#------------------------------
_assert_diff_fs() {
  local mnt1="${1:?missing mntpoint1}"
  local mnt2="${2:?missing mntpoint2}"
  local fsid1 fsid2
  fsid1=$(stat --file-system -c '%i' "${mnt1}" 2>/dev/null)
  fsid2=$(stat --file-system -c '%i' "${mnt2}" 2>/dev/null)
  [[ ${fsid1} != ${fsid2} ]]
  return $?
}

#------------------------------
# Initialize volume (sfdisk, mkfs.ext4) IFF NOT already, mount it at
# /srv/juju/<volume-id>
#
# @param  $1 volume-id, can be any arbitrary string, better if
#            equal to EC2/OS vol-id name (just for consistency)
# @return  0 success
#          1 nil volid/etc
#          2 error while handling the device (non-block device, sfdisk error, etc)
#------------------------------
volume_init_and_mount() {
  ## Find 1st unused device (reverse sort /dev/vdX)
  local volid=${1:?missing volid}
  local dev_regexp
  local dev found_dev=
  local label="${volid}"
  local func=${FUNCNAME[0]}
  dev_regexp=$(config-get volume-dev-regexp) || return 1
  mntpoint=$(_mntpoint_from_volid ${volid})

  [[ -z ${mntpoint} ]] && return 1
  if mount | egrep -qw "${mntpoint}";then
    _assert_diff_fs "/" "${mntpoint}" || {
       juju-log "ERROR: returning from ${func} with '${mntpoint}' still at '/' filesystem"
       return 1
    }
    juju-log "NOTICE: mntpoint=${mntpoint} already mounted, skipping volume_init_and_mount"
    return 0
  fi

  # Sanitize
  case "${dev_regexp?}" in
    # Careful: this is glob matching against an regexp -
    # quite narrowed
    /dev/*|/dev/disk/by-*)
      ;; ## Ok
    *)
      juju-log "ERROR: invalid 'volume-dev-regexp' specified"
      return 1
      ;;
  esac

  # Assume udev will create only existing devices
  for dev in $(ls -rd1 /dev/* | egrep "${dev_regexp}" | egrep -v "[1-9]$" 2>/dev/null);do
    ## Check it's not already mounted
    mount | egrep -q "${dev}[1-9]?" || { found_dev=${dev}; break;}
  done
  [[ -n "${found_dev}" ]] || {
    juju-log "ERROR: ${func}: coult not find an unused device for regexp: ${dev_regexp}"
    return 1
  }
  partition1_dev=${found_dev}1

  juju-log "INFO: ${func}: found_dev=${found_dev}"
  [[ -b ${found_dev?}  ]] || {
    juju-log "ERROR: ${func}: ${found_dev} is not a blockdevice"
    return 2
  }

  # Run next set of "dangerous" commands as 'set -e', in a subshell
  (
  set -e
  # Re-read partition - will fail if already in use
  blockdev --rereadpt ${found_dev}

  # IFF not present, create partition with full disk
  if [[ -b ${partition1_dev?} ]];then
    juju-log "INFO: ${func}: ${partition1_dev} already present - skipping sfdisk."
  else
    juju-log "NOTICE: ${func}: ${partition1_dev} not present at ${found_dev}, running: sfdisk ${found_dev} ..."
    # Format partition1_dev as max sized
    echo ",+," | sfdisk ${found_dev}
  fi

  # Create an ext4 filesystem if NOT already present
  # use e.g. LABEl=vol-000012345
  if file -s ${partition1_dev} | egrep -q ext4 ; then
    juju-log "INFO: ${func}: ${partition1_dev} already formatted as ext4 - skipping mkfs.ext4."
    ## Check e2label - log if it has changed (e.g. already used / initialized with a diff label)
    local curr_label=$(e2label "${partition1_dev}")
    if [[ ${curr_label} != ${label} ]]; then
      juju-log "WARNING: ${func}: ${partition1_dev} had label=${curr_label}, overwritting with label=${label}"
      e2label ${partition1_dev} "${label}"
    fi
  else
    juju-log "NOTICE: ${func}: running: mkfs.ext4 -L ${label} ${partition1_dev}"
    mkfs.ext4 -L "${label}" ${partition1_dev}
  fi

  # Mount it at e.g. /srv/juju/vol-000012345
  [[ -d "${mntpoint}" ]] || mkdir -p "${mntpoint}"
  mount | fgrep -wq "${partition1_dev}" || {
    local files_below_mntpoint="$(cd ${mntpoint}; ls -1A |wc -l )"
    if [[ ${files_below_mntpoint} -ne 0 ]]; then
      juju-log "ERROR: *not* doing 'mount "${partition1_dev}" "${mntpoint}"' because there are already ${files_below_mntpoint} files/dirs beneath '${mntpoint}'"
      exit 1
    fi
    ## should always fsck before mounting (e.g. fsck after max time (-i) / max mounts (-c) )
    fsck "${partition1_dev}"
    mount "${partition1_dev}" "${mntpoint}"
    juju-log "INFO: ${func}: mounted as: '$(mount | fgrep -w ${partition1_dev})'"
  }

  # Add it to fstab is not already there
  fgrep -wq "LABEL=${label}" /etc/fstab || {
    echo "LABEL=${label}    ${mntpoint}    ext4    defaults,nobootwait,comment=${volid}" | tee -a /etc/fstab
    juju-log "INFO: ${func}: LABEL=${label} added to /etc/fstab"
  }
  )
  # Final assertion: mounted filesystem id is different from '/' (effectively mounted)
  _assert_diff_fs "/" "${mntpoint}" || {
     juju-log "ERROR: returning from ${func} with '${mntpoint}' still at '/' filesystem (couldn't mount new volume)"
     ## try to rmdir mntpoint directory - should not be 'mistakenly' used
     rmdir ${mntpoint}
     return 1
  }
  return $?
}

#------------------------------
# Get volume-id from juju config "volume-map" dictionary as
#     volume-map[JUJU_UNIT_NAME]
# @return  0 if volume-map value found ( does echo volid or ""), else:
#          1 if not found or None
#
#------------------------------
volume_get_volid_from_volume_map() {
  local volid=$(config-get "volume-map"|python -c$'import sys;import os;from yaml import load;from itertools import chain; volume_map = load(sys.stdin)\nif volume_map: print volume_map.get(os.environ["JUJU_UNIT_NAME"])')
  [[ $volid == None ]] && return 1
  echo "$volid"
}

# Returns true if permanent storage (considers --ephemeral)
# @returns  0 if volid set and not --ephemeral, else:
#           1 
volume_is_permanent() {
  local volid=${1:?missing volid}
  [[ -n ${volid} && ${volid} != --ephemeral ]] && return 0 || return 1
}
volume_mount_point_from_volid(){
  local volid=${1:?missing volid}
  if volume_is_permanent "${volid}";then
	  echo "/srv/juju/${volid}"
    return 0
  else
    return 1
  fi
}
# Do we have a valid storage state?
# @returns  0 does echo $volid (can be "--ephemeral")
#           1 config state is invalid - we should not serve
volume_get_volume_id() {
  local ephemeral_storage
  local volid
  ephemeral_storage=$(config-get volume-ephemeral-storage) || return 1
  volid=$(volume_get_volid_from_volume_map) || return 1
  if [[ $ephemeral_storage == True ]];then
    # Ephemeral -> should not have a valid volid
    if [[ $volid != "" ]];then
        juju-log "ERROR: volume-ephemeral-storage is True, but $JUJU_UNIT_NAME maps to volid=${volid}"
        return 1
    fi
  else
    # Durable (not ephemeral) -> must have a valid volid for this unit
     if [[ $volid == "" ]];then
        juju-log "ERROR: volume-ephemeral-storage is False, but no volid found for: $JUJU_UNIT_NAME"
        return 1
     fi
  fi
  echo "$volid"
  return 0
}

case "$1" in
  ## allow non SHELL scripts to call helper functions
  call)
    : ${JUJU_UNIT_NAME?} ## Must be called in juju environment
    shift;
    function="${1:?usage: ${0##*/} call function arg1 arg2 ...}"
    shift;
    ${function} "$@" && exit 0 || exit 1
esac
