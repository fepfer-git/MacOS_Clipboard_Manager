#!/usr/bin/env python3
"""
Simple icon creator for ClipboardManager using native macOS tools
"""

import os
import subprocess
import tempfile

def create_app_icon_svg():
    """Create a beautiful, vibrant clipboard icon with modern gradients"""
    return '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <!-- Main clipboard gradient - vibrant blue to purple -->
    <linearGradient id="clipboardGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#3B82F6;stop-opacity:1" />
      <stop offset="30%" style="stop-color:#6366F1;stop-opacity:1" />
      <stop offset="70%" style="stop-color:#8B5CF6;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#A855F7;stop-opacity:1" />
    </linearGradient>
    
    <!-- Clip gradient - warm orange to red -->
    <linearGradient id="clipGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#F59E0B;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#F97316;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#EF4444;stop-opacity:1" />
    </linearGradient>
    
    <!-- Paper gradient - pure white to light gray -->
    <linearGradient id="paperGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FFFFFF;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#F8FAFC;stop-opacity:1" />
    </linearGradient>
    
    <!-- Background glow -->
    <radialGradient id="glowGradient" cx="50%" cy="50%" r="50%">
      <stop offset="0%" style="stop-color:#3B82F6;stop-opacity:0.1" />
      <stop offset="100%" style="stop-color:#8B5CF6;stop-opacity:0.05" />
    </radialGradient>
    
    <!-- Drop shadow filter -->
    <filter id="dropShadow" x="-50%" y="-50%" width="200%" height="200%">
      <feDropShadow dx="0" dy="16" stdDeviation="24" flood-color="rgba(0,0,0,0.2)"/>
    </filter>
    
    <!-- Inner shadow for depth -->
    <filter id="innerShadow" x="-50%" y="-50%" width="200%" height="200%">
      <feOffset dx="0" dy="4"/>
      <feGaussianBlur stdDeviation="8" result="offset-blur"/>
      <feFlood flood-color="rgba(0,0,0,0.1)"/>
      <feComposite in2="offset-blur" operator="in"/>
    </filter>
  </defs>
  
  <!-- Background glow circle -->
  <circle cx="512" cy="512" r="480" fill="url(#glowGradient)"/>
  
  <!-- Main clipboard body with vibrant gradient -->
  <rect x="240" y="200" width="544" height="720" rx="48" ry="48" 
        fill="url(#clipboardGradient)" 
        filter="url(#dropShadow)"/>
  
  <!-- Inner paper area -->
  <rect x="280" y="280" width="464" height="600" rx="24" ry="24" 
        fill="url(#paperGradient)" 
        filter="url(#innerShadow)"/>
  
  <!-- Clipboard clip (metal part) -->
  <rect x="400" y="120" width="224" height="120" rx="32" ry="32" 
        fill="url(#clipGradient)" 
        filter="url(#dropShadow)"/>
  
  <!-- Clip inner highlight -->
  <rect x="420" y="140" width="184" height="80" rx="16" ry="16" 
        fill="rgba(255,255,255,0.3)"/>
  
  <!-- Content lines on paper with varying opacity -->
  <g opacity="0.7">
    <!-- Title line -->
    <rect x="320" y="340" width="280" height="8" rx="4" fill="#1F2937"/>
    
    <!-- Content lines -->
    <rect x="320" y="380" width="360" height="6" rx="3" fill="#374151"/>
    <rect x="320" y="420" width="320" height="6" rx="3" fill="#374151"/>
    <rect x="320" y="460" width="240" height="6" rx="3" fill="#6B7280"/>
    
    <!-- Second paragraph -->
    <rect x="320" y="520" width="200" height="6" rx="3" fill="#9CA3AF"/>
    <rect x="320" y="560" width="300" height="6" rx="3" fill="#9CA3AF"/>
    <rect x="320" y="600" width="260" height="6" rx="3" fill="#9CA3AF"/>
    
    <!-- Third section -->
    <rect x="320" y="660" width="180" height="6" rx="3" fill="#D1D5DB"/>
    <rect x="320" y="700" width="220" height="6" rx="3" fill="#D1D5DB"/>
  </g>
  
  <!-- Modern feature dots at bottom -->
  <circle cx="360" cy="800" r="16" fill="#10B981" opacity="0.9"/>
  <circle cx="420" cy="800" r="16" fill="#3B82F6" opacity="0.9"/>
  <circle cx="480" cy="800" r="16" fill="#8B5CF6" opacity="0.9"/>
  <circle cx="540" cy="800" r="16" fill="#F59E0B" opacity="0.9"/>
  <circle cx="600" cy="800" r="16" fill="#EF4444" opacity="0.9"/>
  
  <!-- Edge highlight for 3D effect -->
  <rect x="240" y="200" width="16" height="720" rx="8" 
        fill="rgba(255,255,255,0.15)"/>
  
  <!-- Corner shine effect -->
  <ellipse cx="400" cy="360" rx="80" ry="40" fill="rgba(255,255,255,0.1)" 
           transform="rotate(-30 400 360)"/>
</svg>'''

def create_menu_bar_icon_svg():
    """Create a vibrant, colorful menu bar icon"""
    return '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="18" height="18" viewBox="0 0 18 18" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="menuGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#3B82F6;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#8B5CF6;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#EC4899;stop-opacity:1" />
    </linearGradient>
    
    <linearGradient id="clipGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#F59E0B;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#EF4444;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- Clipboard body with vibrant gradient -->
  <rect x="2" y="2" width="12" height="14" rx="2" ry="2" 
        fill="url(#menuGradient)" 
        stroke="rgba(255,255,255,0.3)" stroke-width="0.5"/>
  
  <!-- Colorful clip -->
  <rect x="5" y="0" width="6" height="3" rx="1" ry="1" 
        fill="url(#clipGradient)"/>
  
  <!-- Content lines with varying opacity -->
  <rect x="4" y="5" width="6" height="1" rx="0.5" fill="rgba(255,255,255,0.9)"/>
  <rect x="4" y="7" width="8" height="1" rx="0.5" fill="rgba(255,255,255,0.7)"/>
  <rect x="4" y="9" width="7" height="1" rx="0.5" fill="rgba(255,255,255,0.5)"/>
  
  <!-- Small feature dots -->
  <circle cx="4.5" cy="13" r="0.8" fill="#10B981" opacity="0.8"/>
  <circle cx="7" cy="13" r="0.8" fill="#F59E0B" opacity="0.8"/>
  <circle cx="9.5" cy="13" r="0.8" fill="#EF4444" opacity="0.8"/>
</svg>'''

def main():
    print("🎨 Creating beautiful colorful icons for ClipboardManager...")
    
    # Create Resources directory if it doesn't exist
    os.makedirs("Resources", exist_ok=True)
    
    # Create app icon SVG
    print("📱 Creating app bundle icon...")
    app_svg = create_app_icon_svg()
    
    # Save SVG file
    svg_path = "Resources/AppIcon.svg"
    with open(svg_path, 'w') as f:
        f.write(app_svg)
    print(f"✅ App icon SVG created: {svg_path}")
    
    # Create menu bar icon
    print("📋 Creating menu bar icon...")
    menu_svg = create_menu_bar_icon_svg()
    menu_svg_path = "Resources/MenuBarIcon.svg"
    
    with open(menu_svg_path, 'w') as f:
        f.write(menu_svg)
    print(f"✅ Menu bar icon created: {menu_svg_path}")
    
    # Try to create PNG using native tools
    print("🖼️  Converting to PNG using native macOS tools...")
    
    try:
        # Use qlmanage to convert SVG to PNG (built into macOS)
        subprocess.run([
            "qlmanage", "-t", "-s", "512", "-o", "Resources/",
            svg_path
        ], check=True, capture_output=True)
        
        # Rename the generated file
        generated_file = "Resources/AppIcon.svg.png"
        if os.path.exists(generated_file):
            os.rename(generated_file, "Resources/AppIcon.png")
            print("✅ PNG icon created using qlmanage")
    except Exception as e:
        print(f"⚠️  Could not create PNG: {e}")
    
    print("\n🎉 Icon creation complete!")
    print("\n📋 Files created:")
    print("   • Resources/AppIcon.svg (colorful app icon)")
    print("   • Resources/MenuBarIcon.svg (colorful menu bar icon)")
    
    print("\n📋 Next steps:")
    print("1. Update Info.plist to reference the new icon")
    print("2. Copy icons to app bundle Resources folder")
    print("3. Update main.swift to use the colorful menu bar icon")

if __name__ == "__main__":
    main()
