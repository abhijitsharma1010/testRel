#!/bin/sh

API_TOKEN="7076683762:AAHVFQFxTPmCLN2d4rLdaSC3dzQQn8EB47A"
CHAT_ID="1002149806561"

while true
do
    ping -q -w 5 -c 1 10.1.1.2
    if [ "$?" -ne 0 ]; then
        curl -s -o /dev/null -X POST -H "Content-Type: application/json" -d "{\"chat_id\": \"$CHAT_ID\", \"text\": \"IP 10.1.1.2 is not reachable\", \"disable_notification\": false}" https://api.telegram.org/bot$API_TOKEN/sendMessage
    fi
    sleep 60
done