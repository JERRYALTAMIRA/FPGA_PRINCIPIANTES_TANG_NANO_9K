# FPGA-PRINCIPIANTES-TANG-NANO-9K
Prácticas de diseño digital con Verilog/SystemVerilog para FPGA Gowin Tang Nano 9K. Basado en el repositorio basics-graphics-music de Yuri Panchul. Incluye guía de instalación para Ubuntu, configuración de VS Code y 14 prácticas progresivas desde LEDs hasta sensor ultrasónico.

# Prácticas de FPGA (Verilog/SystemVerilog)
> **Basado en el trabajo de [Yuri Panchul](https://github.com/yuri-panchul)**

> Este proyecto es una adaptación del repositorio [basics-graphics-music](https://github.com/yuri-panchul/basics-graphics-music), orientada específicamente a la placa **Gowin Tang Nano 9K** y su módulo de expansión con LCD y TM1638.

> Todo el crédito del código base, estructura de scripts y metodología de enseñanza pertenece a Yuri Panchul y colaboradores.

Este repositorio contiene una colección de prácticas para aprender diseño digital con Verilog y SystemVerilog, optimizadas para ejecutarse en sistemas **Linux (Ubuntu)** utilizando placas de desarrollo basadas en chips Gowin (por ejemplo, **Sipeed Tang Nano 9K**).

## Enlace del Repositorio
Este proyecto está preparado para ser subido a GitHub. Puedes reemplazar el siguiente enlace con la dirección de tu repositorio:
* **Repositorio oficial:** [Enlace a GitHub](https://github.com/REPLACE_WITH_YOUR_USERNAME/REPLACE_WITH_YOUR_REPO_NAME)

---

## 🛠️ Requisitos e Instalación (Ubuntu Linux)

Para poder compilar y cargar los diseños en la FPGA desde Ubuntu, realiza los siguientes pasos:

### 1. Instalar dependencias del sistema
Abre una terminal y ejecuta el siguiente comando para instalar las herramientas necesarias:
```bash
sudo apt update
sudo apt install -y git python3 python3-pip openfpgaloader
```
> [!NOTE]
> `openFPGALoader` es una herramienta de código abierto muy útil en Linux para programar FPGAs de diversas marcas, incluyendo Gowin.

### 2. Descargar e instalar Gowin EDA para Linux
1. Crea una cuenta gratuita en la [web de Gowin](https://www.gowinsemi.com/en/member/).
2. Descarga la versión educativa para Linux (**Gowin V1.9 Education (Linux)**) desde la sección de descargas de Gowin.
3. Extrae el archivo comprimido (.tar.gz) en tu carpeta de usuario:
   ```bash
   mkdir -p ~/gowin
   tar -xf Gowin_V1.9.XX.XX_Education_Linux.tar.gz -C ~/gowin --strip-components=1
   ```
   *(Asegúrate de reemplazar el nombre del archivo con el que hayas descargado).*
4. Los scripts de este repositorio buscarán de forma automática Gowin EDA dentro de tu carpeta `~/gowin` o `/opt/gowin`.

### 3. Configurar reglas de USB (udev rules) para la tarjeta
Para poder programar la placa FPGA sin permisos de superusuario (`sudo`), debes instalar las reglas USB.
Ejecuta el siguiente comando para copiar las reglas de Sipeed a tu sistema:
```bash
sudo cp scripts/fpga/91-sipeed.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
```
Luego, **desconecta y vuelve a conectar** el cable USB de tu tarjeta FPGA.

---

## 💻 Configuración de Visual Studio Code

Para tener un entorno de desarrollo cómodo con autocompletado y resaltado de sintaxis, abre este directorio con VS Code e instala los siguientes plugins desde el marketplace de extensiones:

1. **Verilog-HDL/SystemVerilog support for VS Code** (Creado por `mshr-h`)
   * Proporciona coloreado de sintaxis, autocompletado e integración con linters para Verilog y SystemVerilog.
2. **Verilog/SystemVerilog Tools** (Creado por `leafle`)
   * Ayuda con la navegación de código digital, instanciación de módulos y otras utilidades de productividad para hardware.

---

## 🚀 Guía de Uso y Ejecución de las Prácticas

Todas las prácticas están ubicadas en el directorio `PRACTICAS/` y se ejecutan directamente desde la terminal integrada de VS Code utilizando bash.

### Paso 1: Seleccionar la tarjeta FPGA (Solo la primera vez)
Antes de ejecutar cualquier práctica, debes indicarle al sistema qué placa FPGA estás utilizando. En la terminal integrada, sitúate en la raíz del proyecto y ejecuta:
```bash
./check_setup_and_choose_fpga_board.bash
```
Selecciona la opción correspondiente a tu tarjeta (por ejemplo, escribe `3` para seleccionar la tarjeta de prácticas: `tang_nano_9k_lcd_480_272_tm1638_practicas`).

### Paso 2: Ejecutar una práctica
Una vez seleccionada tu tarjeta, para compilar y probar cualquier práctica (por ejemplo, la Práctica 1), abre la terminal integrada en VS Code y sigue estos pasos:

1. **Entra en el directorio de la práctica:**
   ```bash
   cd PRACTICAS/PRACTICA1
   ```
2. **Sintetizar y cargar a la FPGA:**
   ```bash
   ./03_synthesize_for_fpga.bash
   ```
   *Este comando compilará (sintetizará) el código utilizando Gowin EDA en segundo plano y, si la compilación tiene éxito, subirá el diseño automáticamente a la FPGA conectada.*

### Otros scripts útiles por práctica
Dentro de cada directorio de práctica también encontrarás los siguientes scripts auxiliares:

* `./04_configure_fpga.bash`: Carga el bitstream previamente compilado a la FPGA (sin volver a compilar).
* `./05_run_gui_for_fpga_synthesis.bash`: Abre el entorno gráfico (IDE de Gowin) con el proyecto cargado. Útil si deseas ver el RTL Viewer o realizar configuraciones visuales.
* `./01_clean.bash`: Borra los archivos temporales generados por la síntesis en esa práctica específica.

### Limpieza general
Si deseas limpiar los archivos temporales de **todas** las prácticas a la vez para ahorrar espacio antes de subir a GitHub, ve a la raíz del proyecto y ejecuta:
```bash
./clean_all.bash
```

---
> [!TIP]
> Recuerda que esta es una guía express de configuración básica para comenzar de inmediato. Todos los detalles teóricos, diagramas y descripciones extendidas de los módulos los encontrarás en el documento PDF principal.
