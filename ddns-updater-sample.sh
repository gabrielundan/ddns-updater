#!/bin/bash
# Script that checks DNS record and compares with with current public IP. Only works for IPv4.
# If the two differ, update Google Domain DDNS
# Author: Gabriel Undan (https://github.com/gabrielundan)

### CONSTANTS ###

# Record to nslookup to see if it is accurate
HOSTNAME='<hostname>' # EDIT THIS VALUE

# Google Domain auto-generated DDNS credentials for updating record
GD_USER='<google domain username>' # EDIT THIS VALUE
GD_PASS='<google domain password>' # EDIT THIS VALUE

# domains.google.com requires a user-agent to be set as per https://support.google.com/domains/answer/6147083
USER_AGENT='User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:94.0) Gecko/20100101 Firefox/94.0'

# URI to curl if update is necessary
URI="https://${GD_USER}:${GD_PASS}@domains.google.com/nic/update?hostname=${HOSTNAME}"

curlResult=`curl --silent --write-out '%{http_code}' --output /dev/null -H "User-Agent: ${USER_AGENT}" "${URI}"`
echo "${curlResult}"
exit 0
### CONSTANTS END ###

### SCRIPT ###
# IP recorded on DNS
#  nslookup	looks up DNS record for $HOSTNAME
#  sed		remove first 3 lines (DNS server info)
#  grep		get first IPv4 address
nslookupResult=`nslookup $HOSTNAME | sed '1,3d' | grep -m 1 -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
echo "ns:${nslookupResult}"

# Check if nslookupResult is empty
if [[ -z $nslookupResult ]]; then
	# $nslookupResult is empty; no IPv4 record found
	echo "No DNS record found"
	exit 1
else
	# $nslookupResult is non-empty; IPv4 record found
	echo "IPv4 address found, checking public IP"

	# Get actual public IP
	publicIp=`curl -s ifconfig.me`

	# Check if DNS record and public IP match
	if [[ $nslookupResult == $publicIp ]]; then
		echo "DNS record MATCHES public IP, update unnecessary"
		exit 0
	else
		echo "DNS record DOES NOT MATCH public IP, updating record"

		# Attempt to update DNS record
		curlResult=`curl -s -w '%{http_code}' -o /dev/null -H "User-Agent: ${USER_AGENT}" "${URI}"`

		# Check if HTTP 200
		if [[ $curlResult == 200 ]]; then
			echo "SUCCESS: DDNS Record updated"
			exit 0
		else
			echo "FAILURE: Unable to update DDNS record. Check credentials and hostname"
		fi
	fi
fi

### SCRIPT END ###
