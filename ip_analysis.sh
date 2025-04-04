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

# Improved IP extraction that better handles IPv6
awk '{
    for (i=1; i<=NF; i++) {
        if ($i ~ /^SERVER[0-9]+:/) {
            ip = $(i+1)
            # Remove any trailing comma or other characters after IP
            gsub(/[^0-9a-fA-F:.]/, "", ip)
            # Match either IPv4 or IPv6
            if (ip ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}$/ || ip ~ /^[0-9a-fA-F:]+$/ && ip ~ /:/) {
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
grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}$' temp_ips.txt | while read count ip; do
    if ! is_private_ipv4 "$ip"; then
        printf "%8s %s\n" "$count" "$ip" >> "$output_file"
    fi
done

echo -e "\nPRIVATE IPv4 ADDRESSES (Count | Address):" >> "$output_file"
grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}$' temp_ips.txt | while read count ip; do
    if is_private_ipv4 "$ip"; then
        printf "%8s %s\n" "$count" "$ip" >> "$output_file"
    fi
done

echo -e "\nIPv6 ADDRESSES (Count | Address):" >> "$output_file"
grep -E '^[0-9a-fA-F:]+$' temp_ips.txt | while read count ip; do
    printf "%8s %s\n" "$count" "$ip" >> "$output_file"
done

# Clean up
rm temp_ips.txt

echo "IP analysis complete. Results saved to $output_file"
echo "Total IPv6 addresses found: $(grep -cE '^[0-9a-fA-F:]+$' "$output_file")"
