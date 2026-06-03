// Práctica 11: Control interactivo por botones
// Concepto: Leer entradas de múltiples botones simultáneamente para controlar las coordenadas X, Y de un objeto en pantalla.

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

    // Botones en lógica positiva (1 = presionado, invertidos desde key)
    logic left, right, up, down;
    assign left  = ~key[0];
    assign right = ~key[1];
    assign up    = ~key[2];
    assign down  = ~key[3];

    // Posición
    logic [8:0] pos_x;
    logic [8:0] pos_y;
    
    always_ff @(posedge slow_clock or posedge reset) begin
        if (reset) begin
            pos_x <= 9'd200;
            pos_y <= 9'd120;
        end
        else begin
            if (left && pos_x > 5)  pos_x <= pos_x - 5;
            if (right && pos_x < 425) pos_x <= pos_x + 5;
            if (up && pos_y > 5)    pos_y <= pos_y - 5;
            if (down && pos_y < 220) pos_y <= pos_y + 5;
        end
    end

    // Dibujar
    always_comb begin
        red = 5'h00;
        green = 6'h00;
        blue = 5'h00;
        
        // Cuadrado blanco controlado por botones
        if (x > pos_x && x < pos_x + 40 && y > pos_y && y < pos_y + 40) begin
            red = 5'h1F;
            green = 6'h3F;
            blue = 5'h1F;  // Blanco
        end
        
        // Borde de pantalla (referencia visual)
        if (x < 5 || x > 474 || y < 5 || y > 266) begin
            red = 5'h0F;
            green = 6'h0F;
            blue = 5'h0F;  // Gris
        end
    end

endmodule