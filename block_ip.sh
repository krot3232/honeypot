#!/bin/bash
TIME="${SCRIPT_PARAM:-60}"
ipset add blocked_ips $SOCAT_PEERADDR timeout $TIME -exist
./add_log.sh