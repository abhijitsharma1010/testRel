#!/bin/bash

# Your bot token and chat ID
BOT_TOKEN="7076683762:AAHVFQFxTPmCLN2d4rLdaSC3dzQQn8EB47A"
CHAT_ID="1002149806561"

# The IP address to monitor
IP_ADDRESS="10.1.1.2"

# Function to send a message via Telegram
send_telegram_message() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id=$CHAT_ID -d text="$message"
}

# Ping the IP address
ping -c 1 $IP_ADDRESS > /dev/null 2>&1

# Check the exit status of the ping command
if [ $? -ne 0 ]; then
    # If the IP is not reachable, send a Telegram message
    send_telegram_message "Alert: $IP_ADDRESS is not reachable."
fi
