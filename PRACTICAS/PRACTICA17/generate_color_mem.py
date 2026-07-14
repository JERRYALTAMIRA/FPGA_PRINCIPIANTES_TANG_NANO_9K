import numpy as np
from PIL import Image
import glob
import sys

def generate_palette_mem():
    sprite_files = sorted(glob.glob("sprites_terry/sprite_*.png"))[:8]  # Solo 8 frames para caber en BRAM
    
    # 1. Recolectar todos los pixeles de todos los frames (recortados a 120x112)
    all_img_data = []
    
    # Fondo transparente lo forzaremos a un color especifico para que sea nuestro "color 0" (ej: Magenta o Verde Chillon)
    # Terry suele tener negro, blanco, piel, rojo, azul pantalon, amarillo pelo, gris sombra.
    # Total 7 colores + 1 fondo transparente = 8 colores!
    
    frames_rgba = []
    for f in sprite_files:
        img = Image.open(f).convert("RGBA")
        img = img.crop((0, 0, 120, 104)) # Crop a 120x104
        frames_rgba.append(img)
        
    # Crear una imagen larga con todos los frames unidos para cuantizar con una sola paleta
    total_width = 120 * len(frames_rgba)
    atlas = Image.new("RGBA", (total_width, 104))
    for i, img in enumerate(frames_rgba):
        atlas.paste(img, (i * 120, 0))
        
    # Reemplazar transparencia con verde chillón (0, 255, 0)
    bg = Image.new("RGBA", atlas.size, (0, 255, 0, 255))
    atlas_bg = Image.alpha_composite(bg, atlas).convert("RGB")
    
    # Cuantizar a 8 colores
    quantized = atlas_bg.quantize(colors=8, method=Image.Quantize.MEDIANCUT)
    palette = quantized.getpalette()[:8*3] # Obtener los 8 colores RGB
    
    # Asegurarnos de que el color de fondo (verde) sea el índice 0 para hacerlo facil de ignorar
    # (Para ser más precisos, buscaremos el verde y lo mapearemos a 0)
    palette_colors = [tuple(palette[i:i+3]) for i in range(0, 24, 3)]
    
    # Buscar el verde (0, 255, 0)
    bg_idx = -1
    for i, c in enumerate(palette_colors):
        if c[0] < 50 and c[1] > 200 and c[2] < 50:
            bg_idx = i
            break
            
    if bg_idx == -1:
        # Fallback, buscar el más parecido al verde
        dist = [ (c[0]**2 + (c[1]-255)**2 + c[2]**2) for c in palette_colors ]
        bg_idx = np.argmin(dist)
        
    # Rearreglar paleta para que bg_idx sea 0
    if bg_idx != 0:
        palette_colors[0], palette_colors[bg_idx] = palette_colors[bg_idx], palette_colors[0]
        
    # Crear un diccionario para el remapeo de índices
    # quantized.getdata() devuelve los indices originales
    remap = {bg_idx: 0, 0: bg_idx}
    for i in range(1, 8):
        if i not in remap:
            remap[i] = i
            
    # Escribir la paleta en formato SystemVerilog
    with open("palette.svh", "w") as f:
        f.write("// Paleta generada automaticamente\n")
        f.write("    case (pixel_val)\n")
        for i, c in enumerate(palette_colors):
            # Convertir a RGB565 para salida (R:5, G:6, B:5)
            r5 = (c[0] >> 3) & 0x1F
            g6 = (c[1] >> 2) & 0x3F
            b5 = (c[2] >> 3) & 0x1F
            
            f.write(f"        3'd{i}: begin // RGB: {c}\n")
            if i == 0:
                f.write("            logo_viewport_mask = 0;\n")
                f.write("            red = 0; green = 0; blue = 0;\n")
            else:
                f.write("            logo_viewport_mask = 1;\n")
                f.write(f"            red = 5'd{r5}; green = 6'd{g6}; blue = 5'd{b5};\n")
            f.write("        end\n")
        f.write("    endcase\n")

    # Obtener la imagen cuantizada, remapear índices y empacar
    q_data = np.array(quantized)
    remapped_data = np.vectorize(lambda x: remap.get(x, x))(q_data)
    
    # Separar la imagen larga (atlas) en los frames individuales
    all_frames = []
    for i in range(len(frames_rgba)):
        frame_data = remapped_data[:, i*120 : (i+1)*120]
        all_frames.append(frame_data)
        
    # Aplanar y empacar 2 pixeles en 8 bits (bits [5:3] y [2:0])
    # 120 pixeles por fila / 2 = 60 bytes por fila
    # 60 * 111 = 6660 bytes por frame
    # 6660 * 10 = 66600 bytes total
    flat = np.array(all_frames).flatten()
    
    with open('sprites_color.mem', 'w') as f:
        # Procesar de a 2 pixeles
        for i in range(0, len(flat), 2):
            p1 = flat[i]
            p2 = flat[i+1]
            
            byte_val = ((p1 & 0x7) << 3) | (p2 & 0x7)
            f.write(f'{byte_val:02X}\n')
            
    print(f"Generados {len(flat)//2} bytes de 8-bits en sprites_color.mem")
    print("Paleta guardada en palette.svh")

if __name__ == '__main__':
    generate_palette_mem()
