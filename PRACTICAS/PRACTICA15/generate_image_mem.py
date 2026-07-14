import numpy as np
from PIL import Image
import sys

def generate_mem(image_path="drstone.png"):
    # Load image
    try:
        img = Image.open(image_path).convert('L')
    except Exception as e:
        print(f"Error loading image '{image_path}':", e)
        return
        
    img = img.resize((480, 270))
    pixels = np.array(img)
    bw_pixels = (pixels > 128).astype(int)
    
    # Pack 8 pixels into 1 byte
    # bw_pixels is a 1D array of 129600 elements
    # Reshape to (16200, 8)
    packed = bw_pixels.reshape(-1, 8)
    
    # Convert each row of 8 bits to a single byte (integer 0-255)
    # Most significant bit is the first pixel (leftmost)
    bytes_arr = np.packbits(packed, axis=-1).flatten()
    
    # Write to .mem file
    with open('image.mem', 'w') as f:
        for val in bytes_arr:
            # Write as 2-character hex string (8 bits)
            f.write(f'{val:02X}\n')
            
    print("Successfully generated image.mem (16200 bytes, 8-bit packed B&W, 480x270)")

if __name__ == '__main__':
    img_path = sys.argv[1] if len(sys.argv) > 1 else "drstone.png"
    generate_mem(img_path)
