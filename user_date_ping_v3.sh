#!/bin/bash

# List of IP addresses to process
ip_addresses=("1.10.10.10" "1.1.1.1" "8.8.8.8" "9.9.9.9")

# Ask the user for the starting date
read -p "Enter the starting date (YYYY-MM-DD) for the 15-day period: " user_start_date

# Validate the user input date format
if ! date -d "$user_start_date" > /dev/null 2>&1; then
    echo "Invalid date format. Please use YYYY-MM-DD."
    exit 1
fi

# Calculate the date range
stopped_after_date=$(date -d "$user_start_date" +%Y-%m-%d)
stopped_before_date=$(date -d "$stopped_after_date + 15 days" +%Y-%m-%d)
date=$(date +%Y-%m-%d)

# Output file
output_file="output.txt"

# Clear the output file
> "$output_file"

# Write the start and end dates to the output file
echo "Start Date: $stopped_after_date" >> "$output_file"
echo "End Date: $stopped_before_date" >> "$output_file"
echo "" >> "$output_file"  # Add a blank line for readability

# Display progress
echo "Script started. Processing data from $stopped_after_date to $stopped_before_date."

# Get the list of Indian IPv4 probes
echo "Fetching list of Indian IPv4 probes..."
ripe-atlas probe-search --country IN --status 1 --limit 500 --ids-only > list.of.indian.ipv4.probes
echo "List of Indian IPv4 probes fetched and saved to list.of.indian.ipv4.probes."

# Loop through each IP address
for ip_address in "${ip_addresses[@]}"; do
    echo "Processing IP address: $ip_address"

    # Initialize the file to store all measurement IDs
    > all.measurement.ids.$ip_address

    # Loop through the date range in 2-day increments
    current_date=$(date -d "$stopped_after_date" +%Y-%m-%d)
    while [[ "$current_date" < "$stopped_before_date" ]]; do
        next_date=$(date -d "$current_date + 2 days" +%Y-%m-%d)
        
        # Display progress for the current date range
        echo "Searching for measurements between $current_date and $next_date..."
        
        # Search for measurements in the current 2-day window
        ripe-atlas measurement-search --type ping --af 4 --search $ip_address --started-after $current_date --started-before $next_date --ids-only --limit 1000 >> all.measurement.ids.$ip_address
        
        # Move to the next 2-day window
        current_date=$next_date
    done

    echo "Measurements for IP $ip_address collected."

    # Process the measurements
    echo "Processing measurements for IP $ip_address..."
    > ping.$ip_address.from.indian.probes
    for i in $(cat all.measurement.ids.$ip_address); do
        ripe-atlas report $i --probes list.of.indian.ipv4.probes >> ping.$ip_address.from.indian.probes
    done

    echo "Measurements processed for IP $ip_address."

    # Calculate the average ping time
    awk '/^rtt/ {print $4}' ping.$ip_address.from.indian.probes > time.test
    awk -i inplace '{gsub("/", " "); print}' time.test
    awk '{print $3}' time.test > time.new.$ip_address

    sum=0
    numbers=0
    for j in $(awk '{print $1}' time.new.$ip_address); do
        k=${j//[!0-9.]/}
        sum=$(echo $sum $k | awk '{print $1+$2}')
        ((numbers+=1))
    done

    # Calculate the average ping time
    if ((numbers == 0)); then
        avg=0
    else
        avg=$(echo "$sum / $numbers" | bc -l)
    fi

    # Save the average ping time to the output file
    printf "Avg ping time for $ip_address is :%.2f\n" $avg >> "$output_file"
    echo "Average ping time for $ip_address calculated: $avg ms"
done

echo "Script completed. Results saved to $output_file."
