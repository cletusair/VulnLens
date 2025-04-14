# VulnLens

**VulnLens** is a lightweight, terminal-based vulnerability assessment tool written in Bash. It automates initial recon and vulnerability discovery against a given IP or domain, then generates a clean Markdown and optional HTML report with findings.

---

## 📦 Features

- 🔎 Scans open ports and services with **Nmap**
- 🧠 Extracts service versions and checks for public exploits via **Searchsploit**
- 🌐 Detects web technologies with **WhatWeb**
- 🛡️ Scans for basic web vulnerabilities using **Nikto**
- 📝 Outputs a structured **Markdown report**, and optionally **HTML** (via Pandoc)

---

## 🚀 Usage

```bash
chmod +x vulnscan.sh
./vulnscan.sh

chmod +x va-lite.sh
./va-lite.sh
