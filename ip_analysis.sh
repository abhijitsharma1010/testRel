#!/bin/bash

input_file="output1.txt"
output_file="ip_analysis.txt"

# Function to check if an IPv4 is private
is_private_ipv4() {
    local ip=$1
    # Check for private IP ranges
    [[ $ip =~ ^10\..* ]] || \
    [[ $ip =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\..* ]] || \
    [[ $ip =~ ^192\.168\..* ]] || \
    [[ $ip =~ ^127\..* ]] || \
    [[ $ip =~ ^169\.254\..* ]] || \
    [[ $ip =~ ^100\.([6-9][0-9]|1[0-1][0-9]|12[0-7])\..* ]]
}

# Extract all IPs with more robust pattern matching
awk '{
    for (i=1; i<=NF; i++) {
        if ($i ~ /^SERVER[0-9]+:/) {
            ip = $(i+1)
            # Remove any trailing non-IP characters (more aggressive cleaning)
            gsub(/[^0-9a-fA-F:.].*$/, "", ip)
            # Match IPv4 or IPv6 (more inclusive patterns)
            if (ip ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}$/ || 
                ip ~ /^[0-9a-fA-F]{1,4}(:[0-9a-fA-F]{1,4}){1,7}$/ ||
                ip ~ /^([0-9a-fA-F]{1,4}:){1,7}:([0-9a-fA-F]{1,4})?$/ ||
                ip ~ /^::([0-9a-fA-F]{1,4}:){0,6}[0-9a-fA-F]{1,4}$/) {
                print ip
            }
        }
    }
}' "$input_file" | sort | uniq -c | sort -nr > temp_ips.txt

# Process the IPs into categories
echo "IP Address Analysis Report" > "$output_file"
echo "Generated on $(date)" >> "$output_file"
echo "======================================" >> "$output_file"

echo -e "\nPUBLIC IPv4 ADDRESSES (Count | Address):" >> "$output_file"
grep -E '^ *[0-9]+ ([0-9]{1,3}\.){3}[0-9]{1,3}$' temp_ips.txt | while read count ip; do
    if ! is_private_ipv4 "$ip"; then
        printf "%8s %s\n" "$count" "$ip" >> "$output_file"
    fi
done

echo -e "\nPRIVATE IPv4 ADDRESSES (Count | Address):" >> "$output_file"
grep -E '^ *[0-9]+ ([0-9]{1,3}\.){3}[0-9]{1,3}$' temp_ips.txt | while read count ip; do
    if is_private_ipv4 "$ip"; then
        printf "%8s %s\n" "$count" "$ip" >> "$output_file"
    fi
done

echo -e "\nIPv6 ADDRESSES (Count | Address):" >> "$output_file"
grep -E '^ *[0-9]+ [0-9a-fA-F:]+$' temp_ips.txt | grep -vE '([0-9]{1,3}\.){3}[0-9]{1,3}' | while read count ip; do
    printf "%8s %s\n" "$count" "$ip" >> "$output_file"
done

# Debug information
echo -e "\nDEBUG INFORMATION:" >> "$output_file"
echo "Total lines processed in temp file: $(wc -l < temp_ips.txt)" >> "$output_file"
echo "IPv4 addresses found: $(grep -Ec '([0-9]{1,3}\.){3}[0-9]{1,3}' temp_ips.txt)" >> "$output_file"
echo "IPv6 addresses found: $(grep -Ec '^ *[0-9]+ [0-9a-fA-F:]+$' temp_ips.txt | grep -vcE '([0-9]{1,3}\.){3}[0-9]{1,3}')" >> "$output_file"

# Clean up
rm temp_ips.txt

echo "IP analysis complete. Results saved to $output_file"
