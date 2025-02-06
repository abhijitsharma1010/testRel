#!/bin/bash

ip_address="1.10.10.10"
#ip_address="1.1.1.1"
#ip_address="8.8.8.8"
#ip_address="9.9.9.9"

stopped_after_date=$(date -d "15 days ago" +%Y-%m-%d)
stopped_before_date=$(date +%Y-%m-%d)
date=$(date +%Y-%m-%d)

# Get the list of Indian IPv4 probes
ripe-atlas probe-search --country IN --status 1 --aggregate-by asn_v4 --limit 500 --max-per-aggregation 1 --ids-only > list.of.indian.ipv4.probes

# Initialize an empty file to store all measurement IDs
> all.measurement.ids

# Loop through the date range in 2-day increments
current_date="$stopped_before_date"
while [[ "$current_date" > "$stopped_after_date" ]]; do
    # Calculate the start date for the batch (2 days before the current date)
    batch_start_date=$(date -d "$current_date - 2 days" +%Y-%m-%d)
    
    # Search for measurements in the current 2-day batch
    ripe-atlas measurement-search --type ping --af 4 --search $ip_address --stopped-after $batch_start_date --stopped-before $current_date --ids-only --limit 1000 > $batch_start_date-$current_date.$ip_address.ping.measurements
    
    # Append the measurement IDs to the combined file
    cat $batch_start_date-$current_date.$ip_address.ping.measurements >> all.measurement.ids
    
    # Move to the next batch
    current_date="$batch_start_date"
done

# Process the combined measurement IDs
> ping.$ip_address.from.indian.probes
for i in $(cat all.measurement.ids); do
    echo $i
    ripe-atlas report $i --probes list.of.indian.ipv4.probes >> ping.$ip_address.from.indian.probes
done

# Extract and calculate the average ping time
awk '/^rtt/ {print $4}' ping.$ip_address.from.indian.probes > time.test
awk -i inplace '{gsub("/", " "); print}' time.test
awk '{print $3}' time.test > time.new

> mean.values
sum=0
numbers=0
for j in $(awk '{print $1}' time.new); do
    k=${j//[!0-9.]/}
    echo $k >> mean.values
    sum=$(echo $sum $k | awk '{print $1+$2}')
    ((numbers+=1))
done

# Calculate the average ping time
((numbers==0)) && avg=0 || avg=$(echo "$sum / $numbers" | bc -l)
printf "Avg ping time for $ip_address is :%.2f\n" $avg
