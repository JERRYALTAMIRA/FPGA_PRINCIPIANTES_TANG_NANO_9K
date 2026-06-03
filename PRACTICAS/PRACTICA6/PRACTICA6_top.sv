// Práctica 6: Display 7 segmentos
// Concepto: Mostrar números decimales en el display decodificando valores binarios a segmentos físicos.

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
    // 1. APAGAR PERIFÉRICOS NO UTILIZADOS
    // =================================================
    assign red      = 5'h00;
    assign green    = 6'h00;
    assign blue     = 5'h00;
    assign gpio     = 4'bzzzz;
    assign uart_tx  = 1'b1;
    assign led      = 8'h00;

    // =================================================
    // 2. DECODIFICADOR DE 7 SEGMENTOS
    // =================================================
    // Patrones para display de cátodo común (1 = segmento encendido)
    // Formato de bits: {h, g, f, e, d, c, b, a} (h = punto decimal como MSB, a = segmento LSB)
    //
    //      --a--
    //     |     |
    //     f     b
    //     |     |
    //      --g--
    //     |     |
    //     e     c
    //     |     |
    //      --d--  h (punto decimal)
    //
    // Si queremos mostrar el 0, encendemos a,b,c,d,e,f (los bits 0,1,2,3,4,5 a 1) y g,h en 0:
    // {h, g, f, e, d, c, b, a} = 8'b00111111 = 8'h3F.
    //
    // Si queremos mostrar el 1, encendemos b,c (los bits 1,2 a 1):
    // {h, g, f, e, d, c, b, a} = 8'b00000110 = 8'h06.
    
    function automatic [7:0] seg7_decode(input [3:0] num);
        case (num)
            4'h0: seg7_decode = 8'b1111_1100;  // 0
            4'h1: seg7_decode = 8'b0110_0000;  // 1
            4'h2: seg7_decode = 8'b1101_1010;  // 2
            4'h3: seg7_decode = 8'b1111_0010;  // 3
            4'h4: seg7_decode = 8'b0110_0110;  // 4
            4'h5: seg7_decode = 8'b1011_0110;  // 5
            4'h6: seg7_decode = 8'b1011_1110;  // 6
            4'h7: seg7_decode = 8'b1110_0000;  // 7
            4'h8: seg7_decode = 8'b1111_1110;  // 8
            4'h9: seg7_decode = 8'b1111_0110;  // 9
            default: seg7_decode = 8'b00000000; // Apagado
        endcase
    endfunction

    // =================================================
    // 3. CONTADOR SIMPLE (0-9)
    // =================================================
    logic [3:0] counter;  // 0 a 9
    
    always_ff @(posedge slow_clock or posedge reset) begin
        if (reset) begin
            counter <= 4'b0000;
        end
        else begin
            if (counter == 4'b1001) begin  // Llegó a 9
                counter <= 4'b0000;        // Vuelve a 0
            end
            else begin
                counter <= counter + 1;
            end
        end
    end
    
    // =================================================
    // 4. MOSTRAR EN DISPLAY 7 SEGMENTOS
    // =================================================
    // Decodificar el contador a 7 segmentos
    assign abcdefgh = seg7_decode(counter);
    
    // Activar el primer dígito (dígito 0)
    assign digit = 8'b00000001;

endmodule