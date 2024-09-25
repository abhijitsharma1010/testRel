#!/bin/bash

# Telegram API token
TOKEN="7076683762:AAHVFQFxTPmCLN2d4rLdaSC3dzQQn8EB47A"

# Chat ID
CHAT_ID="-4238307626"

# Monitor CPU and Memory Usage
CPU_USAGE=$(mpstat -a | awk '$12 ~ /[0-9.]+/ { print 100 - $12 }')
MEMORY_USAGE=$(free -h | awk '/^Mem/ { print $3 "/" $2 }')

# Monitor Disk Space
DISK_SPACE=$(df -h | awk '/^\/$/ { print $5 }')

# Monitor Network Usage
NETWORK_USAGE=$(ifconfig | awk '/RX bytes/ { print $2 }')

# Monitor Running Processes
RUNNING_PROCESSES=$(ps -ef | wc -l)

# Send Telegram message
curl -X POST \
  https://api.telegram.org/bot$TOKEN/sendMessage \
  -H 'Content-Type: application/json' \
  -d '{"chat_id": "'$CHAT_ID'", "text": "CPU Usage: '$CPU_USAGE'%\nMemory Usage: '$MEMORY_USAGE'\nDisk Space: '$DISK_SPACE'\nNetwork Usage: '$NETWORK_USAGE' bytes\nRunning Processes: '$RUNNING_PROCESSES'"}'
