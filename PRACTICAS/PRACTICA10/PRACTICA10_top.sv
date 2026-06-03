// Práctica 10: Movimiento automático en pantalla LCD
// Concepto: Utilizar strobe_gen para mover un objeto horizontalmente a una velocidad de cuadros fija (30 Hz).

module practicas_top
(
    input  logic       clock,
    input  logic       slow_clock,
    input  logic       reset,

    input  logic [7:0] key,
    output logic [7:0] led,

    output logic [7:0] abcdefgh,
    output logic [7:0] digit,

    input  logic [8:0] x,
    input  logic [8:0] y,
    output logic [4:0] red,
    output logic [5:0] green,
    output logic [4:0] blue,

    inout  logic [3:0] gpio,

    input  logic       uart_rx,
    output logic       uart_tx
);

    assign abcdefgh = 8'h00;
    assign digit = 8'h00;
    assign led = 8'h00;
    assign gpio = 4'bzzzz;
    assign uart_tx = 1'b1;

    // Generador de pulsos para mover figura a 30 Hz
    logic enable;
    strobe_gen # (
        .clk_mhz   ( 27 ),
        .strobe_hz ( 30 )
    )
    i_strobe_gen (
        .clk    ( clock  ),
        .rst    ( reset  ),
        .strobe ( enable )
    );

    // Posición del rectángulo
    logic [8:0] pos_x;
    
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            pos_x <= 9'd0;
        end
        else if (enable) begin
            if (pos_x >= 9'd400)  // Límite de pantalla
                pos_x <= 9'd0;
            else
                pos_x <= pos_x + 1;
        end
    end

    // Dibujar
    always_comb begin
        red = 5'h00;
        green = 6'h00;
        blue = 5'h00;
        
        // Rectángulo amarillo que se mueve
        if (x > pos_x && x < pos_x + 50 && y > 100 && y < 150) begin
            red = 5'h1F;
            green = 6'h3F;
            blue = 5'h00;  // Amarillo
        end
    end

endmodule