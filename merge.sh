#!/bin/bash

# Read b.txt and store DNS queries and IPs in an associative array
declare -A b_data
while IFS= read -r line; do
    # Split the line into parts using ' ;; ' as the delimiter
    IFS=' ;; ' read -r dns_query ip1 ip2 ip3 <<< "$line"
    # Store the IPs in the associative array with the DNS query as the key
    b_data["$dns_query"]="$ip1;;$ip2;;$ip3"
done < b.txt

# Process mainoutput.txt and append IPs from b.txt
while IFS= read -r line; do
    if [[ $line == Probe_ID* ]]; then
        # Header line, just print it
        echo "$line"
        continue
    fi

    # Extract DNS_Query from the line
    dns_query=$(echo "$line" | awk -F';;' '{print $2}')

    # Check if DNS_Query exists in b_data
    if [[ -n "${b_data[$dns_query]}" ]]; then
        # Append IPs to the line
        echo "$line;;${b_data[$dns_query]}"
    else
        # No match, just print the original line
        echo "$line"
    fi
done < mainoutput.txt > temp_output.txt

# Replace mainoutput.txt with the updated content
mv temp_output.txt mainoutput.txt
