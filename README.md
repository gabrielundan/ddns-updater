# ddns-updater

## Overview
These scripts were created to automatically update an IP on Google Domain DDNS if a change is detected.
The intent is to `cron` `ddns-checker.sh`, which checks if the DNS record of a host matches the current
machine's public facing IP address. If there is a mismatch, `ddns-updater.py` is run, 
creating a get request onto `https://domains.google.com/nic/update`, updating the DDNS record.

## Resource Links
[Google's DDNS Documentation](https://support.google.com/domains/answer/6147083)
