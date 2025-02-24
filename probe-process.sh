#!/bin/bash

# Input file containing raw probe info
raw_input_file="raw_probe_info.json"

# Output file to save the formatted probe info
output_file="indian_probes_info.txt"

# Clear the output file if it exists
> "$output_file"

# Read the raw probe info file line by line
while read -r probe_info; do
    # Extract the required fields using jq
    probe_id=$(echo "$probe_info" | jq -r '.id // "N/A"')
    dns_query=$(echo "$probe_info" | jq -r '.dns_query // "N/A"')
    ipv4_address=$(echo "$probe_info" | jq -r '.address_v4 // "N/A"')
    ipv6_address=$(echo "$probe_info" | jq -r '.address_v6 // "N/A"')
    prefix_v4=$(echo "$probe_info" | jq -r '.prefix_v4 // "N/A"')
    prefix_v6=$(echo "$probe_info" | jq -r '.prefix_v6 // "N/A"')
    asn_ipv4=$(echo "$probe_info" | jq -r '.asn_v4 // "N/A"')
    asn_ipv6=$(echo "$probe_info" | jq -r '.asn_v6 // "N/A"')
    country=$(echo "$probe_info" | jq -r '.country_code // "N/A"')
    is_anchor=$(echo "$probe_info" | jq -r '.is_anchor // "N/A"')
    coordinates=$(echo "$probe_info" | jq -r '.geometry.coordinates // "N/A"')

    # Format the output line
    output_line="Probe id:: $probe_id:: DNS query:: $dns_query:: ipv4 address:: $ipv4_address:: ipv6 address:: $ipv6_address:: prefix v4:: $prefix_v4:: prefix v6:: $prefix_v6:: ASNipv4:: $asn_ipv4:: ASNipv6:: $asn_ipv6:: country:: $country:: anchor $is_anchor:: coordinates:: $coordinates"

    # Append the output line to the output file
    echo "$output_line" >> "$output_file"

done < "$raw_input_file"

echo "Formatted probe information has been saved to $output_file"
