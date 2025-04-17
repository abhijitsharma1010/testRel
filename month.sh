#!/bin/bash

# Check if month and year arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <month> <year>"
    echo "Example: $0 05 2025"
    exit 1
fi

month=$1
year=$2

# Create output directory if it doesn't exist
output_dir="monthly_summaries"
mkdir -p "$output_dir"

# Output file name
output_file="$output_dir/public_ips_${month}-${year}.txt"

# Temporary file for processing
temp_file=$(mktemp)

# Process all daily files for the given month and year
for file in ip_analysis_${month}-[0-9][0-9]-${year}.txt; do
    if [ -f "$file" ]; then
        # Extract public IP section, remove headers and footers, and clean the data
        awk '/PUBLIC IPv4 ADDRESSES/,/PRIVATE IPv4 ADDRESSES/' "$file" | 
        grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |
        sed 's/^[[:space:]]*//' | 
        awk '{print $2, $1}' >> "$temp_file"
    fi
done

# Sum counts by IP address and sort by count (descending)
awk '{
    ip = $1;
    count = $2;
    sum[ip] += count;
}
END {
    for (ip in sum) {
        printf "%6d %s\n", sum[ip], ip;
    }
}' "$temp_file" | sort -rn > "$output_file"

# Add header to the output file
header="Monthly Public IP Address Summary\nMonth: ${month}-${year}\nGenerated on $(date)\n======================================"
sed -i "1i$header" "$output_file"

# Clean up
rm "$temp_file"

echo "Monthly summary created: $output_file"
