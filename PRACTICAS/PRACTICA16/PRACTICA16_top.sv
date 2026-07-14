// Práctica 16: Imagen estática a color de 16 bits (RGB565) desde BRAM
// Concepto: Desplegar una imagen a todo color en formato RGB565 (120x120 píxeles) desde una
//           memoria ROM (Block RAM) direccionada con coordenadas relativas dentro de un visor centrado.

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
    // 2. LÓGICA DE LA IMAGEN
    // =================================================
    
    localparam SCREEN_WIDTH  = 9'd480;
    localparam SCREEN_HEIGHT = 9'd272;
    localparam BITMAP_WIDTH  = 9'd120;
    localparam BITMAP_HEIGHT = 9'd120;

    logic frame;
    logic [15:0] pixel_color;
    logic logo_viewport;
    logic [14:0] x_viewport;
    logic [14:0] y_viewport;

    logic x_vel = 1;
    logic y_vel = 1;
    logic [8:0] x_pos = 9'd180; // Centrado inicial (480-120)/2
    logic [8:0] y_pos = 9'd76;  // Centrado inicial (272-120)/2

    // Detectar el inicio de un nuevo frame (cuando x e y vuelven a 0)
    assign frame = (x == 0 && y == 0);

    // Coordenadas relativas a la imagen
    assign x_viewport = x - x_pos;
    assign y_viewport = y - y_pos;
    
    // Saber si el pixel actual está dentro del cuadro de la imagen
    assign logo_viewport = (x >= x_pos) &&
                           (y >= y_pos) &&
                           (x < (x_pos + BITMAP_WIDTH)) &&
                           (y < (y_pos + BITMAP_HEIGHT));

    // Instancia de la memoria ROM con el mapa de bits RGB565 (120x120)
    rom_image #(
        .ADDR_WIDTH(14),
        .WIDTH(120),
        .HEIGHT(120),
        .IMAGE_PATH("image.mem")
    ) dr_stone_img (
        .clk(lcd_clock),
        .x(x_viewport[13:0]),
        .y(y_viewport[13:0]),
        .pixel(pixel_color)
    );

    // Asignación de colores al LCD (RGB565)
    always_comb begin
        if (lcd_de && logo_viewport) begin
            // El formato es RGB565: R[15:11], G[10:5], B[4:0]
            red   = pixel_color[15:11];
            green = pixel_color[10:5];
            blue  = pixel_color[4:0];
        end else begin
            // Fondo negro
            red   = 5'd0;
            green = 6'd0;
            blue  = 5'd0;
        end
    end

endmodule
