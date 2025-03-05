#!/bin/bash

# Temporary file to store the modified output
temp_file=$(mktemp)

# Read mainoutput.txt line by line
while IFS=';' read -r -a fields; do
    dns_query=${fields[1]}
    
    # Search for exact matching DNS queries in the gzipped file
    matching_ips=$(zgrep -F "^$dns_query;" queries-20250303.gz | awk -F';' '{print $12}' | sort -u | tr '\n' ',' | sed 's/,$//')
    
    # If matching IPs are found, append them to the line
    if [ -n "$matching_ips" ]; then
        echo "${fields[*]};$matching_ips" >> "$temp_file"
    else
        echo "${fields[*]}" >> "$temp_file"
    fi
done < mainoutput.txt

# Replace the original file with the modified content
mv "$temp_file" mainoutput.txt
