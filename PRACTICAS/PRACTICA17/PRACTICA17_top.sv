// Práctica 17: Animación de sprites a color con transparencia
// Concepto: Generar una animación a color de Terry Bogard (8 frames de 120x104 píxeles) desde una
//           BRAM indexada con temporización de barrido vsync (frame_tick), implementando
//           una paleta de colores indexada (3 bits por píxel) y transparencia (color keying).

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
    localparam BITMAP_HEIGHT = 9'd104;

    logic frame_tick;
    logic [2:0] pixel_val;
    logic logo_viewport;
    logic logo_viewport_mask;
    logic [8:0] x_viewport;
    logic [8:0] y_viewport;

    logic [8:0] x_pos = 9'd180; // Centrado inicial (480-120)/2 = 180
    logic [8:0] y_pos = 9'd84;  // Centrado inicial (272-104)/2 = 84

    // Detectar el final de un frame de pantalla (vsync)
    // Cuando x e y son 0, inicia un nuevo barrido de pantalla
    assign frame_tick = (x == 0 && y == 0);

    // Lógica para actualizar el frame de la animación
    logic [4:0] frame_delay = 0;
    logic [3:0] anim_frame = 0;

    always_ff @(posedge lcd_clock) begin
        if (reset) begin
            frame_delay <= 0;
            anim_frame <= 0;
        end else if (frame_tick) begin
            // lcd_vsync es ~60Hz. Actualizar cada 6 frames = ~100ms
            if (frame_delay == 25) begin
                frame_delay <= 0;
                if (anim_frame == 7) begin
                    anim_frame <= 0;
                end else begin
                    anim_frame <= anim_frame + 1'b1;
                end
            end else begin
                frame_delay <= frame_delay + 1'b1;
            end
        end
    end

    // Coordenadas relativas a la imagen
    assign x_viewport = x - x_pos;
    assign y_viewport = y - y_pos;
    
    // Saber si el pixel actual está dentro del cuadro de la imagen
    assign logo_viewport = (x >= x_pos) &&
                           (y >= y_pos) &&
                           (x < (x_pos + BITMAP_WIDTH)) &&
                           (y < (y_pos + BITMAP_HEIGHT));

    // Instancia de la memoria ROM animada (120x104 x 8 frames) a color 3-bits
    rom_sprites #(
        .ADDR_WIDTH(16),
        .WIDTH(120),
        .HEIGHT(104),
        .FRAMES(8),
        .IMAGE_PATH("sprites_color.mem")
    ) terry_anim (
        .clk(lcd_clock),
        .x(x_viewport[6:0]), // 0 to 119
        .y(y_viewport[6:0]), // 0 to 103
        .frame(anim_frame),
        .pixel(pixel_val)
    );

    // Asignación de colores al LCD (RGB565)
    always_comb begin
        logo_viewport_mask = 1'b0;
        if (lcd_de && logo_viewport) begin
            `include "palette.svh"
            
            if (!logo_viewport_mask) begin
                // Transparente (Fondo gris)
                red   = 5'd4;
                green = 6'd8;
                blue  = 5'd4;
            end
        end else begin
            // Fondo gris oscuro para la pantalla
            red   = 5'd4;
            green = 6'd8;
            blue  = 5'd4;
        end
    end

endmodule
