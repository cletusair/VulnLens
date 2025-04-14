#!/bin/bash
# va-lite.sh - Lightweight Vulnerability Assessment Script
# Author: Rohit Cletus 

read -p "Enter target IP or domain: " target
mkdir -p reports
timestamp=$(date +"%Y%m%d_%H%M")
report_dir="reports/$target-$timestamp"
mkdir -p "$report_dir"

echo "[*] Starting vulnerability assessment on $target"
echo "[*] Output will be saved to $report_dir"

# Step 1: Ping check
ping -c 2 $target > /dev/null
if [ $? -ne 0 ]; then
  echo "[-] Host unreachable. Exiting."
  exit 1
fi

# Step 2: Nmap scan - open ports and versions
echo "[+] Running Nmap service/version detection..."
nmap -sV -T4 -oN "$report_dir/nmap.txt" $target

# Step 3: Nikto scan - web server vuln check (if port 80/443 open)
if grep -qE "80/tcp|443/tcp" "$report_dir/nmap.txt"; then
  echo "[+] Running Nikto web vulnerability scan..."
  nikto -h http://$target -output "$report_dir/nikto.txt"
else
  echo "[!] Web server not detected on 80/443 — skipping Nikto."
fi

# Step 4: Searchsploit - match services with known exploits
echo "[+] Extracting versions and checking with Searchsploit..."
grep -Eo '[0-9]+\.[0-9]+(\.[0-9]+)?' "$report_dir/nmap.txt" | while read version; do
  echo "[*] Searching exploits for version $version..."
  searchsploit $version >> "$report_dir/searchsploit.txt"
done

echo "[+] Vulnerability Assessment Complete!"
echo "✔ Reports saved to $report_dir"
