#!/bin/bash
NOW=$(date '+%Y-%m-%d %H:%M:%S')
IP="${SOCAT_PEERADDR:-unknown}"
PORT="${SOCAT_SOCKPORT:-unknown}"
LOG="${SCRIPT_PARAM}"
if [[ "$LOG" != *.log ]]; then
	LOG="honeypot.log"
fi
echo "$NOW IP=$IP PORT=$PORT" >> "$LOG"
