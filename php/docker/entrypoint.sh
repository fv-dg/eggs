#!/bin/bash
cd /home/container

# Output Current php Version
php -v

# Replace Startup Variables
MODIFIED_STARTUP=`echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g'`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
