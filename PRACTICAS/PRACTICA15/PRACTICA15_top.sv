// Práctica 15: Imagen estática de Dr. Stone en Blanco y Negro (1 bit por píxel)
// Concepto: Desplegar una imagen monocromática de alta resolución (480x270) que abarca casi toda
//           la pantalla de 480x272 píxeles, utilizando una memoria BRAM interna direccionada por las
//           coordenadas directas del LCD.

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
    // 2. LÓGICA DE LA IMAGEN (ESCALA 1:1, B/N 480x270)
    // =================================================
    
    localparam SCREEN_WIDTH  = 9'd480;
    localparam SCREEN_HEIGHT = 9'd272;
    localparam BITMAP_WIDTH  = 9'd480;
    localparam BITMAP_HEIGHT = 9'd270;

    logic pixel_val;
    logic logo_viewport;

    // Saber si el pixel actual está dentro del rango (la imagen cubre 480x270, el LCD tiene 2 líneas extra de altura)
    assign logo_viewport = (y < BITMAP_HEIGHT);

    // Instancia de la memoria ROM con el mapa de bits 1-bit B/N (480x270)
    rom_image #(
        .ADDR_WIDTH(15),
        .WIDTH(480),
        .HEIGHT(270),
        .IMAGE_PATH("image.mem")
    ) dr_stone_img (
        .clk(lcd_clock),
        .x(x),
        .y(y),
        .pixel(pixel_val)
    );

    // Asignación de colores al LCD (Blanco y Negro)
    always_comb begin
        if (lcd_de && logo_viewport) begin
            if (pixel_val) begin
                // Blanco (máximo valor en RGB565)
                red   = 5'd31;
                green = 6'd63;
                blue  = 5'd31;
            end else begin
                // Negro
                red   = 5'd0;
                green = 6'd0;
                blue  = 5'd0;
            end
        end else begin
            // Fondo negro (para las 2 líneas sobrantes en Y = 270 y 271)
            red   = 5'd0;
            green = 6'd0;
            blue  = 5'd0;
        end
    end

endmodule
