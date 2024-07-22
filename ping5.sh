#!/bin/bash

# IP address to check
IP="10.1.1.2"

# Telegram bot token and chat ID
BOT_TOKEN="7076683762:AAHVFQFxTPmCLN2d4rLdaSC3dzQQn8EB47A"
CHAT_ID="1002149806561"

# Message to send if IP is not reachable
MESSAGE="The IP address $IP is not reachable."

# Ping the IP address
ping -c 1 $IP > /dev/null 2>&1

# Check if the ping command was successful
if [ $? -ne 0 ]; then
  # Send message to Telegram
  curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d chat_id=$CHAT_ID \
  -d text="$MESSAGE"
fi
