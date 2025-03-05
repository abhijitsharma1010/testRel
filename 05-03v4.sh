#!/bin/bash

# Input and output files
mainoutput="mainoutput.txt"
prok="prok.txt"
tempfile=$(mktemp)

# Read each line from mainoutput.txt
while IFS=';;' read -r probe_id dns_query probe_ipv4 probe_ipv6 probe_prefix_v4 probe_prefix_v6 probe_asnv4 probe_country anchor probe_coordinates resolver1 resolver2 resolver3; do
    # Search for the DNS query in prok.txt and extract the IP address from the 12th position
    ip_address=$(grep "$dns_query" "$prok" | awk '{print $12}' | head -n 1)

    # Append the IP address to the end of the line if found
    if [ -n "$ip_address" ]; then
        echo "$probe_id;;$dns_query;;$probe_ipv4;;$probe_ipv6;;$probe_prefix_v4;;$probe_prefix_v6;;$probe_asnv4;;$probe_country;;$anchor;;$probe_coordinates;;$resolver1;;$resolver2;;$resolver3;;$ip_address" >> "$tempfile"
    else
        echo "$probe_id;;$dns_query;;$probe_ipv4;;$probe_ipv6;;$probe_prefix_v4;;$probe_prefix_v6;;$probe_asnv4;;$probe_country;;$anchor;;$probe_coordinates;;$resolver1;;$resolver2;;$resolver3" >> "$tempfile"
    fi
done < "$mainoutput"

# Replace the original file with the modified content
mv "$tempfile" "$mainoutput"
