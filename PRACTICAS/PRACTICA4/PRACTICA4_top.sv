// Práctica 4: El LED que parpadea
// Concepto: Usar un contador para dividir la frecuencia del reloj

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
    // 2. CONTADOR PARA DIVIDIR LA FRECUENCIA
    // =================================================
    // La FPGA Tang Nano 9K tiene un reloj de 27 MHz (27,000,000 ciclos por segundo).
    // Usamos un contador de 25 bits (puede contar de 0 a 2^25 - 1, o sea, 33,554,431).
    //
    // Matemáticas de división de frecuencia:
    // - El bit 0 (counter[0]) cambia cada ciclo de reloj (tasa de 13.5 MHz).
    // - El bit N cambia a una frecuencia de: 27 MHz / 2^(N+1).
    // - Para el bit 24 (MSB): Frecuencia = 27,000,000 / 2^25 = 27,000,000 / 33,554,432 ≈ 0.8 Hz.
    // - El periodo completo de parpadeo es T = 1 / 0.8 Hz ≈ 1.24 segundos.
    // - Esto significa que el LED estará encendido 0.62 segundos y apagado 0.62 segundos.
    
    logic [24:0] counter;   // Contador de 25 bits
    
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            counter <= 25'b0; // Inicializar explícitamente a 25 bits en 0
        end
        else begin
            counter <= counter + 25'b1;
        end
    end
    
    // =================================================
    // 3. LED PARPADEANTE
    // =================================================
    // El bit más de la izquierda (24) cambia a la velocidad más lenta.
    assign led[0] = counter[24];   // Parpadea cada ~0.6 segundos
    
    // Los demás LEDs apagados
    assign led[7:1] = 7'b0000000;

endmodule