#!/bin/bash

# Enhanced IP Analysis Aggregator Script

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <month> <year>"
    echo "Example: $0 03 2025 (for March 2025)"
    echo "Note: Month should be two digits (01-12)"
    exit 1
fi

month=$(printf "%02d" "$1")  # Ensure two-digit month
year=$2

# Configuration
output_dir="monthly_summaries"
output_file="$output_dir/public_ips_${month}-${year}.txt"
temp_file=$(mktemp)
processed_files=0

# Create output directory with verbose message
echo "Creating output directory '$output_dir' if needed..."
mkdir -p "$output_dir" || { echo "Error creating directory!"; exit 1; }

# Header for output file
header="MONTHLY PUBLIC IP ADDRESS SUMMARY
======================================
Month: ${month}-${year}
Report generated: $(date '+%Y-%m-%d %H:%M:%S %Z')
Total days processed: [DAYS]
======================================
Count   IP Address
------------------"

# Find and process files
echo "Searching for files matching pattern: ip_analysis_${month}-[0-9][0-9]-${year}.txt"

for file in ip_analysis_${month}-[0-9][0-9]-${year}.txt; do
    if [ -f "$file" ]; then
        ((processed_files++))
        echo "  Processing: $file"
        
        # Extract and clean public IP data
        awk '/PUBLIC IPv4 ADDRESSES/,/PRIVATE IPv4 ADDRESSES/' "$file" | 
        grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |
        sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*|[[:space:]]*/ /' |
        awk '{if (NF >= 2) print $2, $1}' >> "$temp_file"
    fi
done

# Verify we found files
if [ "$processed_files" -eq 0 ]; then
    echo "ERROR: No matching files found for ${month}-${year}"
    rm "$temp_file"
    exit 1
fi

echo "Processed $processed_files files with $(wc -l < "$temp_file") IP records"

# Generate summary
echo "Generating monthly summary..."
summary=$(awk '{
    ip = $1;
    count = $2;
    sum[ip] += count;
    total += $2;
}
END {
    # Sort by count descending, then by IP ascending
    n = asorti(sum, sorted, "@val_num_desc");
    for (i = 1; i <= n; i++) {
        ip = sorted[i];
        printf "%7d %s\n", sum[ip], ip;
    }
    print "======================================";
    printf "TOTAL: %d connections from %d unique IPs\n", total, n;
}' "$temp_file")

# Insert processed days count into header
header=$(echo "$header" | sed "s/\[DAYS\]/$processed_files/")

# Write final output
echo "$header" > "$output_file"
echo "$summary" >> "$output_file"

# Clean up
rm "$temp_file"

# Final report
echo "======================================"
echo "MONTHLY SUMMARY COMPLETE"
echo "Output file: $output_file"
echo "Days processed: $processed_files"
echo "Total unique public IPs: $(grep -cE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$output_file")"
echo "Total connections: $(awk '/TOTAL:/ {print $2}' "$output_file")"
echo "======================================"
