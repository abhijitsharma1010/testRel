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

    # CPU Load (1, 5, 15 minute averages)
    cpu_load=$(top -bn1 | grep "load average" | awk '{print $12 $13 $14}')

    # Memory Usage (in MB and percentage)
    mem_usage=$(free -m | awk 'NR==2{printf "%sMB / %sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')

    # Disk Usage (human-readable format)
    disk_usage=$(df -h --output=source,pcent,avail | grep '^/dev/' | awk '{ printf "*%s:* %s used, %s free\n", $1, $2, $3 }')

    # Top 5 processes by memory usage
    top_processes=$(ps aux --sort=-%mem | awk 'NR<=6{printf "  - PID: %s, User: %s, Mem Usage: %.1f%%, Command: %s\n", $2, $1, $4, $11 }')

    # Compile all the information into a user-friendly format
    system_report="*📊 System Monitoring Report:*\n\n"
    system_report+="*🕒 Uptime:* $uptime_info\n\n"
    system_report+="*💻 CPU Load (1m, 5m, 15m):* $cpu_load\n\n"
    system_report+="*📈 Memory Usage:* $mem_usage\n\n"
    system_report+="*💾 Disk Usage:*\n$disk_usage\n\n"
    system_report+="*🔝 Top 5 Processes by Memory Usage:*\n$top_processes\n"

    echo "$system_report"
}

# Send the report via Telegram
report=$(get_system_info)
send_telegram_message "$report"
