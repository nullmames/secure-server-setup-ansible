#!/bin/sh

# Obtain sync status
SYNC=$(curl -s -m2 -N -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' "http://${HAPROXY_SERVER_ADDR}:${HAPROXY_SERVER_PORT}")
echo "${SYNC}" | grep -q "result"
if [ $? -ne 0 ]; then
    return 1
fi
SYNC=$(echo "${SYNC}" | jq .result)

if [ "${SYNC}" = "false" ]; then
    return 0
else
    return 1
fi
