#!/usr/bin/env python3
import xml.etree.ElementTree as ET
import sys
import os
from pathlib import Path

RISKY_PERMS = {
    'android.permission.SEND_SMS': '🔴 HIGH - SMS Fraud Risk',
    'android.permission.READ_SMS': '🔴 HIGH - SMS Spyware',
    'android.permission.RECEIVE_SMS': '🔴 HIGH - SMS Interception',
    'android.permission.CALL_PHONE': '🟡 MEDIUM - Call Abuse',
    'android.permission.READ_CALL_LOG': '🔴 HIGH - Call Log Spyware',
    'android.permission.WRITE_CALL_LOG': '🔴 HIGH - Call Log Manipulation',
    'android.permission.ACCESS_FINE_LOCATION': '🔴 HIGH - Precise Tracking',
    'android.permission.RECORD_AUDIO': '🔴 HIGH - Microphone Spyware',
    'android.permission.CAMERA': '🔴 HIGH - Camera Spyware',
    'android.permission.GET_ACCOUNTS': '🔴 HIGH - Account Harvesting',
    'android.permission.READ_CONTACTS': '🔴 HIGH - Contact Theft',
    'android.permission.SYSTEM_ALERT_WINDOW': '🔴 HIGH - Overlay Attack'
}

def analyze_permissions(manifest_path, output_path):
    """Analyze AndroidManifest.xml for risky permissions"""
    with open(output_path, 'w') as f:
        f.write("🔒 PERMISSION ANALYSIS REPORT\n")
        f.write("=" * 60 + "\n\n")
        
        high_risk = 0
        total_perms = 0
        
        try:
            tree = ET.parse(manifest_path)
            root = tree.getroot()
            
            for uses_perm in root.findall('.//{http://schemas.android.com/apk/res/android}uses-permission'):
                perm_name = uses_perm.get('{http://schemas.android.com/apk/res/android}name')
                if perm_name:
                    total_perms += 1
                    if perm_name in RISKY_PERMS:
                        f.write(f"{RISKY_PERMS[perm_name]}: {perm_name}\n")
                        high_risk += 1
                    else:
                        f.write(f"ℹ️  LOW: {perm_name}\n")
            
            f.write("\n" + "=" * 60 + "\n")
            f.write(f"📊 SUMMARY\n")
            f.write(f"Total Permissions: {total_perms}\n")
            f.write(f"High Risk Permissions: {high_risk}\n")
            risk_score = (high_risk / max(total_perms, 1)) * 100
            f.write(f"🚨 RISK SCORE: {risk_score:.1f}%\n")
            
        except Exception as e:
            f.write(f"❌ Error parsing manifest: {str(e)}\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 perm_analyzer.py <manifest.xml> <output.txt>")
        sys.exit(1)
    
    manifest = sys.argv[1]
    output = sys.argv[2]
    
    if os.path.exists(manifest):
        analyze_permissions(manifest, output)
        print(f"✅ Permissions analyzed: {output}")
    else:
        print(f"❌ Manifest not found: {manifest}")
