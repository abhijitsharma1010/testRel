#!/bin/bash

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$dir"

# List of IP addresses
ip_addresses=("2409::1" "2606:4700:4700::1111" "2001:4860:4860::8888" "2620:fe::9")
#ip_addresses=("1.10.10.10" "8.8.8.8" "1.1.1.1" "9.9.9.9")

# Ask user for start and end dates
read -p "Enter the start date (YYYY-MM-DD): " start_date
read -p "Enter the end date (YYYY-MM-DD): " end_date

# Validate the date format
if ! date -d "$start_date" > /dev/null 2>&1; then
    echo "Invalid start date format. Please use YYYY-MM-DD."
    exit 1
fi

if ! date -d "$end_date" > /dev/null 2>&1; then
    echo "Invalid end date format. Please use YYYY-MM-DD."
    exit 1
fi

# Output file
output_file="output.txt"

echo " " >> "$output_file"
echo "Date: $(date +%d-%m-%Y)" >> "$output_file"

# Initialize the output file
##> output.txt
##echo  >> output.txt

# Loop through each IP address
for ip_address in "${ip_addresses[@]}"; do
    echo "Processing IP: $ip_address"
    
    # Get the list of Indian IPv4 probes
    /root/.local/bin/ripe-atlas probe-search --status 1 --country IN --limit 500 --max-per-aggregation 1 --ids-only > list.of.indian.ipv4.probes

    # Initialize an empty file to store all measurement IDs
    > all_measurement_ids.$date.$ip_address

    # Loop through the date range in 2-day increments
    current_date=$(date -d "$start_date" +%Y-%m-%d)
    while [[ "$current_date" < "$end_date" ]]; do
        next_date=$(date -d "$current_date + 2 days" +%Y-%m-%d)
        
        # Ensure the next_date does not exceed the end_date
        if [[ "$next_date" > "$end_date" ]]; then
            next_date="$end_date"
        fi
        
        echo "Searching measurements between $current_date and $next_date"
        
        # Search for measurements in the current 2-day window
        /root/.local/bin/ripe-atlas measurement-search --type dns --af 6 --search $ip_address --ids-only --limit 1000 --started-after $current_date --started-before $next_date >> all_measurement_ids.$date.$ip_address
        
        # Move to the next 2-day window
        current_date="$next_date"
    done

    # Process the measurements using the list of Indian probes
    > dns.$date.$ip_address.from.indian.probes
    for i in $(cat all_measurement_ids.$date.$ip_address); do
        echo $i
        /root/.local/bin/ripe-atlas report $i --probes list.of.indian.ipv4.probes >> dns.$date.$ip_address.from.indian.probes
    done

    # Extract and calculate the average DNS query time
    grep "Query time" dns.$date.$ip_address.from.indian.probes > query_time_$date.$ip_address

    > new
    awk '{print $4}' query_time_$date.$ip_address > new
    avg=$(awk '{sum += $1; count++} END {if (count > 0) print sum/count; else print "No data"}' new)

    # Append the date and DNS query time to output.txt
    printf "Avg DNS query time for $ip_address is: %.2f\n" $avg >> "$output_file"
    printf "Avg DNS query time for $ip_address is: %.2f\n" $avg
done
