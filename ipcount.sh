#!/bin/bash

input_file="output1.txt"
output_file="unique_ips.txt"

# Extract all IPs (IPv4 and IPv6) from SERVER fields, count occurrences, and sort by count
awk '{
    for (i=1; i<=NF; i++) {
        if ($i ~ /^SERVER[0-9]+:/) {
            ip = $(i+1)
            # Remove any trailing comma or other characters after IP
            gsub(/[^0-9a-fA-F:.]/, "", ip)
            if (ip ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}$/ || ip ~ /^[0-9a-fA-F:]+$/) {
                print ip
            }
        }
    }
}' "$input_file" | sort | uniq -c | sort -nr > "$output_file"

echo "Unique IP addresses with counts saved to $output_file"
