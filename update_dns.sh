#!/bin/bash

# Define the input files
main_output_file="mainoutput.txt"
queries_file="queries-20250303.gz"

# Create a temporary file to store the updated output
temp_file="temp_output.txt"

# Clear the temporary file
> "$temp_file"

# Read each line from mainoutput.txt
while IFS=';;' read -r probe_id dns_query probe_ipv4 probe_ipv6 probe_prefix_v4 probe_prefix_v6 probe_asnv4 probe_country anchor probe_coordinates resolver_1 resolver_2 resolver_3; do
    # Initialize a variable to hold the matched IPs
    matched_ips=""

    # Search for the DNS_Query in the gzipped queries file
    # Use zgrep to search for the DNS_Query in the compressed file
    while IFS=';;' read -r _ _ _ _ _ _ _ _ _ _ _ ip; do
        if [[ "$dns_query" == "$_" ]]; then
            # Append the found IP to matched_ips
            matched_ips+="$ip "
        fi
    done < <(zcat "$queries_file" | grep "$dns_query")

    # If matched_ips is not empty, append it to the line
    if [[ -n "$matched_ips" ]]; then
        echo "$probe_id;;$dns_query;;$probe_ipv4;;$probe_ipv6;;$probe_prefix_v4;;$probe_prefix_v6;;$probe_asnv4;;$probe_country;;$anchor;;$probe_coordinates;;$resolver_1;;$resolver_2;;$resolver_3;;$matched_ips" >> "$temp_file"
    else
        # If no matches, write the original line
        echo "$probe_id;;$dns_query;;$probe_ipv4;;$probe_ipv6;;$probe_prefix_v4;;$probe_prefix_v6;;$probe_asnv4;;$probe_country;;$anchor;;$probe_coordinates;;$resolver_1;;$resolver_2;;$resolver_3" >> "$temp_file"
    fi
done < "$main_output_file"

# Replace the original file with the updated one
mv "$temp_file" "$main_output_file"

echo "Processing complete. Updated $main_output_file with matched IPs."
