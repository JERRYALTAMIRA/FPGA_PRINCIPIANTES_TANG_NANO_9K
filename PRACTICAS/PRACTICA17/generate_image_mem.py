import numpy as np
from PIL import Image
import sys

def generate_mem(image_path="dr-stone-prueba.jpg"):
    try:
        img = Image.open(image_path).convert('RGB')
    except Exception as e:
        print(f"Error loading image '{image_path}':", e)
        return
        
    img = img.resize((160, 90))
    pixels = np.array(img)
    
    with open('image.mem', 'w') as f:
        for row in pixels:
            for r, g, b in row:
                # RGB565 format
                r5 = (r >> 3) & 0x1F
                g6 = (g >> 2) & 0x3F
                b5 = (b >> 3) & 0x1F
                rgb565 = (r5 << 11) | (g6 << 5) | b5
                f.write(f'{rgb565:04X}\n')
                
    print("Successfully generated image.mem (160x90 RGB565)")

if __name__ == '__main__':
    img_path = sys.argv[1] if len(sys.argv) > 1 else "dr-stone-prueba.jpg"
    generate_mem(img_path)
