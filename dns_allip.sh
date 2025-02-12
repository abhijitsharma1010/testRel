#!/bin/bash

# List of IP addresses
##ip_addresses=("1.10.10.10" "8.8.8.8" "1.1.1.1" "9.9.9.9")
ip_addresses=("1.10.10.10")

# Date range setup
stopped_after_date=$(date -d "15 days ago" +%Y-%m-%d)
stopped_before_date=$(date +%Y-%m-%d)
date=$(date +%Y-%m-%d)

# Initialize the output file
##> output.txt
echo  >> output.txt

# Loop through each IP address
for ip_address in "${ip_addresses[@]}"; do
    echo "Processing IP: $ip_address"
    
    # Get the list of Indian IPv4 probes
    ripe-atlas probe-search --status 1 --country IN --limit 500 --max-per-aggregation 1 --ids-only > list.of.indian.ipv4.probes

    # Initialize an empty file to store all measurement IDs
    > all_measurement_ids.$ip_address

    # Loop through the date range in 2-day increments
    current_date=$(date -d "$stopped_after_date" +%Y-%m-%d)
    while [[ "$current_date" < "$stopped_before_date" ]]; do
        next_date=$(date -d "$current_date + 2 days" +%Y-%m-%d)
        
        # Ensure the next_date does not exceed the stopped_before_date
        if [[ "$next_date" > "$stopped_before_date" ]]; then
            next_date="$stopped_before_date"
        fi
        
        echo "Searching measurements between $current_date and $next_date"
        
        # Search for measurements in the current 2-day window
        ripe-atlas measurement-search --type dns --af 4 --search $ip_address --ids-only --limit 1000 --started-after $current_date --started-before $next_date >> all_measurement_ids.$ip_address
        
        # Move to the next 2-day window
        current_date="$next_date"
    done

    # Process the measurements using the list of Indian probes
    > dns.$ip_address.from.indian.probes
    for i in $(cat all_measurement_ids.$ip_address); do
        echo $i
        ripe-atlas report $i --probes list.of.indian.ipv4.probes >> dns.$ip_address.from.indian.probes
    done

    # Extract and calculate the average DNS query time
    grep "Query time" dns.$ip_address.from.indian.probes > query_time_$ip_address

    > mean.values
    sum=0
    numbers=0
    for j in $(awk '{print $4}' query_time_$ip_address); do
        k=${j//[!0-9.]/}
        echo $k >> mean.values
        sum=$(echo $sum $k | awk '{print $1+$2}')
        ((numbers+=1))
    done

    # Calculate the average DNS query time
    if ((numbers == 0)); then
        avg=0
    else
        avg=$(echo "$sum / $numbers" | bc -l)
    fi

    # Append the date and DNS query time to output.txt
    printf "%s - Avg DNS query time for %s is: %.2f\n" "$date" "$ip_address" "$avg" >> output.txt
done

echo "Script completed. Results saved to output.txt"
