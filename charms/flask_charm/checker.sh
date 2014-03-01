#!/bin/bash
ps cax | grep -i 'nginx' > /dev/null
if [ $? -eq 0 ]; then
  echo "Process is running."
else
  sudo service nginx restart
fi
