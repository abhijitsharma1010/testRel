#!/bin/bash

# Input and output files
mainoutput="mainoutput.txt"
queries="queries-20250303.gz"

# Temporary file to store the modified lines
tempfile=$(mktemp)

# Read each line from mainoutput.txt
while IFS=';;' read -r probe_id dns_query probe_ipv4 probe_ipv6 probe_prefix_v4 probe_prefix_v6 probe_asnv4 probe_country anchor probe_coordinates resolver_1 resolver_2 resolver_3; do
    # Search for the DNS_Query in queries-20250303.gz and extract the IP addresses from the 12th field
    ips=$(zgrep "$dns_query" "$queries" | awk -F';;' '{print $12}' | tr '\n' ',' | sed 's/,$//')

    # Append the IPs to the end of the line
    echo "$probe_id;;$dns_query;;$probe_ipv4;;$probe_ipv6;;$probe_prefix_v4;;$probe_prefix_v6;;$probe_asnv4;;$probe_country;;$anchor;;$probe_coordinates;;$resolver_1;;$resolver_2;;$resolver_3;;$ips" >> "$tempfile"
done < "$mainoutput"

# Replace the original file with the modified file
mv "$tempfile" "$mainoutput"

echo "IP addresses have been appended to the end of each line in $mainoutput."
