#!/usr/bin/env python3
"""
Create a beautiful, colorful clipboard icon for ClipboardManager
This script generates both the app icon and menu bar icon assets.
"""

import os
import subprocess
import tempfile

def create_app_icon_svg():
    """Create a colorful SVG icon for the application bundle"""
    svg_content = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="clipboardGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4A90E2;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#357ABD;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="clipGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#F5A623;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#D68910;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="paperGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FFFFFF;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#F8F9FA;stop-opacity:1" />
    </linearGradient>
    <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
      <feDropShadow dx="0" dy="8" stdDeviation="12" flood-color="rgba(0,0,0,0.25)"/>
    </filter>
  </defs>
  
  <!-- Background circle with subtle gradient -->
  <circle cx="256" cy="256" r="240" fill="url(#clipboardGrad)" filter="url(#shadow)"/>
  
  <!-- Main clipboard body -->
  <rect x="140" y="120" width="232" height="320" rx="16" ry="16" 
        fill="url(#paperGrad)" stroke="#E1E8ED" stroke-width="3"/>
  
  <!-- Clipboard clip (metal part) -->
  <rect x="200" y="80" width="112" height="48" rx="8" ry="8" 
        fill="url(#clipGrad)" stroke="#B7850F" stroke-width="2"/>
  
  <!-- Clip inner detail -->
  <rect x="220" y="100" width="72" height="8" rx="4" ry="4" fill="#FFFFFF" opacity="0.7"/>
  
  <!-- Content lines on the paper -->
  <rect x="180" y="180" width="152" height="8" rx="4" fill="#4A90E2" opacity="0.8"/>
  <rect x="180" y="220" width="152" height="8" rx="4" fill="#4A90E2" opacity="0.6"/>
  <rect x="180" y="260" width="120" height="8" rx="4" fill="#4A90E2" opacity="0.4"/>
  
  <!-- Visual elements suggesting "stacked" clipboard items -->
  <rect x="120" y="140" width="12" height="280" rx="6" fill="#357ABD" opacity="0.3"/>
  <rect x="380" y="140" width="12" height="280" rx="6" fill="#357ABD" opacity="0.3"/>
  
  <!-- Highlight/shine effect -->
  <ellipse cx="200" cy="180" rx="40" ry="20" fill="url(#paperGrad)" opacity="0.5" 
           transform="rotate(-30 200 180)"/>
</svg>'''
    return svg_content

def create_menu_bar_icon_svg():
    """Create a colorful SVG icon for the menu bar (smaller, more vibrant)"""
    svg_content = '''<?xml version="1.0" encoding="UTF-8"?>
<svg width="18" height="18" viewBox="0 0 18 18" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="mbClipboardGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#5C9EFF;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#4A90E2;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="mbClipGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FFB347;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#F5A623;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- Main clipboard body -->
  <rect x="2" y="3" width="12" height="14" rx="1.5" ry="1.5" 
        fill="url(#mbClipboardGrad)" stroke="#357ABD" stroke-width="0.5"/>
  
  <!-- Clipboard clip -->
  <rect x="5.5" y="1" width="5" height="3" rx="0.5" ry="0.5" 
        fill="url(#mbClipGrad)" stroke="#D68910" stroke-width="0.3"/>
  
  <!-- Content lines -->
  <rect x="4" y="7" width="8" height="1" rx="0.5" fill="#FFFFFF" opacity="0.9"/>
  <rect x="4" y="9.5" width="8" height="1" rx="0.5" fill="#FFFFFF" opacity="0.7"/>
  <rect x="4" y="12" width="6" height="1" rx="0.5" fill="#FFFFFF" opacity="0.5"/>
  
  <!-- Stack indicators -->
  <rect x="0.5" y="5" width="1" height="10" rx="0.5" fill="#357ABD" opacity="0.4"/>
  <rect x="15.5" y="5" width="1" height="10" rx="0.5" fill="#357ABD" opacity="0.4"/>
</svg>'''
    return svg_content

def create_iconset():
    """Create an iconset for the macOS app bundle"""
    
    # Create the SVG files
    app_icon_svg = create_app_icon_svg()
    
    # Create temporary directory for icon generation
    with tempfile.TemporaryDirectory() as temp_dir:
        svg_path = os.path.join(temp_dir, "icon.svg")
        iconset_path = os.path.join(temp_dir, "ClipboardManager.iconset")
        
        # Write SVG file
        with open(svg_path, 'w') as f:
            f.write(app_icon_svg)
        
        # Create iconset directory
        os.makedirs(iconset_path, exist_ok=True)
        
        # Icon sizes for macOS app bundles
        icon_sizes = [
            (16, "icon_16x16.png"),
            (32, "icon_16x16@2x.png"),
            (32, "icon_32x32.png"),
            (64, "icon_32x32@2x.png"),
            (128, "icon_128x128.png"),
            (256, "icon_128x128@2x.png"),
            (256, "icon_256x256.png"),
            (512, "icon_256x256@2x.png"),
            (512, "icon_512x512.png"),
            (1024, "icon_512x512@2x.png")
        ]
        
        # Convert SVG to PNG files using librsvg (if available) or ImageMagick
        for size, filename in icon_sizes:
            output_path = os.path.join(iconset_path, filename)
            
            # Try librsvg first (more accurate)
            try:
                subprocess.run([
                    "rsvg-convert", 
                    "-w", str(size), 
                    "-h", str(size), 
                    svg_path, 
                    "-o", output_path
                ], check=True, capture_output=True)
            except (subprocess.CalledProcessError, FileNotFoundError):
                # Fallback to ImageMagick
                try:
                    subprocess.run([
                        "convert", 
                        "-background", "transparent",
                        "-size", f"{size}x{size}",
                        svg_path, 
                        output_path
                    ], check=True, capture_output=True)
                except (subprocess.CalledProcessError, FileNotFoundError):
                    print(f"Warning: Could not generate {filename}. Install librsvg or ImageMagick.")
                    continue
        
        # Create .icns file using iconutil
        icns_path = "ClipboardManager.icns"
        try:
            subprocess.run([
                "iconutil", 
                "-c", "icns", 
                iconset_path,
                "-o", icns_path
            ], check=True)
            print(f"✅ Created app icon: {icns_path}")
            return icns_path
        except subprocess.CalledProcessError:
            print("❌ Failed to create .icns file. iconutil not available.")
            return None

if __name__ == "__main__":
    print("🎨 Creating colorful ClipboardManager icons...")
    
    # Create app icon
    icns_path = create_iconset()
    
    # Create menu bar icon SVG
    menu_bar_svg = create_menu_bar_icon_svg()
    with open("menu_bar_icon.svg", 'w') as f:
        f.write(menu_bar_svg)
    
    print("✅ Created menu_bar_icon.svg")
    
    print("\n🎨 Icon creation complete!")
    print("📁 Files created:")
    if icns_path:
        print(f"   • {icns_path} (for app bundle)")
    print("   • menu_bar_icon.svg (for menu bar)")
