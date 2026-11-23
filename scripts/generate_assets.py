import os
import json
import math
from PIL import Image, ImageDraw

def create_app_icon():
    size = 1024
    img = Image.new("RGBA", (size, size), (13, 17, 23, 255))
    draw = ImageDraw.Draw(img)

    # Background subtle radial gradient
    center_x, center_y = size // 2, size // 2
    max_radius = size * 0.7

    for r in range(int(max_radius), 0, -8):
        factor = r / max_radius
        # Interpolate between darker edge and subtle midnight navy center
        red = int(11 + (22 - 11) * (1 - factor))
        green = int(14 + (32 - 14) * (1 - factor))
        blue = int(22 + (45 - 22) * (1 - factor))
        draw.ellipse([center_x - r, center_y - r, center_x + r, center_y + r], fill=(red, green, blue, 255))

    # Outer precision ring (Neon Cyan with transparency)
    ring_radius_outer = 320
    ring_radius_mid = 240
    ring_radius_inner = 160

    # Draw subtle radar/pulse rings
    draw.ellipse(
        [center_x - ring_radius_outer, center_y - ring_radius_outer, center_x + ring_radius_outer, center_y + ring_radius_outer],
        outline=(0, 242, 254, 70),
        width=4
    )
    draw.ellipse(
        [center_x - ring_radius_mid, center_y - ring_radius_mid, center_x + ring_radius_mid, center_y + ring_radius_mid],
        outline=(0, 242, 254, 120),
        width=5
    )
    draw.ellipse(
        [center_x - ring_radius_inner, center_y - ring_radius_inner, center_x + ring_radius_inner, center_y + ring_radius_inner],
        outline=(0, 230, 118, 180),
        width=6
    )

    # Draw precision crosshair ticks
    tick_len = 40
    for angle in [0, 90, 180, 270]:
        rad = math.radians(angle)
        x1 = center_x + int((ring_radius_outer - tick_len // 2) * math.cos(rad))
        y1 = center_y + int((ring_radius_outer - tick_len // 2) * math.sin(rad))
        x2 = center_x + int((ring_radius_outer + tick_len // 2) * math.cos(rad))
        y2 = center_y + int((ring_radius_outer + tick_len // 2) * math.sin(rad))
        draw.line([(x1, y1), (x2, y2)], fill=(0, 242, 254, 200), width=4)

    # Stylized central touch pointer / lightning click beacon
    # Geometric cursor polygon
    cursor_points = [
        (center_x - 30, center_y - 80),
        (center_x + 90, center_y + 40),
        (center_x + 20, center_y + 35),
        (center_x - 10, center_y + 95),
        (center_x - 45, center_y + 80),
        (center_x - 15, center_y + 20),
        (center_x - 70, center_y + 15),
    ]
    
    # Outer glow of cursor
    for offset in range(12, 0, -3):
        alpha = int(35 * (1 - offset / 12))
        draw.polygon(cursor_points, outline=(0, 242, 254, alpha))

    # Core cursor solid fill with gradient-like look
    draw.polygon(cursor_points, fill=(0, 242, 254, 255), outline=(255, 255, 255, 240))

    # Center target pulse dot
    dot_radius = 22
    draw.ellipse(
        [center_x - 10 - dot_radius, center_y - 20 - dot_radius, center_x - 10 + dot_radius, center_y - 20 + dot_radius],
        fill=(0, 230, 118, 255),
        outline=(255, 255, 255, 255),
        width=3
    )

    # Target folder
    icon_dir = os.path.abspath("AutoClickToolkit/Resources/Assets.xcassets/AppIcon.appiconset")
    os.makedirs(icon_dir, exist_ok=True)
    
    # 1024x1024 base icon (iOS App Store & Single-size icon for iOS 16+)
    base_icon_path = os.path.join(icon_dir, "AppIcon-512@2x.png")
    img.save(base_icon_path, format="PNG")
    print(f"Generated 1024x1024 icon at: {base_icon_path}")

    # Standard iOS AppIcon variants
    sizes = [
        (20, 1), (20, 2), (20, 3),
        (29, 1), (29, 2), (29, 3),
        (38, 2), (38, 3),
        (40, 1), (40, 2), (40, 3),
        (60, 2), (60, 3),
        (64, 2), (64, 3),
        (68, 2),
        (76, 1), (76, 2),
        (83.5, 2),
        (1024, 1)
    ]

    images_metadata = []
    for s, scale in sizes:
        px = int(s * scale)
        filename = f"icon_{s}x{s}@{scale}x.png" if scale > 1 else f"icon_{s}x{s}.png"
        filepath = os.path.join(icon_dir, filename)
        resized = img.resize((px, px), Image.Resampling.LANCZOS)
        resized.save(filepath, format="PNG")
        
        images_metadata.append({
            "size": f"{s}x{s}" if isinstance(s, int) else f"{s}x{s}",
            "idiom": "universal",
            "scale": f"{scale}x",
            "filename": filename
        })

    contents_json = {
        "images": images_metadata,
        "info": {
            "version": 1,
            "author": "xcode"
        }
    }

    with open(os.path.join(icon_dir, "Contents.json"), "w", encoding="utf-8") as f:
        json.dump(contents_json, f, indent=2)

    # Also AccentColor.colorset
    accent_dir = os.path.abspath("AutoClickToolkit/Resources/Assets.xcassets/AccentColor.colorset")
    os.makedirs(accent_dir, exist_ok=True)
    accent_json = {
        "colors": [
            {
                "idiom": "universal",
                "color": {
                    "color-space": "srgb",
                    "components": {
                        "red": "0.000",
                        "green": "0.949",
                        "blue": "0.996",
                        "alpha": "1.000"
                    }
                }
            }
        ],
        "info": {
            "version": 1,
            "author": "xcode"
        }
    }
    with open(os.path.join(accent_dir, "Contents.json"), "w", encoding="utf-8") as f:
        json.dump(accent_json, f, indent=2)

    # Root xcassets Contents.json
    root_xcassets = os.path.abspath("AutoClickToolkit/Resources/Assets.xcassets/Contents.json")
    with open(root_xcassets, "w", encoding="utf-8") as f:
        json.dump({"info": {"version": 1, "author": "xcode"}}, f, indent=2)

    print("Assets catalog setup complete.")

if __name__ == "__main__":
    create_app_icon()
