#!/bin/bash

# Obtain lag status from Sei node - connect time of 1 second, max time of 2 seconds
LAG=$(curl -s --connect-timeout 1 --max-time 2 -N http://${HAPROXY_SERVER_ADDR}:${HAPROXY_SERVER_PORT}/lag_status)

# Check if we have data
echo "${LAG}" | grep -q "height"
if [ $? -eq 1 ]; then
    exit 1
fi

# Under 300 or empty
LAG_AMOUNT=$(echo "${LAG}" | jq -r ".lag")

# If LAG is null or greater than 300, exit
if [ -z "${LAG_AMOUNT}" ] || [ "${LAG_AMOUNT}" -gt 1 ]; then
    exit 1
fi

exit 0
