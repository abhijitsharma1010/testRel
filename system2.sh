#!/bin/bash

# Your Bot Token and Chat ID
BOT_TOKEN="7076683762:AAHVFQFxTPmCLN2d4rLdaSC3dzQQn8EB47A"
CHAT_ID="-4238307626"

# Function to send a Telegram message
send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="$message" \
    -d parse_mode="Markdown"
}

# Get system information
get_system_info() {
    # Uptime
    uptime_info=$(uptime -p)

    # CPU Load
    cpu_load=$(top -bn1 | grep "load average" | awk '{print $12 $13 $14}')

    # Memory Usage
    mem_usage=$(free -m | awk 'NR==2{printf "Memory Usage: %sMB/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')

    # Disk Usage
    disk_usage=$(df -h | grep '^/dev/' | awk '{ printf "%s: %s used, %s free\n", $1, $3, $4}')

    # Top 5 processes by memory usage
    top_processes=$(ps aux --sort=-%mem | awk 'NR<=6{print $0}')

    # Compile all the information
    system_report="*System Report:*\n\n"
    system_report+="*Uptime:* $uptime_info\n"
    system_report+="*CPU Load:* $cpu_load\n"
    system_report+="*Memory:* $mem_usage\n"
    system_report+="*Disk Usage:*\n$disk_usage\n"
    system_report+="*Top Processes by Memory:* \n$top_processes"

    echo "$system_report"
}

# Send the report via Telegram
report=$(get_system_info)
send_telegram_message "$report"

