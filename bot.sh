#!/bin/bash

# Set your Telegram bot token and chat ID
BOT_TOKEN="7076683762:AAHVFQFxTPmCLN2d4rLdaSC3dzQQn8EB47A"
CHAT_ID="-4238307626"

# Get system resources
CPU_USAGE=$(top -b -n 1 | grep "Cpu(s)" | awk '{print $2 + $4}')
RAM_USAGE=$(free -m | awk '/Mem/ {print $3/$2 * 100}')
DISK_USAGE=$(df -h --output=pcent / | awk '{print $1}')

# Create the message
MESSAGE="System Resources:
CPU Usage: $CPU_USAGE%
RAM Usage: $RAM_USAGE%
Disk Usage: $DISK_USAGE%"

# Send the message to Telegram
curl -s --data "text=$MESSAGE" --data "chat_id=$CHAT_ID" "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" > /dev/null
