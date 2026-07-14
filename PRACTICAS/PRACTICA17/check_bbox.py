import numpy as np
from PIL import Image
import glob

min_x, max_x = 1000, -1
min_y, max_y = 1000, -1

for f in sorted(glob.glob("sprites_terry/sprite_*.png")):
    img = Image.open(f).convert("RGBA")
    arr = np.array(img)
    alpha = arr[:,:,3]
    y_idx, x_idx = np.where(alpha > 0)
    if len(x_idx) > 0:
        min_x = min(min_x, x_idx.min())
        max_x = max(max_x, x_idx.max())
        min_y = min(min_y, y_idx.min())
        max_y = max(max_y, y_idx.max())

print(f"BBox: X [{min_x} - {max_x}], Y [{min_y} - {max_y}]")
print(f"Width: {max_x - min_x + 1}, Height: {max_y - min_y + 1}")
