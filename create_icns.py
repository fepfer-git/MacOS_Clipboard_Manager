#!/usr/bin/env python3
"""
Create .icns file from SVG for ClipboardManager app bundle
"""

import os
import subprocess
import tempfile

def create_icns_from_svg(svg_path, output_path):
    """Convert SVG to ICNS format using native macOS tools"""
    
    with tempfile.TemporaryDirectory() as temp_dir:
        iconset_dir = os.path.join(temp_dir, "AppIcon.iconset")
        os.makedirs(iconset_dir)
        
        # Define required icon sizes for macOS
        sizes = [
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
        
        print("🔄 Converting SVG to PNG files...")
        
        # Convert SVG to PNG for each size using sips (built into macOS)
        for size, filename in sizes:
            png_path = os.path.join(iconset_dir, filename)
            try:
                # Create a temporary large PNG first
                temp_png = os.path.join(temp_dir, f"temp_{size}.png")
                
                # Use qlmanage to convert SVG to PNG
                subprocess.run([
                    "qlmanage", "-t", "-s", str(size), "-o", temp_dir, svg_path
                ], check=True, capture_output=True)
                
                # qlmanage creates a file with .svg.png extension
                generated_file = os.path.join(temp_dir, os.path.basename(svg_path) + ".png")
                if os.path.exists(generated_file):
                    # Resize using sips if needed and rename
                    subprocess.run([
                        "sips", "-z", str(size), str(size), generated_file, "--out", png_path
                    ], check=True, capture_output=True)
                    print(f"✅ Created {filename} ({size}x{size})")
                else:
                    print(f"⚠️  Failed to create {filename}")
                    
            except Exception as e:
                print(f"⚠️  Error creating {filename}: {e}")
        
        # Convert iconset to icns using iconutil
        print("🎨 Creating ICNS file...")
        try:
            subprocess.run([
                "iconutil", "-c", "icns", iconset_dir, "-o", output_path
            ], check=True)
            print(f"✅ ICNS file created: {output_path}")
            return True
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to create ICNS file: {e}")
            return False

def main():
    print("🎨 Creating ICNS file for ClipboardManager...")
    
    svg_path = "Resources/AppIcon.svg"
    icns_path = "Resources/AppIcon.icns"
    
    if not os.path.exists(svg_path):
        print(f"❌ SVG file not found: {svg_path}")
        return False
    
    success = create_icns_from_svg(svg_path, icns_path)
    
    if success:
        print("\n🎉 ICNS creation complete!")
        print(f"📁 Icon file: {icns_path}")
        print("\n📋 Next steps:")
        print("1. Copy the ICNS file to the app bundle")
        print("2. Rebuild and reinstall the app")
    else:
        print("\n❌ ICNS creation failed")
        print("The SVG file is still available for manual conversion")
    
    return success

if __name__ == "__main__":
    main()
