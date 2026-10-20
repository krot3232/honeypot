# Honeypot
<img src="https://raw.githubusercontent.com/krot3232/logos/main/honeypot.png" width="200">

A simple Bash script that uses socat to catch port scanners and automatically bans their IPs
## Install
```bash
apt install ipset socat
```
Installation check:
```bash
socat -V | head -n 1
iptables -V
ipset -v
```
Configure iptables:
```bash
ipset create blocked_ips hash:ip timeout 60 -exist
iptables -C INPUT -m set --match-set blocked_ips src -j DROP 2>/dev/null || iptables -I INPUT -m set --match-set blocked_ips src -j DROP
```
## Example
### Logging
Logging to a file without IP-based blocking:
```bash
./honeypot.sh 22/ssh,2222/ssh add_log honeypot.log
```
### Block IP
IP address blocking for 120 seconds, with an entry recorded in the log file `honeypot.log`:
```bash
./honeypot.sh 22/ssh,2222/ssh,3389/rdp,80/http block_ip 120
```
