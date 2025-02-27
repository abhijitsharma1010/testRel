#!/bin/bash

# Input files
dns_file="dns.txt"
probe_info_file="probe_info.txt"

# Function to extract value for a given key from probe_info.txt
extract_value() {
    local key="$1"
    local file="$2"
    grep -oP "(?<=$key\s{20,}).*" "$file"
}

# Read the probe_info.txt file and store the data in an associative array
declare -A probe_info
while IFS= read -r line; do
    if [[ $line =~ ^ID ]]; then
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
        # Store the probe information in the associative array
        probe_info["$probe_id"]="$ipv4_address::$ipv6_address::$prefix_v4::$prefix_v6::$asn_ipv4::$country::$anchor::$coordinates"
    fi
done < "$probe_info_file"

# Read the dns.txt file and process each probe
while IFS= read -r line; do
    if [[ $line =~ ^Probe\ #[0-9]+ ]]; then
        # Extract probe ID from dns.txt
        probe_id=$(echo "$line" | grep -oP '(?<=Probe #)[0-9]+')
    elif [[ $line =~ ^;;\ SERVER ]]; then
        # Extract the server IP address used for the DNS query
        server_ip=$(echo "$line" | grep -oP '(?<=SERVER: )[^#]+')
        # Get the probe information from the associative array
        if [[ -n "${probe_info[$probe_id]}" ]]; then
            IFS='::' read -r ipv4_address ipv6_address prefix_v4 prefix_v6 asn_ipv4 country anchor coordinates <<< "${probe_info[$probe_id]}"
            # Output the formatted information
            echo "$probe_id :: DNS query :: $ipv4_address :: $ipv6_address :: $prefix_v4 :: $prefix_v6 :: $asn_ipv4 :: $country :: $anchor :: $coordinates :: $server_ip"
        fi
    fi
done < "$dns_file"
