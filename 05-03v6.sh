#!/bin/bash

# Input files
mainoutput_file="mainoutput.txt"
prok_file="prok.txt"

# Output file
output_file="output.txt"

# Read each line from mainoutput.txt
while IFS=';;' read -r probe_id dns_query probe_ipv4; do
    # Skip the header line
    if [[ "$probe_id" == "Probe_ID" ]]; then
        echo "$probe_id;;$dns_query;;$probe_ipv4;;Client_IP" > "$output_file"
        continue
    fi

    # Search for the DNS query in prok.txt
    match=$(grep -F "$dns_query" "$prok_file")

    if [[ -n "$match" ]]; then
        # Extract the client IP from the matching line
        client_ip=$(echo "$match" | awk '{print $6}' | awk -F'#' '{print $1}')

        # Append the client IP to the line in mainoutput.txt
        echo "$probe_id;;$dns_query;;$probe_ipv4;;$client_ip" >> "$output_file"
    else
        # If no match is found, just append the original line without the client IP
        echo "$probe_id;;$dns_query;;$probe_ipv4;;" >> "$output_file"
    fi
done < "$mainoutput_file"

echo "Processing complete. Output saved to $output_file."
