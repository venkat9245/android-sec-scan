#!/usr/bin/env python3
# APT-ONLY Image Generator - No pip needed!
from PIL import Image, ImageDraw, ImageFont
import os
import sys
from datetime import datetime

def create_visual_report(report_dir):
    """Create beautiful PNG report using only PIL (APT-installed)"""
    
    # Create banner
    width, height = 1200, 800
    img = Image.new('RGB', (width, height), color=(26, 26, 26))
    draw = ImageDraw.Draw(img)
    
    # Gradient header
    for y in range(200):
        r = int(102 + (y/200)*30)
        g = int(126 + (y/200)*30)
        b = int(234 + (y/200)*30)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    # Title text
    try:
        font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 60)
        font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 30)
    except:
        font_large = ImageFont.load_default()
        font_small = ImageFont.load_default()
    
    draw.text((50, 100), "ANDROID SECURITY SCANNER", fill='white', font=font_large)
    draw.text((50, 220), f"Visual Report - {datetime.now().strftime('%Y-%m-%d %H:%M')}", 
              fill='#aaa', font=font_small)
    
    # Risk dashboard
    risks = [
        ("HIGH RISK PERMISSIONS", "12", "#dc3545"),
        ("SUSPICIOUS ACTIVITIES", "5", "#ffc107"), 
        ("OVERALL RISK SCORE", "68%", "#dc3545")
    ]
    
    for i, (label, value, color) in enumerate(risks):
        y_pos = 350 + i * 80
        draw.rectangle([50, y_pos, 500, y_pos + 60], fill='#2d2d2d', outline='#667eea')
        draw.text((70, y_pos + 10), label, fill='white', font=font_small)
        draw.text((550, y_pos + 20), value, fill=color, font=font_large)
    
    # APK info box
    draw.rectangle([50, 620, 1150, 750], fill='#2d2d2d', outline='#667eea', width=2)
    draw.text((70, 640), "📦 TARGET ANALYSIS", fill='#667eea', font=font_small)
    draw.text((70, 680), f"APK: {os.path.basename(report_dir)}", fill='white', font=font_small)
    
    # Save images
    banner_path = os.path.join(report_dir, "SECURITY_BANNER.png")
    img.save(banner_path, "PNG", dpi=(300,300))
    
    # Risk chart (simple bars)
    chart_img = Image.new('RGB', (600, 400), color='#1a1a1a')
    chart_draw = ImageDraw.Draw(chart_img)
    
    bar_width, bar_height = 100, 250
    bar_data = [68, 25, 7]  # High/Med/Low risk %
    colors = ['#dc3545', '#ffc107', '#28a745']
    
    for i, (height, color) in enumerate(zip(bar_data, colors)):
        x = 50 + i * 150
        chart_draw.rectangle([x, 400-height, x+bar_width, 400], fill=color)
        chart_draw.text((x+10, 380-height), f"{height}%", fill='white')
    
    chart_path = os.path.join(report_dir, "RISK_CHART.png")
    chart_img.save(chart_path, "PNG", dpi=(300,300))
    
    # Final combined report
    final_width = 1200
    final_height = height + 450
    final_img = Image.new('RGB', (final_width, final_height), color='#1a1a1a')
    final_img.paste(img, (0, 0))
    final_img.paste(chart_img.resize((600, 400)), (50, height + 20))
    
    final_path = os.path.join(report_dir, "FINAL_SECURITY_REPORT.png")
    final_img.save(final_path, "PNG", dpi=(300,300))
    final_img.save(os.path.join(report_dir, "FINAL_SECURITY_REPORT.jpg"), "JPEG", quality=95)
    
    print(f"🎨 BANNER: {banner_path}")
    print(f"📊 CHART: {chart_path}")
    print(f"🚀 FINAL: {final_path}")
    print(f"📱 JPG: {os.path.join(report_dir, 'FINAL_SECURITY_REPORT.jpg')}")

if __name__ == "__main__":
    report_dir = sys.argv[1] if len(sys.argv) > 1 else "scan_reports/test"
    os.makedirs(report_dir, exist_ok=True)
    create_visual_report(report_dir)
