#!/usr/bin/env python3
import os
import glob
from PIL import Image

def convert_to_rgb565(r, g, b):
    # R: 5 bits (0-31), G: 6 bits (0-63), B: 5 bits (0-31)
    r5 = (r >> 3) & 0x1F
    g6 = (g >> 2) & 0x3F
    b5 = (b >> 3) & 0x1F
    return (r5 << 11) | (g6 << 5) | b5

def main():
    # Buscar imágenes en el directorio actual
    extensions = ["*.png", "*.jpg", "*.jpeg", "*.bmp"]
    image_files = []
    for ext in extensions:
        image_files.extend(glob.glob(ext))
        image_files.extend(glob.glob(ext.upper()))
    image_files = sorted(list(set(image_files)))

    if not image_files:
        print("No se encontraron imagenes en la carpeta actual (.png, .jpg, .bmp).")
        print("Por favor, coloca al menos una imagen aqui.")
        return

    print("Imagenes encontradas:")
    for idx, f in enumerate(image_files):
        print(f"  [{idx}] {f}")

    img_idx_str = input(f"Selecciona el numero de la imagen (0-{len(image_files)-1}): ").strip()
    if not img_idx_str.isdigit() or int(img_idx_str) >= len(image_files):
        print("Seleccion invalida.")
        return

    selected_file = image_files[int(img_idx_str)]
    print(f"\nProcesando '{selected_file}'...")
    
    img = Image.open(selected_file).convert("RGB")
    orig_w, orig_h = img.size
    print(f"Dimensiones nativas: {orig_w}x{orig_h}")

    print("\n¿Deseas escalar la imagen?")
    print("  1. No (usar tamaño nativo)")
    print("  2. Escalar a 150x150 (Snow Bros)")
    print("  3. Escalar a otra dimension personalizada")
    opc = input("Selecciona opcion (1, 2 o 3) [Default: 2]: ").strip()

    if opc == '1':
        width, height = orig_w, orig_h
    elif opc == '3':
        width = int(input("Ancho objetivo: ").strip())
        height = int(input("Alto objetivo: ").strip())
        img = img.resize((width, height), Image.Resampling.LANCZOS)
    else: # Default 150x150
        width, height = 150, 150
        img = img.resize((width, height), Image.Resampling.LANCZOS)

    output_mem = "image.mem"
    with open(output_mem, "w") as f:
        for y in range(height):
            for x in range(width):
                r, g, b = img.getpixel((x, y))
                val16 = convert_to_rgb565(r, g, b)
                f.write(f"{val16:04X}\n")

    print(f"\n¡Exito! Archivo guardado como '{output_mem}'.")
    print(f"Dimensiones de la imagen en el archivo .mem: {width}x{height}")
    print(f"Pixeles totales: {width*height}")
    print(f"Para el modulo Verilog, asegúrate de configurar:")
    print(f"  - WIDTH = {width}")
    print(f"  - HEIGHT = {height}")
    import math
    bits_needed = math.ceil(math.log2(width * height))
    print(f"  - ADDR_WIDTH = {bits_needed}")

if __name__ == "__main__":
    main()
