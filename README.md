# ddns-updater

## Overview
This script was created to automatically update an IP on Google Domain DDNS if a change is detected.
The intent is to `cron` `ddns-updater.sh`, which checks if the DNS record of a host matches the current
machine's public facing IP address. If there is a mismatch, a HTTP GET request is placed
onto `https://domains.google.com/nic/update`, updating the DDNS record.

## Directions
```bash
# Create copy from sample file
cp ddns-updater-sample.sh ddns-updater.sh

# update vars HOSTNAME, GD_USER, GD_PASS
vim ddns-updater.sh

# Add to crontab
crontab -e 
# OR
sudo vim /etc/crontab
```

```bash
# Sample crontab entries for every 6th hour at the top of the hour (hh:00)

# User crontab (crontab -e)
* */6 * * * /path/to/ddns-updater.sh

# System crontab (sudo vim /etc/crontab)
* */6 * * * [user] /path/to/ddns-updater.sh
```

## Resource Links
[Google's DDNS Documentation](https://support.google.com/domains/answer/6147083)
