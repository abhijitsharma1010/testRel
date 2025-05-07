#!/bin/bash

# Set variables
IP="10.2.2.1"
BOT_TOKEN="7076683762:AAHVFQFxTPmCLN2d4rLdaSC3dzQQn8EB47A"
CHAT_ID="-4238307626"
DOWNTIME_TRACKING_DIR="/tmp/ping_monitor"
STATUS_FILE="${DOWNTIME_TRACKING_DIR}/status"
DOWNTIME_START_FILE="${DOWNTIME_TRACKING_DIR}/downtime_start"
LAST_NOTIFICATION_FILE="${DOWNTIME_TRACKING_DIR}/last_notification"
UPDATE_INTERVAL=30  # Minutes between status updates
PING_COUNT=3        # Number of pings to try before determining status
PING_TIMEOUT=2      # Seconds to wait for each ping response

# Create tracking directory if it doesn't exist
mkdir -p "$DOWNTIME_TRACKING_DIR"

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

# Function to send Telegram message
send_telegram_message() {
  local message="$1"
  curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id=$CHAT_ID \
    -d text="$message" > /dev/null 2>&1
  
  # Record when we sent this notification
  echo "$(date +%s)" > "$LAST_NOTIFICATION_FILE"
}

# Current time in seconds since epoch
current_time=$(date +%s)

# Perform multiple pings to reduce false positives
ping_success=false
for i in $(seq 1 $PING_COUNT); do
  if ping -c 1 -W $PING_TIMEOUT $IP > /dev/null 2>&1; then
    ping_success=true
    break
  fi
  # Short delay between ping attempts
  sleep 1
done

# Check if IP is up or down
if $ping_success; then
  # IP is up
  if [ -f "$STATUS_FILE" ] && [ "$(cat "$STATUS_FILE")" == "down" ]; then
    # IP was previously down, now it's up
    if [ -f "$DOWNTIME_START_FILE" ]; then
      downtime_start=$(cat "$DOWNTIME_START_FILE")
      downtime_seconds=$((current_time - downtime_start))
      downtime_minutes=$((downtime_seconds / 60))
      human_readable_downtime=$(format_duration $downtime_minutes)
      
      send_telegram_message "Ping to $IP restored! Device was down for $human_readable_downtime."
    else
      send_telegram_message "Ping to $IP restored!"
    fi
    
    # Update status and clean up tracking files
    echo "up" > "$STATUS_FILE"
    rm -f "$DOWNTIME_START_FILE"
    rm -f "$LAST_NOTIFICATION_FILE"
  elif [ ! -f "$STATUS_FILE" ]; then
    # Initialize status file if it doesn't exist
    echo "up" > "$STATUS_FILE"
  fi
  # If it was already up, do nothing
else
  # IP is down
  if [ ! -f "$STATUS_FILE" ] || [ "$(cat "$STATUS_FILE")" != "down" ]; then
    # First time down or status was up before
    echo "down" > "$STATUS_FILE"
    echo "$current_time" > "$DOWNTIME_START_FILE"
    send_telegram_message "Ping to $IP failed! Device is down."
  else
    # Already down, check if we need to send a periodic update
    if [ -f "$DOWNTIME_START_FILE" ]; then
      downtime_start=$(cat "$DOWNTIME_START_FILE")
      downtime_seconds=$((current_time - downtime_start))
      downtime_minutes=$((downtime_seconds / 60))
      
      # Check when the last notification was sent
      if [ -f "$LAST_NOTIFICATION_FILE" ]; then
        last_notification=$(cat "$LAST_NOTIFICATION_FILE")
        time_since_last_notification=$((current_time - last_notification))
        minutes_since_last_notification=$((time_since_last_notification / 60))
        
        # Send update if it's been at least UPDATE_INTERVAL minutes
        if [ $minutes_since_last_notification -ge $UPDATE_INTERVAL ]; then
          human_readable_downtime=$(format_duration $downtime_minutes)
          send_telegram_message "Ping to $IP still failing! Device has been down for $human_readable_downtime."
        fi
      else
        # No record of last notification, should never happen but just in case
        echo "$current_time" > "$LAST_NOTIFICATION_FILE"
      fi
    else
      # No downtime start recorded, initialize it
      echo "$current_time" > "$DOWNTIME_START_FILE"
    fi
  fi
fi
