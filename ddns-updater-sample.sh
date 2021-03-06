#!/bin/bash
# Script that checks DNS record of a hostname and compares it with current machine's public IP.
# If the two differ, update Google Domain DDNS. Exits if records match. Only works for IPv4
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

### CONSTANTS END ###

### SCRIPT ###
# IP recorded on DNS
#  nslookup	looks up DNS record for $HOSTNAME
#  sed		remove first 3 lines (DNS server info)
#  grep		get first IPv4 address
nslookupResult=`nslookup $HOSTNAME | sed '1,3d' | grep -m 1 -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`

# Check if nslookupResult is empty
if [[ -z $nslookupResult ]]; then
	# $nslookupResult is empty; no IPv4 record found
	echo "No DNS record found for domain '${HOSTNAME}'"
	exit 1
fi

# $nslookupResult is non-empty; IPv4 record found
echo "IPv4 address found, checking public IP"

# Get actual public IP
publicIp=`curl -s ifconfig.me`

# Check if DNS record and public IP match
if [[ $nslookupResult == $publicIp ]]; then
	echo "DNS record MATCHES public IP; exiting"
	exit 0
fi

echo "DNS record DOES NOT MATCH public IP; updating record"

# Attempt to update DNS record
curlResult=`curl -s -w '%{http_code}' -o /dev/null -H "User-Agent: ${USER_AGENT}" "${URI}"`

# Check if HTTP 200
if [[ $curlResult == 200 ]]; then
	# HTTP 200 signifies record was updated successfully or there was no update needed
	echo "SUCCESS: DDNS Record updated"
	exit 0
fi

# curl did not return HTTP 200. Likely that HOSTNAME, GD_USER or GD_PASS was invalid
# See https://support.google.com/domains/answer/6147083 for more details
echo "FAILURE: Unable to update DDNS record. Check credentials and hostname"
exit 1

### SCRIPT END ###
