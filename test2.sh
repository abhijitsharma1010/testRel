#!/bin/bash

# Define the target IP address
TARGET_IP="1.10.10.10"

# Step 1: Get the list of Indian probes
# Assuming you have a command to get probes and their locations
# Replace `ripe-atlas probes` with the actual command to list probes
INDIAN_PROBES=$(ripe-atlas probes --country IN --format json | jq -r '.[].id')

# Step 2: Get ping measurements from Indian probes to the target IP
# Replace `ripe-atlas measurements` with the actual command to get measurements
MEASUREMENTS=$(ripe-atlas measurements --target $TARGET_IP --probes $INDIAN_PROBES --format json)

# Step 3: Extract the round-trip times (RTTs) from the measurements
RTT_VALUES=$(echo "$MEASUREMENTS" | jq -r '.[] | .result[] | select(.rtt != null) | .rtt')

# Step 4: Calculate the average RTT
if [ -z "$RTT_VALUES" ]; then
    echo "No RTT values found."
    exit 1
fi

# Calculate the average
SUM=0
COUNT=0

for RTT in $RTT_VALUES; do
    SUM=$(echo "$SUM + $RTT" | bc)
    COUNT=$((COUNT + 1))
done

if [ $COUNT -eq 0 ]; then
    echo "No RTT values to calculate average."
    exit 1
fi

AVERAGE=$(echo "scale=2; $SUM / $COUNT" | bc)

# Step 5: Output the average RTT
echo "Average RTT from Indian probes to $TARGET_IP: $AVERAGE ms"
