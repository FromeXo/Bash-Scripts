#!/usr/bin/env bash
#===================================================================================
# FILE: myip.sh
# Shows info about your ip config.
#===================================================================================
#### SCRIPT ####
# Simple IPv4 reg pattern
readonly IP4_PATTERN="[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"

# Get DNS
DNS=`nmcli | grep -oE "servers.*|domains.*"`

# Get Gateway
GATEWAY=`ip route show | head -1 | grep -oE "${IP4_PATTERN}"`

# Collect info about all network devices
OUTPUT=`nmcli device | sed -E "s/\s\s+/,/g" | sed -E "s/\,$//g" | tail -n +2`


DATA=()
while IFS=, read -r DEVICE TYPE STATE CONNECTION; do

	# Get the IP (with prefix) of each device
	IP=$(ip addr show "${DEVICE}" 2>&1 | grep -oE "${IP4_PATTERN}\/[0-9]{1,2}")
	
	if [ "${IP}" = "" ];then
		IP="--"
	fi

	DATA+=("${DEVICE},${TYPE},${STATE},${CONNECTION},${IP}")

done <<< "${OUTPUT}"

echo ""
for value in "${DATA[@]}"; do
    printf "%-8s\n" "${value}"
done | column -t -s , -N DEVICE,TYPE,STATE,CONNECTION,IP


echo $'\nGateway:'
echo "  ${GATEWAY}"
echo "DNS:"
echo "  ${DNS%$'\n'*}"
echo "  ${DNS##*$'\n'}"
