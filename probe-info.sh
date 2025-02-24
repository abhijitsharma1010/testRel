#!/bin/bash

# Input file containing Indian IPv4 probe IDs
input_file="list.of.indian.ipv4.probes"

# Output file to save raw probe info
raw_output_file="raw_probe_info.json"

# Clear the raw output file if it exists
> "$raw_output_file"

# Loop through each probe ID in the input file
while read -r probe_id; do
    # Run the ripe-atlas probe-info command and append the output to the raw output file
    ripe-atlas probe-info "$probe_id" >> "$raw_output_file"
done < "$input_file"

echo "Raw probe information has been saved to $raw_output_file"
