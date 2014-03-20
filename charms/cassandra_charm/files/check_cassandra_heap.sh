#!/bin/bash
# Copyright (C) 2012 Canonical Ltd.
# Author: Liam Young
#
# Script used to check Cassandra is alive and that it has space left in the heap

set -u

if [[ $# -lt 3 ]]; then
    echo "$0 <jmx-ipadress> <warnpct> <criticalpct>"
    exit 1
fi
WARN_PCT=$2
CRIT_PCT=$3

NODE_INF0="$(nodetool -h $1 info 2>/dev/null)"
if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to connect to Cassandra"
    exit 2
fi
PCT_USED=$(echo "$NODE_INF0" | awk 'BEGIN {FS=":"} $1 ~ /Heap Memory/ {print $2}' | awk '{ printf("%i\n", $1*100/$3) }')
USAGE_INFO="${PCT_USED}% of heap memory used"
if [[ $PCT_USED -lt $WARN_PCT ]]; then
    echo "OK: ${USAGE_INFO}"
    exit 0
elif [[ $PCT_USED -lt $CRIT_PCT ]]; then
    echo "WARNING: ${USAGE_INFO}"
    exit 1
else
    echo "CRITICAL: ${USAGE_INFO}"
    exit 1
fi
