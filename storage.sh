#!/bin/bash

# Set Telegram Bot Token and Chat ID
TOKEN="7076683762:AAHVFQFxTPmCLN2d4rLdaSC3dzQQn8EB47A"
CHAT_ID="-4238307626"

# Set storage and bandwidth monitoring commands
STORAGE_CMD="df -h --output=source,size,used,avail,pcent /"
BANDWIDTH_CMD="vnstat --json"

# Function to send message to Telegram
send_telegram_message() {
  curl -s -X POST \
  https://api.telegram.org/bot$TOKEN/sendMessage \
  -H 'Content-Type: application/json' \
  -d '{"chat_id": "'$CHAT_ID'", "text": "'"$1"'" }'
}

# Main script
while true
do
  # Get storage information
  STORAGE_INFO=$($STORAGE_CMD)
  
  # Get bandwidth information
  BANDWIDTH_INFO=$($BANDWIDTH_CMD)
  
  # Extract relevant information
  STORAGE_USED=$(echo "$STORAGE_INFO" | awk '{print $3}')
  STORAGE_AVAILABLE=$(echo "$STORAGE_INFO" | awk '{print $4}')
  BANDWIDTH_RX=$(echo "$BANDWIDTH_INFO" | jq '.traffic.rx')
  BANDWIDTH_TX=$(echo "$BANDWIDTH_INFO" | jq '.traffic.tx')
  
  # Create message to send to Telegram
  MESSAGE="Storage: $STORAGE_USED / $STORAGE_AVAILABLE\nBandwidth: RX $BANDWIDTH_RX, TX $BANDWIDTH_TX"
  
  # Send message to Telegram
  send_telegram_message "$MESSAGE"
  
  # Wait for 1 hour
  sleep 3600
done
