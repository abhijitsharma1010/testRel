# Read the contents of b.txt and store it in a dictionary
b_data = {}
with open('b.txt', 'r') as b_file:
    for line in b_file:
        parts = line.strip().split(' ;; ')
        dns_query = parts[0]
        ips = parts[1:]
        b_data[dns_query] = ips

# Process mainoutput.txt and append the IPs from b.txt
output_lines = []
with open('mainoutput.txt', 'r') as main_file:
    for line in main_file:
        line = line.strip()
        if line.startswith('Probe_ID'):  # Header line
            output_lines.append(line)
            continue
        
        parts = line.split(';;')
        dns_query = parts[1]
        
        if dns_query in b_data:
            ips = b_data[dns_query]
            appended_ips = ';;'.join(ips)
            new_line = f"{line};;{appended_ips}"
            output_lines.append(new_line)
        else:
            output_lines.append(line)

# Write the updated content back to mainoutput.txt
with open('mainoutput.txt', 'w') as main_file:
    for line in output_lines:
        main_file.write(line + '\n')
