#!/bin/bash
# VulnLens - Lightweight Recon + Vulnerability Analysis Tool
# Author: Rohit Cletus

read -p "Enter target IP or domain: " target
scan_time=$(date +"%Y-%m-%d_%H-%M")
report_dir="reports/$target-$scan_time"
mkdir -p "$report_dir"

# ---------- Step 1: Nmap Scan ----------
echo "[*] Running Nmap..."
nmap -sV -oN "$report_dir/nmap.txt" $target

# ---------- Step 2: Extract Services & Searchsploit ----------
echo "[*] Extracting services for Searchsploit..."
grep -Eo '[a-zA-Z]+ [0-9]+\.[0-9]+(\.[0-9]+)?' "$report_dir/nmap.txt" | while read line; do
    service=$(echo $line | cut -d ' ' -f1)
    version=$(echo $line | cut -d ' ' -f2)
    echo "[*] Checking exploits for $service $version..."
    searchsploit "$service $version" >> "$report_dir/searchsploit.txt"
done

# ---------- Step 3: WhatWeb (for HTTP) ----------
echo "[*] Running WhatWeb if HTTP is detected..."
if grep -qE "80/tcp|443/tcp" "$report_dir/nmap.txt"; then
    whatweb $target > "$report_dir/whatweb.txt"
fi

# ---------- Step 4: Nikto Scan ----------
echo "[*] Running Nikto (if HTTP present)..."
if grep -qE "80/tcp|443/tcp" "$report_dir/nmap.txt"; then
    nikto -h http://$target -output "$report_dir/nikto.txt"
fi

# ---------- Step 5: Generate Markdown Report ----------
report_md="$report_dir/report.md"
echo "# VulnLens Report" > $report_md
echo "**Target:** $target" >> $report_md
echo "**Scan Time:** $scan_time" >> $report_md
echo -e "\n## Open Ports and Services" >> $report_md
cat "$report_dir/nmap.txt" >> $report_md
echo -e "\n## Detected Technologies" >> $report_md
cat "$report_dir/whatweb.txt" >> $report_md 2>/dev/null || echo "N/A" >> $report_md
echo -e "\n## Known Vulnerabilities (Searchsploit)" >> $report_md
cat "$report_dir/searchsploit.txt" >> $report_md
echo -e "\n## Nikto Web Scan Results" >> $report_md
cat "$report_dir/nikto.txt" >> $report_md 2>/dev/null || echo "No HTTP service detected." >> $report_md

# ---------- Step 6: Convert Markdown to HTML (Optional) ----------
if command -v pandoc &> /dev/null; then
    pandoc "$report_md" -o "$report_dir/report.html"
    echo "[*] HTML report generated at $report_dir/report.html"
else
    echo "[!] Pandoc not found. Skipping HTML export."
fi

echo "[*] Report generated at $report_md"
echo "[*] Done!"
echo "[*] You can view the report in the 'reports' directory."