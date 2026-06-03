#!/usr/bin/env python3
import serial
import time

class TM1638Interactive:
    def __init__(self, port='/dev/ttyS0', baudrate=115200):
        self.ser = serial.Serial(port, baudrate, timeout=1)
        time.sleep(2)
        print("Controlador TM1638 inicializado")
        print("Escribe 'quit' para salir")
        print("Escribe 'clear' para limpiar el display")
    
    def run(self):
        try:
            while True:
                text = input("\nTexto para mostrar (máx 8 caracteres): ").strip()
                
                if text.lower() == 'quit':
                    break
                elif text.lower() == 'clear':
                    self.clear_display()
                else:
                    self.send_text(text)
        
        except KeyboardInterrupt:
            print("\nSaliendo...")
        finally:
            self.clear_display()
            self.ser.close()
    
    def send_text(self, text):
        text = text.upper()[:8]
        for char in text:
            if 32 <= ord(char) <= 126:  # Caracteres ASCII imprimibles
                self.ser.write(char.encode('ascii'))
                time.sleep(0.01)
        print(f"Mostrando: '{text}'")
    
    def clear_display(self):
        self.send_text("        ")
        print("Display limpiado")

if __name__ == "__main__":
    controller = TM1638Interactive()
    controller.run()