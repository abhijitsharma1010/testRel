#!/bin/bash

# Current working directory
current_dir=$(dirname "$0")
cd $current_dir

# Source the config files
source ./config_chat_id
source ./config_bot_token

# Set other variables
DATE="$(date +%d/%m/%Y__%H:%M)"
IP="10.2.2.1"
REQUIRED_FAILURES=3          # Number of consecutive failures before alerting
PING_COUNT=4                 # Ping packets per check
CACHE_FILE="/tmp/ping_status_cache_$IP"
DOWNTIME_START_FILE="/tmp/ping_downtime_start_$IP"
FAIL_COUNT_FILE="/tmp/ping_fail_count_$IP"

# Helper: format seconds into Xh Xm Xs
format_duration() {
  local total=$1
  echo "$((total / 3600))h $(( (total % 3600) / 60 ))m $((total % 60))s"
}

# Helper: get elapsed downtime string
get_downtime_str() {
  if [ -f "$DOWNTIME_START_FILE" ]; then
    local start=$(cat "$DOWNTIME_START_FILE")
    local now=$(date +%s)
    format_duration $(( now - start ))
  else
    echo "unknown"
  fi
}

# Ping the IP address — require packet loss threshold to avoid single-packet glitches
ping -c $PING_COUNT -W 2 $IP > /dev/null 2>&1
PING_RESULT=$?

if [ $PING_RESULT -ne 0 ]; then
  # Increment consecutive failure counter
  FAIL_COUNT=0
  [ -f "$FAIL_COUNT_FILE" ] && FAIL_COUNT=$(cat "$FAIL_COUNT_FILE")
  FAIL_COUNT=$(( FAIL_COUNT + 1 ))
  echo "$FAIL_COUNT" > "$FAIL_COUNT_FILE"

  # Only alert after REQUIRED_FAILURES consecutive failures
  if [ "$FAIL_COUNT" -ge "$REQUIRED_FAILURES" ]; then
    if [ ! -f "$CACHE_FILE" ] || [ "$(cat "$CACHE_FILE")" != "down" ]; then
      # First time crossing the threshold — record downtime start and alert
      echo "$(date +%s)" > "$DOWNTIME_START_FILE"
      curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id=$CHAT_ID \
        -d text="🔴 Ping to $IP FAILED on $DATE" > /dev/null 2>&1
      echo "down" > "$CACHE_FILE"
    else
      # Already down — send hourly reminder with total downtime so far
      if [ "$(find "$CACHE_FILE" -mmin +60)" ]; then
        DOWNTIME_STR=$(get_downtime_str)
        curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
          -d chat_id=$CHAT_ID \
          -d text="🔴 Ping to $IP still DOWN on $DATE. Total downtime so far: $DOWNTIME_STR" > /dev/null 2>&1
        touch "$CACHE_FILE"
      fi
    fi
  fi

else
  # Ping succeeded — reset failure counter
  rm -f "$FAIL_COUNT_FILE"

  # If it was previously marked as down, send recovery message
  if [ -f "$CACHE_FILE" ] && [ "$(cat "$CACHE_FILE")" == "down" ]; then
    DOWNTIME_STR=$(get_downtime_str)
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
      -d chat_id=$CHAT_ID \
      -d text="✅ Ping to $IP RESTORED on $DATE. Total downtime: $DOWNTIME_STR" > /dev/null 2>&1
    rm -f "$CACHE_FILE" "$DOWNTIME_START_FILE"
  fi
fi
