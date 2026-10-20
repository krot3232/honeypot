# Honeypot
<img src="https://raw.githubusercontent.com/krot3232/logos/main/honeypot.png" width="200">

A simple Bash script that uses socat to catch port scanners and automatically bans their IPs

[![!#/bin/bash](https://img.shields.io/badge/-%23!%2Fbin%2Fbash-1f425f.svg?style=flat-square&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
## Features
* **Real-time Detection:** Catches unauthorized port scans instantly using `socat`.
* **Automated Banning:** Leverages `ipset` for high-performance IP blocking with custom timeouts.
* **Flexible Modes:** Supports both dry-run logging and active IP blocking modes.
* **Low Overhead:** Native Linux tools ensure minimal CPU and memory usage.
## Install
**1.** Install the packages:
```bash
# Debian / Ubuntu / Linux Mint
apt install ipset socat -y
# RHEL / CentOS / Rocky Linux / AlmaLinux / Fedora
dnf install ipset socat -y
# CentOS 7
yum install ipset socat -y
```
Installation check:
```bash
socat -V | head -n 1
iptables -V
ipset -v
```
**2.** Configure `iptables`:
```bash
ipset create blocked_ips hash:ip timeout 60 -exist
iptables -C INPUT -m set --match-set blocked_ips src -j DROP 2>/dev/null || iptables -I INPUT -m set --match-set blocked_ips src -j DROP
```
**3.** Clone `honeypot`
```bash
cd /root && git clone https://github.com/krot3232/honeypot.git && cd honeypot
```
**4.** Move all your service ports to non-standard ports, and set up a `honeypot` in their place.  
**5.** Run `systemd` honeypot.service:

Edit `honeypot.service`, add open ports for a `honeypot`, change the IP ban duration (default is `60` seconds). 
```bash
nano honeypot.service
cp honeypot.service /etc/systemd/system/honeypot.service
systemctl daemon-reload
systemctl start honeypot
systemctl enable honeypot
``` 
or using `nohup` examples:
```bash
nohup ./honeypot.sh "5432/postgresql,6379/redis" add_log honeypot.log &
nohup ./honeypot.sh 22/ssh,2222-2224/ssh add_log honeypot.log &

nohup ./honeypot.sh "1/null,22/ssh,2222/ssh,3389/rdp,1023/null,65535/null" block_ip 60 &
```

See logs here `/var/log/honeypot.log`
> [!WARNING]
> Be careful with the block duration; you could end up locking yourself out if you attempt to establish a connection to a port where a honeypot is set up.

## Example
```bash
./honeypot.sh <PORT>/<SERVICE> <SCRIPT> <SCRIPT_PARAM>
```
`<PORT>` - one port `22` or ranges of ports `1-25`, `<SERVICE>` - name service in the directory [echo](https://github.com/krot3232/honeypot/tree/main/echo), `<SCRIPT>` - block_ip or add_log, `<SCRIPT_PARAM>` - lockout duration in seconds or name log file  
`<PORT>/<SERVICE>` - can be specified multiple times, separated by commas.

### Logging
Logging to a file without IP-based blocking:
```bash
./honeypot.sh 22/ssh,2222-2224/ssh add_log honeypot.log
```
### Block IP
IP address blocking for `120` seconds, with an entry recorded in the log file `honeypot.log`:
```bash
./honeypot.sh 22/ssh,2222/ssh,3389/rdp,80/http block_ip 120
```
---

## Useful commands
All blocked IP addresses:
```bash
ipset list blocked_ips
```
Save file IPs:
```bash
ipset save blocked_ips > blocked_ips.txt
```
Check is Ip block:
```bash
ipset test blocked_ips 192.168.1.100
```
Unblock IP:
```bash
ipset del blocked_ips 192.168.1.100
```
Unblock all IP:
```bash
ipset flush blocked_ips
```
Nmap port scan:
```bash
nmap -sV -p $PORT -n -Pn --open $IP
```
