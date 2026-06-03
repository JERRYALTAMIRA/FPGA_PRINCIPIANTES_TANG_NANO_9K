// Práctica 3: Compuertas lógicas (AND, OR, XOR)
// Concepto: Combinar entradas usando operadores lógicos

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
    // 2. CONVERTIR BOTONES A LÓGICA POSITIVA
    // =================================================
    // Para hacer el código más legible, creamos variables
    // que son 1 cuando el botón está presionado
    logic b0, b5;
    assign b0 = ~key[0];   // b0 = 1 cuando botón 0 está presionado
    assign b1 = ~key[1];   // b1 = 1 cuando botón 1 está presionado
    assign b2 = ~key[2];   // b2 = 1 cuando botón 2 está presionado
    assign b3 = ~key[3];   // b3 = 1 cuando botón 3 está presionado
    assign b4 = ~key[4];   // b4 = 1 cuando botón 4 está presionado
    assign b5 = ~key[5];   // b5 = 1 cuando botón 5 está presionado
    // =================================================
    // 3. COMPUERTAS LÓGICAS (Operadores a Nivel de Bits)
    // =================================================
    // Nota: Usamos operadores a nivel de bits (&, |, ^, ~) porque estamos
    // trabajando con señales físicas (cables individuales).
    // Evita usar operadores lógicos (&&, ||, !) que se usan para condiciones lógicas.
    
    // LED 0: AND (ambos botones presionados)
    assign led[0] = b0 & b1;
    
    // LED 1: OR (al menos un botón presionado)
    assign led[3] = b2 | b3;
    
    // LED 2: XOR (exactamente uno de los dos botones presionado)
    assign led[5] = b4 ^ b5;
    
    // Extra/Desafío:
    // LED 3: NAND -> assign led[3] = ~(b0 & b1);
    // LED 4: NOR  -> assign led[4] = ~(b0 | b1);
    // LED 5: XNOR -> assign led[5] = ~(b0 ^ b1);
        
    // Los demás LEDs apagados (6 y 7)
    assign led[7:6] = 2'b00;

endmodule