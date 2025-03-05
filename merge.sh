#!/bin/bash

# Process mainoutput.txt and append IPs from b.txt
while IFS= read -r line; do
    if [[ $line == Probe_ID* ]]; then
        # Header line, just print it
        echo "$line"
        continue
    fi

    # Extract DNS_Query from the line
    dns_query=$(echo "$line" | awk -F';;' '{print $2}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Search for the DNS_Query in b.txt and extract the IPs
    ips=$(grep -F "$dns_query" b.txt | awk -F' ;; ' '{print $2 ";;" $3 ";;" $4}')

    # If IPs are found, append them to the line
    if [[ -n "$ips" ]]; then
        echo "$line;;$ips"
    else
        # No match, just print the original line
        echo "$line"
    fi
done < mainoutput.txt > temp_output.txt

# Replace mainoutput.txt with the updated content
mv temp_output.txt mainoutput.txt
