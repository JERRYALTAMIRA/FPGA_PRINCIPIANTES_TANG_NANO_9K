// Práctica 2: El botón que enciende el LED
// Concepto: Leer entradas (key) para controlar LEDs

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

    // =================================================
    // 1. APAGAR TODO LO QUE NO USAMOS
    // =================================================
    assign abcdefgh = 8'h00;
    assign digit    = 8'h00;
    assign red      = 5'h00;
    assign green    = 6'h00;
    assign blue     = 5'h00;
    assign gpio     = 4'bzzzz;
    assign uart_tx  = 1'b1;

    // =================================================
    // 2. BOTÓN CONTROLA LED
    // =================================================
    // ¡IMPORTANTE! Los botones usan lógica negativa:
    // key = 0 cuando está PRESIONADO
    // key = 1 cuando está LIBRE
    //
    // Usamos ~ (NOT) para invertir: ~0 = 1 (LED encendido)
    //
    // Usamos la concatenación {} para unir 7 bits apagados con el bit del botón:
    assign led = {7'b0000000, ~key[0]}; // Botón 0 → LED 0, los demás apagados

endmodule