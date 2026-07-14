import numpy as np
from PIL import Image
import glob
import os

def generate_mem():
    sprite_files = sorted(glob.glob("sprites_terry/sprite_*.png"))
    if not sprite_files:
        print("No sprites found!")
        return

    frames = []
    
    for f in sprite_files:
        # Load image, convert to grayscale
        try:
            img = Image.open(f).convert('L')
            # Ensure it is 128x112
            if img.size != (128, 112):
                img = img.resize((128, 112))
                
            pixels = np.array(img)
            # Threshold to 1-bit (adjust 128 if needed based on transparency/colors)
            # You might need to adjust threshold logic if background is transparent or white
            # Terry sprites often have a background color or are transparent.
            # Assuming Terry is mostly dark/colored and background is transparent/white
            
            # If the sprite has an alpha channel in the original, we should probably handle it?
            # Let's open with RGBA to handle transparency:
            orig = Image.open(f).convert("RGBA")
            if orig.size != (128, 112):
                orig = orig.resize((128, 112))
            
            # Create a white background
            bg = Image.new("RGBA", orig.size, (255, 255, 255, 255))
            alpha_composite = Image.alpha_composite(bg, orig).convert("L")
            
            pixels = np.array(alpha_composite)
            # White = 1, Black = 0 or vice versa? Let's make sprite 1 and background 0 for rendering
            # If pixel is bright (background), map to 0. If dark (Terry), map to 1.
            bw_pixels = (pixels < 200).astype(int) 
            
            frames.append(bw_pixels)
        except Exception as e:
            print(f"Error processing {f}:", e)
            
    if not frames:
        return
        
    all_frames = np.array(frames) # Shape: (11, 112, 128)
    
    # Pack into bytes
    # Reshape each row of 128 into 16 bytes (8 pixels per byte)
    packed = all_frames.reshape(-1, 8)
    bytes_arr = np.packbits(packed, axis=-1).flatten()
    
    # Write to memory file
    with open('sprites.mem', 'w') as out:
        for val in bytes_arr:
            out.write(f'{val:02X}\n')
            
    print(f"Successfully generated sprites.mem with {len(frames)} frames. Size: {len(bytes_arr)} bytes.")

if __name__ == '__main__':
    generate_mem()
