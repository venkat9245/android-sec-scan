#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "    ██████╗██╗██████╗ ███████╗███████╗██████╗ "
    echo "    ██╔══██╗██║██╔══██╗██╔════╝██╔════╝██╔══██╗"
    echo "    ██║  ██║██║██████╔╝█████╗  █████╗  ██████╔╝"
    echo "    ██║  ██║██║██╔══██╗██╔══╝  ██╔══╝  ██╔══██╗"
    echo "    ██████╔╝██║██║  ██║███████╗███████╗██║  ██║"
    echo "    ╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝"
    echo ""
    echo "        ╔══════════════════════════════════════════════════════════════╗"
    echo "        ║           🔥 ANDROID SECURITY SCANNER v2.1 🔥                ║"
    echo "        ║                    by SUBHASH - Kali Linux                   ║"
    echo "        ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

generate_images() {
    local report_dir="$1"
    echo -e "${YELLOW}🎨 Generating HD security report...${NC}"
    python3 ~/android-security-scanner/visual_report.py "$report_dir" 2>/dev/null || true
    echo -e "${GREEN}✅ Report saved: $report_dir/report.png${NC}"
}

check_url() {
    echo -e "${YELLOW}🌐 URL Reputation Scanner${NC}"
    read -p "Enter URL: " target_url
    
    mkdir -p scan_reports/url_scan
    report_dir="scan_reports/url_scan/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$report_dir"
    
    danger_keywords=("malware" "trojan" "exploit" "phishing" "virus" "ransomware" "backdoor")
    clean_keywords=("google" "microsoft" "amazon" "github" "stackoverflow")
    
    verdict="CLEAN"
    risk_score=0
    
    url_lower=$(echo "$target_url" | tr '[:upper:]' '[:lower:]')
    
    for keyword in "${danger_keywords[@]}"; do
        if [[ "$url_lower" == *"$keyword"* ]]; then
            ((risk_score+=3))
            verdict="DANGER"
        fi
    done
    
    for keyword in "${clean_keywords[@]}"; do
        if [[ "$url_lower" == *"$keyword"* ]]; then
            risk_score=0
            verdict="CLEAN"
        fi
    done
    
    echo ""
    echo -e "${CYAN}📊 URL ANALYSIS:${NC}"
    echo "   🌐 Target: $target_url"
    echo "   📈 Risk Score: $risk_score"
    echo ""
    
    if [[ "$verdict" == "DANGER" ]]; then
        echo -e "${RED}🚨 DANGER! MALICIOUS URL 🚨${NC}"
        echo "<h1>🚨 DANGER URL</h1><h2>$target_url</h2><p>Risk: $risk_score/10</p>" > "$report_dir/report.html"
    else
        echo -e "${GREEN}✅ CLEAN & SAFE ✅${NC}"
        echo "<h1>✅ SAFE URL</h1><h2>$target_url</h2><p>Clean: Risk $risk_score</p>" > "$report_dir/report.html"
    fi
    
    generate_images "$report_dir"
    echo -e "${PURPLE}📁 Report: $report_dir/${NC}\n"
}

scan_apk() {
    echo -e "${YELLOW}🔍 APK Security Scanner${NC}"
    echo -e "${CYAN}📱 Available APKs:${NC}"
    find . -name "*.apk" -type f 2>/dev/null | head -5 || echo "   No APKs in current directory"
    echo ""
    
    read -p "Enter APK path: " apk_file
    
    if [[ ! -f "$apk_file" ]]; then
        echo -e "${RED}❌ APK not found: $apk_file${NC}"
        sleep 2
        return
    fi

    echo -e "${CYAN}🔍 Analyzing: $(basename "$apk_file")${NC}"
    
    report_dir="scan_reports/apk_scan/$(date +%Y%m%d_%H%M%S)_$(basename "$apk_file" .apk)"
    mkdir -p "$report_dir"
    
    echo -e "${YELLOW}📋 Extracting APK contents...${NC}"
    timeout 30 apktool d "$apk_file" -o "$report_dir/extracted" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  APKTOOL failed, using basic analysis${NC}"
        mkdir -p "$report_dir/extracted"
    }
    
    dangerous_perms=0
    risky_perms=("SEND_SMS" "READ_SMS" "RECEIVE_SMS" "CALL_PHONE" "READ_CALL_LOG" 
                 "WRITE_EXTERNAL_STORAGE" "READ_EXTERNAL_STORAGE" "ACCESS_FINE_LOCATION" 
                 "CAMERA" "RECORD_AUDIO" "SYSTEM_ALERT_WINDOW" "BIND_ACCESSIBILITY_SERVICE")
    
    if [[ -f "$report_dir/extracted/AndroidManifest.xml" ]]; then
        for perm in "${risky_perms[@]}"; do
            if grep -qi "android.permission.$perm" "$report_dir/extracted/AndroidManifest.xml" 2>/dev/null; then
                ((dangerous_perms++))
                echo -e "${RED}⚠️  DANGEROUS: $perm${NC}"
            fi
        done
    fi
    
    suspicious_files=0
    suspicious_patterns=("root" "su" "sms" "exploit" "payload" "malware" "trojan" "keylogger")
    
    if [[ -d "$report_dir/extracted" ]]; then
        if find "$report_dir/extracted" -name "*sms*" -o -name "*root*" -o -name "*su*" -o -name "*dex*" 2>/dev/null | grep -q .; then
            ((suspicious_files++))
            echo -e "${RED}🚨 Suspicious files detected${NC}"
        fi
        
        if find "$report_dir/extracted" -name "*.smali" 2>/dev/null | xargs grep -il "${suspicious_patterns[*]}" 2>/dev/null | grep -q .; then
            ((suspicious_files++))
            echo -e "${RED}🚨 Malicious patterns in code${NC}"
        fi
    fi
    
    total_risks=$((dangerous_perms * 2 + suspicious_files * 3))
    
    echo ""
    echo -e "${WHITE}══════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}📊 SECURITY ANALYSIS RESULTS:${NC}"
    echo "   📱 APK: $(basename "$apk_file")"
    echo "   ⚠️  Dangerous Permissions: $dangerous_perms"
    echo "   🚨 Suspicious Indicators: $suspicious_files"
    echo "   📈 TOTAL RISK SCORE: $total_risks"
    echo -e "${WHITE}══════════════════════════════════════════════════${NC}"
    echo ""
    
    cat > "$report_dir/report.html" << HTML_EOF
<!DOCTYPE html>
<html>
<head><title>APK Analysis - $(basename "$apk_file")</title>
<style>body{font-family:Arial;background:#1a1a1a;color:#00ff00;padding:20px}</style>
</head>
<body>
<h1>🔍 APK SECURITY SCAN</h1>
<h2>$(basename "$apk_file")</h2>
<p><strong>Risks:</strong> $total_risks | Permissions: $dangerous_perms | Suspicious: $suspicious_files</p>
</body>
</html>
HTML_EOF

    if [[ $total_risks -ge 8 ]]; then
        echo -e "${RED}🚨🚨🚨 CRITICAL DANGER! MALWARE CONFIRMED 🚨🚨🚨${NC}"
        echo -e "${RED}   ⚠️  DO NOT INSTALL - HIGH RISK${NC}"
    elif [[ $total_risks -ge 4 ]]; then
        echo -e "${YELLOW}⚠️⚠️  WARNING - RISKY APK ⚠️⚠️${NC}"
        echo -e "${YELLOW}   ⚠️  MEDIUM-HIGH RISK${NC}"
    elif [[ $total_risks -ge 1 ]]; then
        echo -e "${YELLOW}⚠️  CAUTION - Minor Risks ⚠️${NC}"
        echo -e "${YELLOW}   ⚠️  LOW RISK${NC}"
    else
        echo -e "${GREEN}✅✅✅ CLEAN & SECURE ✅✅✅${NC}"
        echo -e "${GREEN}   ☑️  NO SECURITY RISKS${NC}"
    fi
    
    generate_images "$report_dir"
    echo -e "${PURPLE}📁 Full report saved: $report_dir/${NC}\n"
}

generate_visual_report() {
    echo -e "${YELLOW}📊 Generating Visual Reports...${NC}"
    find scan_reports -name "report.html" -mtime -1 2>/dev/null | while read report; do
        dir=$(dirname "$report")
        generate_images "$dir"
    done
    echo -e "${GREEN}✅ All visual reports generated!${NC}\n"
}

main_menu() {
    while true; do
        show_banner
        echo -e "${WHITE}══════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}          🔥 MAIN MENU 🔥${NC}"
        echo -e "${WHITE}══════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}1.${NC} 🔍 ${CYAN}APK Security Scan${NC}"
        echo -e "${GREEN}2.${NC} 🌐 ${CYAN}URL Reputation Check${NC}"
        echo -e "${GREEN}3.${NC} 📊 ${CYAN}Generate Visual Reports${NC}"
        echo -e "${RED}0.${NC} ❌ ${RED}Exit${NC}"
        echo -e "${WHITE}══════════════════════════════════════════════════${NC}"
        echo ""
        
        read -p "Choose option [0-3]: " choice
        
        case $choice in
            1) scan_apk ;;
            2) check_url ;;
            3) generate_visual_report ;;
            0) echo -e "${PURPLE}👋 Thanks for using SUBHASH's APK TOOL!${NC}"; exit 0 ;;
            *) echo -e "${RED}❌ Invalid option!${NC}"; sleep 1 ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

mkdir -p scan_reports/{apk_scan,url_scan}
chmod +x "$0"
main_menu
