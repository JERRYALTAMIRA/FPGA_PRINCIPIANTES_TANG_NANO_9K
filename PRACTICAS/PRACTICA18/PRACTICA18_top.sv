// Práctica 18: Lector de imágenes a color desde tarjeta MicroSD en LCD
// Concepto: Leer y desplegar una imagen de pantalla completa (480x272) con profundidad de color
//           de 8 bits (RGB332) desde una tarjeta de almacenamiento MicroSD utilizando el protocolo SPI,
//           almacenando los datos leídos temporalmente en un buffer de línea (Block RAM de doble puerto).

module practicas_top
(
    input  logic       clock,       // 27 MHz desde la tarjeta
    input  logic       slow_clock,
    input  logic       reset,       // Botón de reset
    
    input  logic [7:0] key,
    output logic [7:0] led,
    output logic [7:0] abcdefgh,
    output logic [7:0] digit,
    
    // UART
    input  logic       uart_rx,
    output logic       uart_tx,

    // LCD 480x272
    input  logic       lcd_clock,
    input  logic       lcd_de,
    input  logic [8:0] x,
    input  logic [8:0] y,
    output logic [4:0] red,
    output logic [5:0] green,
    output logic [4:0] blue,
    
    inout  logic [3:0] gpio,

    // SD Card (Pines Físicos)
    output logic       sd_cs,
    output logic       sd_sclk,
    output logic       sd_mosi,
    input  logic       sd_miso,

    // Pines Físicos de la PSRAM (GW1NR-9)
    output logic [1:0] O_psram_ck,
    output logic [1:0] O_psram_ck_n,
    inout  logic [1:0] IO_psram_rwds,
    inout  logic [15:0] IO_psram_dq,
    output logic [1:0] O_psram_reset_n,
    output logic [1:0] O_psram_cs_n
);

    // =================================================
    // 1. APAGAR PERIFÉRICOS NO UTILIZADOS
    // =================================================
    assign led = 8'h00;
    assign uart_tx = 1'b1; 
    assign gpio[3:2] = 2'bzz;

    // Desactivar PSRAM
    assign O_psram_ck = 2'b00;
    assign O_psram_ck_n = 2'b11;
    assign O_psram_reset_n = 2'b00;
    assign O_psram_cs_n = 2'b11;

    // =================================================
    // 2. GENERADOR DE RELOJ LENTO SPI (~400 kHz)
    // =================================================
    // Divisor para conseguir ~400 kHz para la fase de inicialización de la SD
    // 27 MHz / 64 = 421.875 KHz
    logic [5:0] sd_clk_div = 6'd0;
    logic       clk_pulse_slow;

    always_ff @(posedge clock) begin
        sd_clk_div <= sd_clk_div + 1'b1;
    end
    assign clk_pulse_slow = (sd_clk_div == 6'd0);

    // =================================================
    // 3. INSTANCIACIÓN DEL CONTROLADOR SD (SPI)
    // =================================================
    logic        sd_rd;
    logic [31:0] sd_address;
    logic [7:0]  sd_dout;
    logic        sd_byte_available;
    logic        sd_ready;

    sd_controller i_sd_controller (
        .sd_cs(sd_cs),
        .sd_mosi(sd_mosi),
        .sd_miso(sd_miso),
        .sd_sclk(sd_sclk),
        .clk(clock),
        .clk_pulse_slow(clk_pulse_slow),
        .reset(reset),
        .rd(sd_rd),
        .address(sd_address),
        .dout(sd_dout),
        .byte_available(sd_byte_available),
        .ready(sd_ready)
    );

    // =================================================
    // 4. BUFFER DE DLINEA (Dual Port RAM - 1024 bytes)
    // =================================================
    // Un buffer de 1024 bytes guarda aprox. 2 líneas completas de 480 px.
    logic [9:0] wr_addr = 10'd0;
    logic [9:0] rd_addr;
    logic [7:0] pixel_color;

    // Dirección de lectura basada en las coordenadas actuales del LCD
    // x (0 a 479) e y (0 a 271) mapeadas directamente en forma cíclica.
    assign rd_addr = {1'b0, x} + (y[0] * 10'd480); 

    // Memoria interna de doble puerto inferida como Block RAM
    logic [7:0] line_buffer [0:1023];

    always_ff @(posedge clock) begin
        if (reset) begin
            wr_addr <= 10'd0;
        end else if (x == 0 && y == 0) begin
            wr_addr <= 10'd0; // Sincroniza el puntero al inicio del frame
        end else if (sd_byte_available) begin
            line_buffer[wr_addr] <= sd_dout;
            wr_addr <= wr_addr + 1'b1;
        end
    end

    // =================================================
    // 5. MÁQUINA DE ESTADOS LECTORA DE SECTORES DE LA SD
    // =================================================
    // Queremos mantener el line_buffer lleno por delante del barrido del LCD.
    // 480 px * 272 filas = 130,560 píxeles totales.
    // 130,560 bytes / 512 bytes por sector = 255 sectores.
    
    typedef enum logic [1:0] {
        ST_IDLE_SD,
        ST_START_READ,
        ST_WAIT_READ
    } fsm_sd_t;

    fsm_sd_t sd_state = ST_IDLE_SD;
    logic [8:0] sector_count = 9'd0; // 0 a 254 (255 sectores en total)
    logic [9:0] bytes_needed;        // Cuántos bytes faltan en el buffer

    // Calculamos la distancia entre el puntero de escritura de la SD y el de lectura del LCD
    // para saber cuándo necesitamos ordenar una lectura de un nuevo sector de 512 bytes.
    always_comb begin
        bytes_needed = wr_addr - rd_addr;
    end

    always_ff @(posedge clock) begin
        if (reset) begin
            sd_state     <= ST_IDLE_SD;
            sd_rd        <= 1'b0;
            sd_address   <= 32'd0;
            sector_count <= 9'd0;
        end else begin
            case (sd_state)
                ST_IDLE_SD: begin
                    // Si ya leímos toda la pantalla (255 sectores), esperamos a que el LCD empiece un nuevo barrido
                    if (sector_count >= 9'd255) begin
                        if (x == 0 && y == 0) begin
                            sector_count <= 9'd0;
                        end
                    end else begin
                        // Si el controlador está libre y hay espacio en el buffer (> 512 bytes libres), leemos
                        if (sd_ready && (bytes_needed < 10'd512)) begin
                            sd_address <= {23'd0, sector_count}; // Mapea sector 0 a 254
                            sd_rd      <= 1'b1;
                            sd_state   <= ST_START_READ;
                        end
                    end
                end

                ST_START_READ: begin
                    sd_rd    <= 1'b0;
                    sd_state <= ST_WAIT_READ;
                end

                ST_WAIT_READ: begin
                    if (sd_ready) begin
                        sector_count <= sector_count + 1'b1;
                        sd_state     <= ST_IDLE_SD;
                    end
                end
            endcase
        end
    end

    // =================================================
    // 6. CONTROL Y CONVERSIÓN DE COLOR RGB332 -> RGB565
    // =================================================
    logic [7:0] current_pixel;
    assign current_pixel = line_buffer[rd_addr];

    always_comb begin
        if (lcd_de) begin
            // Conversión de RGB332 (píxel leído de SD) a RGB565 (LCD)
            red   = {current_pixel[7:5], 2'b00}; // R: 3 bits -> 5 bits
            green = {current_pixel[4:2], 3'b000}; // G: 3 bits -> 6 bits
            blue  = {current_pixel[1:0], 3'b000}; // B: 2 bits -> 5 bits
        end else begin
            red   = 5'd0;
            green = 6'd0;
            blue  = 5'd0;
        end
    end

    // Opcional: Leds de depuración
    // El punto decimal del display 7 segmentos se apaga, etc.
    assign abcdefgh = 8'hFF;
    assign digit = 8'hFF;

endmodule
