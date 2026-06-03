import serial
import time

# Ajusta el puerto según tu configuración:
# En Raspberry Pi el puerto suele ser /dev/serial0 o /dev/ttyAMA0
# Si usas un adaptador USB-serial, puede ser /dev/ttyUSB0
puerto = "/dev/serial0"
baudrate = 115200

ser = serial.Serial(puerto, baudrate, timeout=1)

print("Esperando datos desde FPGA... (Ctrl+C para salir)")
time.sleep(1)  # pequeña pausa para estabilizar

try:
    while True:
        if ser.in_waiting > 0:
            dato = ser.read(1)  # leer un byte
            valor = dato[0]
            print(f"Recibido: 0x{valor:02X} ({chr(valor)})")
except KeyboardInterrupt:
    print("\nTerminando programa.")
finally:
    ser.close()
