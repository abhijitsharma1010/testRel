#!/bin/bash

# Step 1: Search for Indian probes
echo "Fetching Indian probes..."
indian_probes=$(ripe-atlas probe-search --country IN --ids-only)
if [ -z "$indian_probes" ]; then
  echo "No Indian probes found."
  exit 1
fi

# Step 2: Search for ping measurements made using Indian probes to "1.10.10.10"
echo "Searching for ping measurements to 1.10.10.10 using Indian probes..."
measurement_ids=$(ripe-atlas measurement-search --target 1.10.10.10 --probes "$indian_probes" --type ping --ids-only)
if [ -z "$measurement_ids" ]; then
  echo "No measurements found for the target IP using Indian probes."
  exit 1
fi

# Step 3: Fetch results and calculate average RTT
echo "Calculating average RTT..."
total_rtt=0
count=0

for measurement_id in $measurement_ids; do
  # Get measurement results in JSON format
  results=$(ripe-atlas report $measurement_id --format json)

  # Extract RTT values from the JSON and calculate the average
  rtts=$(echo "$results" | jq '.result[].avg')
  
  for rtt in $rtts; do
    total_rtt=$(echo "$total_rtt + $rtt" | bc)
    count=$((count + 1))
  done
done

if [ $count -eq 0 ]; then
  echo "No RTT values found."
else
  average_rtt=$(echo "$total_rtt / $count" | bc -l)
  echo "Average RTT: $average_rtt ms"
fi
