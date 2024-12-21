#!/bin/bash
# Time in seconds between current time and last block
ACCEPTABLE_DELTA=45

# Get latest block height
LATEST_BLOCK_DATA=$(curl -s --connect-timeout 3 --max-time 5 -H "Content-Type: application/json" --data '{"jsonrpc": "2.0","method": "eth_getBlockByNumber","params": ["latest", false],"id": 1}' "http://${HAPROXY_SERVER_ADDR}:${HAPROXY_SERVER_PORT}")

CURRENT_TIME=$(date '+%s')

# Check sync status
echo "${LATEST_BLOCK_DATA}" | grep -q "result"

if [ $? -ne 0 ]; then
    exit 1
fi

LATEST_BLOCK_TIME=$(echo "${LATEST_BLOCK_DATA}" | sed -E 's/^.*timestamp":"([^"]*).*$/\1/')
BLOCK_TIME_DELTA=$((${CURRENT_TIME} - ${LATEST_BLOCK_TIME}))

if [ -z "${LATEST_BLOCK_TIME}" ] || [ "${BLOCK_TIME_DELTA}" -gt ${ACCEPTABLE_DELTA} ]; then
    exit 1
fi

# For testing to print to log
# echo -e "Current time: ${CURRENT_TIME} Latest block time: ${LATEST_BLOCK_TIME} Delta: ${BLOCK_TIME_DELTA}"

exit 0
