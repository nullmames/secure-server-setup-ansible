#!/bin/bash

# Obtain lag status from Sei node
LAG=$(curl -s -m5 -N http://${HAPROXY_SERVER_ADDR}:${HAPROXY_SERVER_PORT}/lag_status)

# Check if high lag amount
echo "${LAG}" | grep -q "code"
if [ $? -eq 0 ]; then
    exit 1
fi

# Under 300 or empty
LAG_AMOUNT=$(echo "${LAG}" | jq -r ".lag")

# If LAG is null or greater than 200, exit
if [ -z "${LAG_AMOUNT}" ] || [ "${LAG_AMOUNT}" -gt 200 ]; then
    exit 1
fi

exit 0
