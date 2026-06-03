// Práctica 12: Animación física (Pelota rebotante)
// Concepto: Simular física simple de colisiones elásticas contra las paredes de la pantalla de 480x272 píxeles
//           utilizando lógica de rebote simétrica y el radio del objeto.

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

    // Generador de movimiento a 60 Hz
    logic enable;
    strobe_gen # (
        .clk_mhz   ( 27 ),
        .strobe_hz ( 60 )
    )
    i_strobe_gen (
        .clk    ( clock  ),
        .rst    ( reset  ),
        .strobe ( enable )
    );

    // Posición y dirección
    logic [8:0] pos_x;
    logic [8:0] pos_y;
    logic dir_x;  // 0 = derecha, 1 = izquierda
    logic dir_y;  // 0 = abajo, 1 = arriba
    
    // Físicas del rebote:
    // Pantalla: 480x272 (X: 0 a 479, Y: 0 a 271)
    // Pelota: Radio = 20 píxeles (R^2 = 400 en la ecuación de abajo)
    // Para que no se salga de los bordes, el centro debe estar limitado a:
    // X_min = R = 20, X_max = 480 - R = 460
    // Y_min = R = 20, Y_max = 272 - R = 252
    
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            pos_x <= 9'd200;
            pos_y <= 9'd120;
            dir_x <= 1'b0;
            dir_y <= 1'b0;
        end
        else if (enable) begin
            // Mover en X
            if (dir_x == 1'b0) begin // Moviendo a la derecha
                if (pos_x >= 9'd460) dir_x <= 1'b1;
                else pos_x <= pos_x + 4;
            end
            else begin               // Moviendo a la izquierda
                if (pos_x <= 9'd20) dir_x <= 1'b0;
                else pos_x <= pos_x - 4;
            end
            
            // Mover en Y
            if (dir_y == 1'b0) begin // Moviendo hacia abajo
                if (pos_y >= 9'd252) dir_y <= 1'b1;
                else pos_y <= pos_y + 3;
            end
            else begin               // Moviendo hacia arriba
                if (pos_y <= 9'd20) dir_y <= 1'b0;
                else pos_y <= pos_y - 3;
            end
        end
    end

    // Dibujar
    always_comb begin
        red = 5'h00;
        green = 6'h00;
        blue = 5'h00;
        
        // Pelota que rebota
        if ((x-pos_x)*(x-pos_x) + (y-pos_y)*(y-pos_y) < 400) begin
            red = 5'h1F;
            green = 6'h00;
            blue = 5'h00;  // Rojo
        end
    end

endmodule