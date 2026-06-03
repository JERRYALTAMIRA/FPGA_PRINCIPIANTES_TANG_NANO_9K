// Práctica 9: Coordenadas de pantalla y colores
// Concepto: Controlar colores de píxeles combinacionalmente basándose en coordenadas x, y en LCD.

module practicas_top
(
    input  logic       clock,
    input  logic       slow_clock,
    input  logic       reset,

    input  logic [7:0] key,
    output logic [7:0] led,

    output logic [7:0] abcdefgh,
    output logic [7:0] digit,

    // Coordenadas del píxel actual en pantalla (LCD de 480x272 píxeles)
    // x va de 0 a 479 (de izquierda a derecha)
    // y va de 0 a 271 (de arriba a abajo)
    input  logic [8:0] x,
    input  logic [8:0] y,
    output logic [4:0] red,
    output logic [5:0] green,
    output logic [4:0] blue,

    inout  logic [3:0] gpio,

    input  logic       uart_rx,
    output logic       uart_tx
);

    // Apagar todo lo que no usamos
    assign abcdefgh = 8'h00;
    assign digit = 8'h00;
    assign led = 8'h00;
    assign gpio = 4'bzzzz;
    assign uart_tx = 1'b1;

    // Dibujar en pantalla (bloque combinacional)
    always_comb begin
        // Fondo negro
        red = 5'h00;
        green = 6'h00;
        blue = 5'h00;
        
        // Rectángulo rojo (esquina superior izquierda)
        if (x > 50 && x < 150 && y > 50 && y < 100) begin
            red = 5'h1F;  // Rojo máximo
            green = 6'h00;
            blue = 5'h00;
        end
        
        // Rectángulo verde (esquina superior derecha)
        if (x > 330 && x < 430 && y > 50 && y < 100) begin
            red = 5'h00;
            green = 6'h3F;  // Verde máximo
            blue = 5'h00;
        end
        
        // Rectángulo azul (centro)
        if (x > 190 && x < 290 && y > 110 && y < 160) begin
            red = 5'h00;
            green = 6'h00;
            blue = 5'h1F;  // Azul máximo
        end
    end

endmodule