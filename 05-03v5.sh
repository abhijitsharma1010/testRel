#!/bin/bash

# Input files
mainoutput="mainoutput.txt"
prok="prok.txt"

# Temporary file to store intermediate results
tempfile=$(mktemp)

# Process each DNS query in mainoutput.txt
while IFS= read -r dns_query; do
    # Search for the DNS query in prok.txt and extract client IPs
    ips=$(grep -F "$dns_query" "$prok" | awk '{print $12}' | sort | uniq | tr '\n' ',' | sed 's/,$//')

    # Append the IPs to the DNS query line
    if [ -n "$ips" ]; then
        echo "$dns_query $ips" >> "$tempfile"
    else
        echo "$dns_query" >> "$tempfile"
    fi
done < "$mainoutput"

# Replace mainoutput.txt with the updated content
mv "$tempfile" "$mainoutput"

echo "Updated mainoutput.txt with client IPs."
