import numpy as np
from PIL import Image
import sys

def generate_bin(image_path="dr-stone-prueba.jpg", width=480, height=270, out_name="image.bin"):
    try:
        img = Image.open(image_path).convert('RGB')
    except Exception as e:
        print(f"Error loading image '{image_path}':", e)
        return
        
    img = img.resize((width, height))
    pixels = np.array(img)
    
    with open(out_name, 'wb') as f:
        for row in pixels:
            for r, g, b in row:
                # RGB565 format
                r5 = (r >> 3) & 0x1F
                g6 = (g >> 2) & 0x3F
                b5 = (b >> 3) & 0x1F
                rgb565 = (r5 << 11) | (g6 << 5) | b5
                
                # Write as 2 bytes (little endian or big endian? typically little endian for SD card reads, but we write it big endian for simplicity if we read byte by byte. Let's do little endian: lower byte first, then upper byte)
                f.write(bytes([rgb565 & 0xFF, (rgb565 >> 8) & 0xFF]))
                
    print(f"Successfully generated {out_name} ({width}x{height} RGB565)")

if __name__ == '__main__':
    img_path = sys.argv[1] if len(sys.argv) > 1 else "dr-stone-prueba.jpg"
    generate_bin(img_path)
