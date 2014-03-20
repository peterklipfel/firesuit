#!/bin/bash
if [ "$1" == "cassandra" ] && [ "$2" == "start" ]; then
  exit 101
else
  exit 0
fi
