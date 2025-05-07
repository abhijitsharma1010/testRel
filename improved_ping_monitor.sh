#!/bin/bash

# Set variables
IP="10.2.2.1"
BOT_TOKEN="7076683762:AAHVFQFxTPmCLN2d4rLdaSC3dzQQn8EB47"
CHAT_ID="-100214980656"
CACHE_FILE="/tmp/ping_status_cache"
DOWNTIME_FILE="/tmp/ping_downtime_start"
UPDATE_INTERVAL=30  # Minutes between status updates
PING_COUNT=3        # Number of pings to try before determining status
PING_TIMEOUT=2      # Seconds to wait for each ping response

# Function to format time duration in human-readable format
format_duration() {
  local duration_minutes=$1
  
  if [[ $duration_minutes -lt 60 ]]; then
    echo "${duration_minutes} minutes"
  else
    local hours=$((duration_minutes / 60))
    local minutes=$((duration_minutes % 60))
    
    if [[ $minutes -eq 0 ]]; then
      echo "${hours} hours"
    else
      echo "${hours} hours and ${minutes} minutes"
    fi
  fi
}

# Perform multiple pings to reduce false positives
ping_status=0
for i in $(seq 1 $PING_COUNT); do
  ping -c 1 -W $PING_TIMEOUT $IP > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    ping_status=1
    break
  fi
  # Short delay between ping attempts
  sleep 1
done

current_time=$(date +%s)

# Check the status of the ping
if [ $ping_status -eq 0 ]; then
  # Ping failed - target is down
  
  if [ ! -f "$DOWNTIME_FILE" ]; then
    # First time down - record start time and send initial alert
    echo $current_time > "$DOWNTIME_FILE"
    echo "down" > "$CACHE_FILE"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
      -d chat_id=$CHAT_ID \
      -d text="Ping to $IP failed! Device is down." > /dev/null 2>&1
  else
    # Already down - check if we need to send a periodic update
    downtime_start=$(cat "$DOWNTIME_FILE")
    downtime_seconds=$((current_time - downtime_start))
    downtime_minutes=$((downtime_seconds / 60))
    
    # Check when the last notification was sent
    last_notification=0
    if [ -f "$CACHE_FILE" ]; then
      last_notification=$(stat -c %Y "$CACHE_FILE")
    fi
    
    time_since_last_notification=$((current_time - last_notification))
    minutes_since_last_notification=$((time_since_last_notification / 60))
    
    # Send update if it's been approximately UPDATE_INTERVAL minutes since last notification
    if [ $minutes_since_last_notification -ge $UPDATE_INTERVAL ]; then
      human_readable_downtime=$(format_duration $downtime_minutes)
      
      curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id=$CHAT_ID \
        -d text="Ping to $IP still failing! Device has been down for $human_readable_downtime." > /dev/null 2>&1
      
      # Update cache file timestamp to mark when we sent this notification
      echo "down" > "$CACHE_FILE"
    fi
  fi
else
  # Ping succeeded - target is up
  
  if [ -f "$DOWNTIME_FILE" ]; then
    # Device was previously down and is now up
    downtime_start=$(cat "$DOWNTIME_FILE")
    downtime_seconds=$((current_time - downtime_start))
    downtime_minutes=$((downtime_seconds / 60))
    human_readable_downtime=$(format_duration $downtime_minutes)
    
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
      -d chat_id=$CHAT_ID \
      -d text="Ping to $IP restored! Device was down for $human_readable_downtime." > /dev/null 2>&1
    
    # Clean up status files
    rm -f "$DOWNTIME_FILE"
    rm -f "$CACHE_FILE"
  fi
  # If it was already up, do nothing
fi
