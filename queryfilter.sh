#!/bin/bash

# Input file
input_file="prok.txt"

# Output file
output_file="filtered_dns_queries.txt"

# Clear the output file if it exists
> "$output_file"

# Temporary associative array to store DNS queries and their client IPs
declare -A dns_queries

# Read the input file line by line
while IFS= read -r line; do
    # Check if the line contains 'prok.clean-internet.in'
    if echo "$line" | grep -q 'prok.clean-internet.in'; then
        # Extract the full DNS query
        dns_query=$(echo "$line" | grep -oP '(?<=query: ).*?(?= IN)')

        # Extract the client IP
        client_ip=$(echo "$line" | grep -oP '(?<=client @0x[0-9a-f]+ )[0-9a-f:.]+')

        # Append the client IP to the DNS query in the associative array
        if [[ -n "$dns_query" && -n "$client_ip" ]]; then
            if [[ -z "${dns_queries[$dns_query]}" ]]; then
                dns_queries["$dns_query"]="$client_ip"
            else
                dns_queries["$dns_query"]="${dns_queries[$dns_query]};;$client_ip"
            fi
        fi
    fi
done < "$input_file"

# Write the results to the output file
for query in "${!dns_queries[@]}"; do
    echo "$query;;${dns_queries[$query]}" >> "$output_file"
done

echo "Filtered DNS queries have been saved to $output_file"
