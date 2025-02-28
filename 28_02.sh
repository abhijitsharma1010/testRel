#!/bin/bash

# Input file
input_file="probe_info.txt"
log_file="script_output.log"

# Function to extract value for a given key
extract_value() {
    local key="$1"
    local file="$2"
    grep -oP "(?<=$key\s{20,}).*" "$file"
}

# Function to extract resolver IPs for a given probe ID
extract_resolvers() {
    local probe_id="$1"
    local log_file="$2"
    resolvers=$(grep -A 20 "Probe ID: $probe_id" "$log_file" | grep "SERVER:" | awk '{print $2}' | tr '\n' ' ' | sed 's/ / :: /g')
    echo "$resolvers"
}

# Read the file and process each probe
while IFS= read -r line; do
    if [[ $line =~ ^ID ]]; then
        # Extract probe ID
        probe_id=$(echo "$line" | awk '{print $2}')
    elif [[ $line =~ ^Address\ \(IPv4\) ]]; then
        ipv4_address=$(echo "$line" | awk '{print $3}')
    elif [[ $line =~ ^Address\ \(IPv6\) ]]; then
        ipv6_address=$(echo "$line" | awk '{print $3}')
    elif [[ $line =~ ^Prefix\ \(IPv4\) ]]; then
        prefix_v4=$(echo "$line" | awk '{print $3}')
    elif [[ $line =~ ^Prefix\ \(IPv6\) ]]; then
        prefix_v6=$(echo "$line" | awk '{print $3}')
    elif [[ $line =~ ^ASN\ \(IPv4\) ]]; then
        asn_ipv4=$(echo "$line" | awk '{print $3}')
    elif [[ $line =~ ^Country ]]; then
        country=$(echo "$line" | awk '{print $2}')
    elif [[ $line =~ ^Anchor? ]]; then
        anchor=$(echo "$line" | awk '{print $2}')
        if [[ $anchor == "✔" ]]; then
            anchor="yes"
        else
            anchor="no"
        fi
    elif [[ $line =~ ^Coordinates ]]; then
        coordinates=$(echo "$line" | awk '{print $2}')
        # Extract resolver IPs for the probe ID
        resolvers=$(extract_resolvers "$probe_id" "$log_file")
        # Output the formatted information
        echo "$probe_id :: DNS query :: $ipv4_address :: $ipv6_address :: $prefix_v4 :: $prefix_v6 :: $asn_ipv4 :: $country :: $anchor :: $coordinates :: $resolvers"
    fi
done < "$input_file"
