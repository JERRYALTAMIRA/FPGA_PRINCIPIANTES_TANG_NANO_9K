// Práctica 5: Contador binario en LEDs
// Concepto: Mostrar el valor de un contador en LEDs (sistema binario)

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
    // 2. CONTADOR DE 8 BITS (0 a 255)
    // =================================================
    // slow_clock es ~100 Hz, así que el contador aumenta
    // aproximadamente 100 veces por segundo (lo cual es visible)
    
    logic [7:0] counter;   // 8 bits = rango de valores de 0 a 255
    
    always_ff @(posedge slow_clock or posedge reset) begin
        if (reset) begin
            counter <= 8'h00;   // Comienza en 0 (usamos hexadecimal para abreviar)
        end
        else begin
            counter <= counter + 8'h01; // Incrementa en 1 cada ciclo de slow_clock
        end
    end
    
    // =================================================
    // 3. MOSTRAR CONTADOR EN LEDs
    // =================================================
    // Los LEDs muestran directamente el valor binario del contador:
    // led[7] es el bit más significativo (MSB) y led[0] es el bit menos significativo (LSB)
    assign led = counter;
    
    // Ejemplo ilustrativo:
    // Si counter = 42 (en decimal) = 00101010 (en binario)
    // LED7  LED6  LED5  LED4  LED3  LED2  LED1  LED0
    //  OFF   OFF    ON   OFF    ON   OFF    ON   OFF
    //   0     0     1     0     1     0     1     0

endmodule