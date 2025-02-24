#!/bin/bash

# Input file containing Indian IPv4 probe IDs
input_file="list.of.indian.ipv4.probes"

# Output file to save the results
output_file="indian_probes_info.txt"

# Clear the output file if it exists
> "$output_file"

# Loop through each probe ID in the input file
while read -r probe_id; do
    # Run the ripe-atlas probe-info command and capture the output
    probe_info=$(ripe-atlas probe-info "$probe_id")

    # Extract the required fields from the probe-info output
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

done < "$input_file"

echo "Probe information has been saved to $output_file"
