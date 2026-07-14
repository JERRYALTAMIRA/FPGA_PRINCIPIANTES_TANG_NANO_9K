#!/usr/bin/env python3
import os
import glob
from PIL import Image

def rgb888_to_rgb332(r, g, b):
    # R: 3 bits (0-7), G: 3 bits (0-7), B: 2 bits (0-3)
    r3 = (r >> 5) & 0x07
    g3 = (g >> 5) & 0x07
    b2 = (b >> 6) & 0x03
    return (r3 << 5) | (g3 << 2) | b2

def process_image(img_path, width=480, height=272, fill_bg=(0,0,0)):
    print(f"Procesando: {img_path}")
    img = Image.open(img_path)
    
    # Si la imagen no tiene el tamaño exacto, preguntar cómo escalarla
    if img.size != (width, height):
        print(f"  Dimensiones originales: {img.size[0]}x{img.size[1]}")
        print("  La imagen no es de 480x272. ¿Cómo deseas procesarla?")
        print("  1. Escalar y estirar para llenar la pantalla.")
        print("  2. Mantener aspecto y centrar (con fondo negro).")
        opc = input("  Selecciona opción (1 o 2) [Default: 2]: ").strip()
        if opc == '1':
            img = img.resize((width, height), Image.Resampling.LANCZOS)
        else:
            # Centrar manteniendo aspecto
            img.thumbnail((width, height), Image.Resampling.LANCZOS)
            background = Image.new("RGB", (width, height), fill_bg)
            offset = ((width - img.size[0]) // 2, (height - img.size[1]) // 2)
            background.paste(img, offset)
            img = background
    else:
        img = img.convert("RGB")

    # Convertir a bytes RGB332
    bin_data = bytearray()
    for y in range(height):
        for x in range(width):
            r, g, b = img.getpixel((x, y))
            val = rgb888_to_rgb332(r, g, b)
            bin_data.append(val)
    return bin_data

def main():
    # Buscar imágenes soportadas
    extensions = ["*.png", "*.jpg", "*.jpeg", "*.bmp"]
    image_files = []
    for ext in extensions:
        image_files.extend(glob.glob(ext))
        image_files.extend(glob.glob(ext.upper()))
        
    image_files = sorted(list(set(image_files)))
    
    if not image_files:
        print("No se encontraron imágenes en el directorio actual (.png, .jpg, .bmp).")
        print("Por favor coloca al menos una imagen aquí.")
        return

    print("Imágenes encontradas:")
    for idx, f in enumerate(image_files):
        print(f"  [{idx}] {f}")
        
    print("\n¿Qué deseas hacer?")
    print("  1. Convertir UNA sola imagen.")
    print("  2. Combinar MÚLTIPLES imágenes en secuencia (para animación/galería).")
    
    choice = input("Selecciona una opción (1 o 2): ").strip()
    
    output_bin = "sd_image.bin"
    
    if choice == '2':
        indices_str = input("Ingresa los números de las imágenes separados por comas (ej. 0,1,2) o '*' para todas: ").strip()
        if indices_str == '*':
            selected_files = image_files
        else:
            indices = [int(i.strip()) for i in indices_str.split(",") if i.strip().isdigit()]
            selected_files = [image_files[i] for i in indices if i < len(image_files)]
            
        if not selected_files:
            print("Selección inválida.")
            return
            
        print(f"\nCombinando {len(selected_files)} imágenes en secuencia...")
        final_data = bytearray()
        for f in selected_files:
            final_data.extend(process_image(f))
            
        with open(output_bin, "wb") as out_f:
            out_f.write(final_data)
            
        print(f"\n¡Éxito! Archivo multiframe guardado como: '{output_bin}' ({len(final_data)} bytes)")
        print(f"Cada frame ocupa exactamente 130,560 bytes (255 sectores).")
        print(f"Total sectores requeridos: {len(final_data) // 512}")
        
    else:
        img_idx_str = input(f"Selecciona el número de la imagen (0-{len(image_files)-1}): ").strip()
        if not img_idx_str.isdigit() or int(img_idx_str) >= len(image_files):
            print("Selección inválida.")
            return
            
        selected_file = image_files[int(img_idx_str)]
        bin_data = process_image(selected_file)
        
        with open(output_bin, "wb") as out_f:
            out_f.write(bin_data)
            
        print(f"\n¡Éxito! Imagen convertida y guardada como: '{output_bin}' ({len(bin_data)} bytes)")
        print(f"Ocupa exactamente 255 sectores de 512 bytes en la SD.")

if __name__ == "__main__":
    main()
