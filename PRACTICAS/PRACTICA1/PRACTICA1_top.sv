// Práctica 1: Encender un LED
// Concepto: assign = conexión permanente

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

    // ⭐ PUERTOS UART (necesarios aunque no los usemos)
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
    assign uart_tx  = 1'b1;     // UART inactivo

    // =================================================
    // 2. ENCENDER EL LED 0
    // =================================================
    // Asignamos el bus completo de 8 bits.
    // El bit de más a la derecha (led[0]) es 1, los demás son 0.
    assign led = 8'b00000001;

endmodule