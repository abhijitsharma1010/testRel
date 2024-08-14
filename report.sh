#!/bin/bash

# Source the config files
source config_chat_id
source config_bot_token

# Set other variables
IP="117.250.113.139"
MESSAGE_DOWN="Ping to $IP failed!"
MESSAGE_UP="Ping to $IP restored!"
CACHE_FILE="/tmp/ping_status_cache"
DOWNTIME_START_FILE="/tmp/ping_downtime_start"
MONTHLY_DOWNTIME_FILE="/tmp/ping_monthly_downtime"

# Ping the IP address
ping -c 2 $IP > /dev/null 2>&1

# Check the exit status of the ping command
if [ $? -ne 0 ]; then
  # Check if the ping was previously down
  if [ ! -f "$CACHE_FILE" ] || [ "$(cat "$CACHE_FILE")" != "down" ]; then
    # Record the downtime start time
    echo "$(date +%s)" > "$DOWNTIME_START_FILE"
    # Send Telegram message
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id=$CHAT_ID -d text="$MESSAGE_DOWN" > /dev/null 2>&1
    # Update cache file
    echo "down" > "$CACHE_FILE"
  else
    # Check if 1 hour has passed since the last message
    if [ "$(find "$CACHE_FILE" -mmin +60)" ]; then
      # Send Telegram message
      curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id=$CHAT_ID -d text="$MESSAGE_DOWN" > /dev/null 2>&1
      # Update cache file timestamp
      touch "$CACHE_FILE"
    fi
  fi
else
  # Check if the ping was previously down
  if [ -f "$CACHE_FILE" ] && [ "$(cat "$CACHE_FILE")" == "down" ]; then
    # Calculate the downtime duration
    DOWNTIME_START=$(cat "$DOWNTIME_START_FILE")
    DOWNTIME_END=$(date +%s)
    DOWNTIME_DURATION=$((DOWNTIME_END - DOWNTIME_START))
    DOWNTIME_HOURS=$((DOWNTIME_DURATION / 3600))
    DOWNTIME_MINUTES=$(( (DOWNTIME_DURATION % 3600) / 60 ))
    DOWNTIME_SECONDS=$((DOWNTIME_DURATION % 60))
    # Add downtime to monthly downtime
    CURRENT_MONTH=$(date +%Y-%m)
    if [ -f "$MONTHLY_DOWNTIME_FILE" ]; then
      MONTHLY_DOWNTIME=$(cat "$MONTHLY_DOWNTIME_FILE")
    else
      MONTHLY_DOWNTIME=0
    fi
    MONTHLY_DOWNTIME=$((MONTHLY_DOWNTIME + DOWNTIME_DURATION))
    echo "$MONTHLY_DOWNTIME" > "$MONTHLY_DOWNTIME_FILE"
    # Send Telegram message with downtime duration
    MESSAGE_UP_WITH_DURATION="Ping to $IP restored! Downtime duration: ${DOWNTIME_HOURS}h ${DOWNTIME_MINUTES}m ${DOWNTIME_SECONDS}s"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id=$CHAT_ID -d text="$MESSAGE_UP_WITH_DURATION" > /dev/null 2>&1
    # Remove cache files
    rm "$CACHE_FILE"
    rm "$DOWNTIME_START_FILE"
  fi
fi

# Check if it's the 1st of the month
if [ $(date +%d) -eq 1 ]; then
  # Send monthly downtime report
  CURRENT_MONTH=$(date +%Y-%m)
  PREVIOUS_MONTH=$(date -d "-1 month" +%Y-%m)
  if [ -f "$MONTHLY_DOWNTIME_FILE" ]; then
    MONTHLY_DOWNTIME=$(cat "$MONTHLY_DOWNTIME_FILE")
    rm "$MONTHLY_DOWNTIME_FILE"
    MESSAGE_MONTHLY_DOWNTIME="Monthly downtime report for $PREVIOUS_MONTH: ${MONTHLY_DOWNTIME} seconds"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id=$CHAT_ID -d text="$MESSAGE_MONTHLY_DOWNTIME" > /dev/null 2>&1
  fi
fi
