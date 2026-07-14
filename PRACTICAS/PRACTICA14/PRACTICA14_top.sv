// Práctica 14: Logo de DVD rebotando en pantalla LCD (1 bit por píxel)
// Concepto: Cargar una imagen monocromática de 256x128 píxeles desde una memoria ROM interna (Block RAM),
//           calcular su movimiento y colisión contra los bordes físicos de la pantalla LCD de 480x272
//           y cambiar dinámicamente de color con cada rebote.

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

    // SD Card (Pines Físicos de la tarjeta)
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

    // Desactivar SD Card
    assign sd_cs = 1'b1;
    assign sd_sclk = 1'b0;
    assign sd_mosi = 1'b1;

    // =================================================
    // 2. LÓGICA DEL LOGO DVD
    // =================================================
    
    localparam SCREEN_WIDTH  = 9'd480;
    localparam SCREEN_HEIGHT = 9'd272;
    localparam BITMAP_WIDTH  = 9'd256;
    localparam BITMAP_HEIGHT = 9'd128;

    logic frame;
    logic pixel;
    logic logo_viewport;
    logic [9:0] x_viewport;
    logic [9:0] y_viewport;

    logic x_vel = 1;
    logic y_vel = 1;
    logic [8:0] x_pos = 9'd100;
    logic [8:0] y_pos = 9'd50;
    logic [2:0] color = 3'b001; // Color inicial (Rojo, Verde, Azul en bits)

    // Detectar el inicio de un nuevo frame (cuando x e y vuelven a 0)
    assign frame = (x == 0 && y == 0);

    // Coordenadas relativas a la imagen
    assign x_viewport = x - x_pos;
    assign y_viewport = y - y_pos;
    
    // Saber si el pixel actual está dentro del cuadro del logo
    assign logo_viewport = (x >= x_pos) &&
                           (y >= y_pos) &&
                           (x < (x_pos + BITMAP_WIDTH)) &&
                           (y < (y_pos + BITMAP_HEIGHT));

    // Instancia de la memoria ROM con el mapa de bits del logo de DVD (1 bit por pixel)
    rom_bitmap #(
        .ADDR_WIDTH(16),
        .WIDTH(256),
        .HEIGHT(128),
        .BITMAP_PATH("bitmap.mem") // Ruta relativa donde se ejecutará la síntesis
    ) dvd_logo (
        .clk(lcd_clock),
        .x(x_viewport),
        .y(y_viewport),
        .pixel(pixel)
    );

    // Movimiento y cambio de color del DVD en cada frame
    always_ff @ (posedge lcd_clock) begin
        if (reset) begin
            x_pos <= 9'd100;
            y_pos <= 9'd50;
            x_vel <= 1;
            y_vel <= 1;
            color <= 3'b001;
        end else if (frame) begin
            // Rebotar en los bordes y rotar color
            if (x_pos == 0) begin
                color <= {color[1:0], color[2]};
                x_vel <= 1;
            end
            if (x_pos == (SCREEN_WIDTH - BITMAP_WIDTH)) begin
                color <= {color[1:0], color[2]};
                x_vel <= 0;
            end
            if (y_pos == 0) begin
                color <= {color[1:0], color[2]};
                y_vel <= 1;
            end
            if (y_pos == (SCREEN_HEIGHT - BITMAP_HEIGHT)) begin
                color <= {color[1:0], color[2]};
                y_vel <= 0;
            end
            
            // Actualizar posiciones
            x_pos <= x_vel ? (x_pos + 1'b1) : (x_pos - 1'b1);
            y_pos <= y_vel ? (y_pos + 1'b1) : (y_pos - 1'b1);
        end
    end

    // Asignación de colores al LCD (RGB565 convertido a 5-6-5 pines)
    always_comb begin
        if (lcd_de && logo_viewport && pixel) begin
            red   = color[0] ? 5'b11111 : 5'd0;
            green = color[1] ? 6'b111111 : 6'd0;
            blue  = color[2] ? 5'b11111 : 5'd0;
        end else begin
            red   = 5'd0;
            green = 6'd0;
            blue  = 5'd0;
        end
    end

endmodule
