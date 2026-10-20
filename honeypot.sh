#!/bin/bash
# Start honeypot
# Usage: ./honeypot.sh <PORT>/<SERVICE> <SCRIPT> <SCRIPT_PARAM>
# Example: ./honeypot.sh 1/dnsix,22/ssh,2222/ssh,3389/rdp,1023/rsh,65535/mercurial block_ip 3600
# Example: ./honeypot.sh 22/ssh,2222/ssh add_log honeypot.log
# Example: ./honeypot.sh 3389/rdp add_log rdp.log

set -e

ARG="${1:-22/ssh}"

IFS=',' read -r -a SERVICES <<< "$ARG"
SCRIPT2="${2:-add_log}.sh"
export SCRIPT_PARAM="${3}"


for ITEM in "${SERVICES[@]}"; do
	if [[ ! "$ITEM" =~ ^([0-9-]+)/([a-zA-Z0-9_-]+)$ ]]; then
        echo "Error: invalid service: $ITEM" >&2
        exit 1
    fi
    PORT="${BASH_REMATCH[1]}"
    SERVICE="${BASH_REMATCH[2]}"
	SCRIPT="./echo/${SERVICE}.sh"
	if [[ ! -f "$SCRIPT" || ! -x "$SCRIPT" ]]; then
        echo "Error: script not found or not executable: $SCRIPT" >&2
        exit 1
    fi
	PORT_START="${PORT%%-*}"
	PORT_END="${PORT#*-}"
	if [[ ! "$PORT_START" =~ ^[0-9]+$ ]] || (( 10#$PORT_START < 1 || 10#$PORT_START > 65535 )) || \
   [[ ! "$PORT_END" =~ ^[0-9]+$ ]] || (( 10#$PORT_END < 1 || 10#$PORT_END > 65535 )) || \
   (( 10#$PORT_START > 10#$PORT_END )); then
    echo "Error: invalid port: $PORT" >&2
    exit 1
	fi
     
done

for ITEM in "${SERVICES[@]}"; do
    PORT="${ITEM%%/*}"
	PORT_START="${PORT%%-*}"
	PORT_END="${PORT#*-}"
	SERVICE="${ITEM#*/}"
	SCRIPT1="./echo/${SERVICE}.sh"
	for PORT1 in $(seq "$PORT_START" "$PORT_END"); do
		socat -T30 \
			TCP4-LISTEN:${PORT1},reuseaddr,fork,max-children=64,backlog=128 \
			EXEC:"/bin/sh -c '${SCRIPT1}&&./${SCRIPT2}'",nofork &
		PID=$!
		echo "Start $PORT1/$SERVICE pid:$PID"
	done
done


wait
