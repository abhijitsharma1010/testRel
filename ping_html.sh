#!/bin/bash

# Set the IP addresses and the date range
#ip_addresses=("1.10.10.10" "36.50.50.50")
ip_addresses=("1.10.10.10" "1.1.1.1" "8.8.8.8")
stopped_after_date=$(date -d "15 days ago" +%Y-%m-%d)
stopped_before_date=$(date +%Y-%m-%d)
date=$(date +%Y-%m-%d)
dns=("Sarvagya " "Cloudflare")
>ping_avg_$date
>ping.html


for ip_address in "${ip_addresses[@]}"; do
	ip=$ip_address

    # Searching all the Indian Probes available over IPv4
    ripe-atlas probe-search --country IN --aggregate-by asn_v4 --limit 500 --max-per-aggregation 1 --ids-only > list.of.indian.ipv4.probes

    # Searching all the global IP address ping results
    # This measurement-search command has a limit of returning only max 1000 ids. We can choose the duration, such as weekly, so that we don't miss any results
    ripe-atlas measurement-search --type ping --af 4 --search $ip_address --stopped-after $stopped_after_date --ids-only --limit 1000 > $stopped_after_date-$stopped_before_date.$ip_address.ping.measurements

    # Now we have the IP address ping measurement IDs and the Indian probes list
    # Filter the results for the desired probe list
    > ping.$ip_address.from.indian.probes
    for i in $(cat $stopped_after_date-$stopped_before_date.$ip_address.ping.measurements); do
        echo $i
        ripe-atlas report $i --probes list.of.indian.ipv4.probes >> ping.$ip_address.from.indian.probes
    done

    # Filter out average ping time from probe output.
    awk '/^rtt/ {print $4}' ping.$ip_address.from.indian.probes > time.test
    awk -i inplace '{gsub("/", " "); print}' time.test
    awk '{print $3}' time.test > time.new

    # Next is finding out the mean value
    > mean.values
    sum=0
    numbers=0
    for j in $(awk '{print $1}' time.new); do
        k=${j//[!0-9.]/}
        echo $k >> mean.values
        sum=$(echo $sum $k | awk '{print $1+$2}')
        ((numbers+=1))
done
((numbers==0)) && avg=0 || avg=$(echo "$sum / $numbers" | bc -l)
printf "Avg ping time is :%.2f\n" $avg
output=$(printf "%.2f\n" $avg)
echo "$output"_"$ip_address" >> ping_avg_$date
  

if [ ! -f "ping_avg_$date" ]; then
    echo "Error: ping_avg_$date file not found."
    exit 1
fi

# Read each line from the file
while read -r line; do
    # Separate values before and after _
    time="${line%%_*}"
    ipadd="${line#*_}"

done < "ping_avg_$date"



echo '                                    <progress max="100" value="'$time'" class="progressStrip-1">
                                        <div class="progress-bar"></div>
                                    </progress>
                                    <p class="progress-text mb-4" data-value="'$time'">'$ipadd'</p>
				                            ' >> ping.html


done

cat html1 > main.html
cat ping.html >> main.html
cat html2 >> main.html

