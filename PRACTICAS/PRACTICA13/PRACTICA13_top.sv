// Board configuration: tang_nano_9k_lcd_480_272_tm1638_hackathon
// Práctica 13: Semáforo dibujado en LCD con máquina de estados

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
    assign abcdefgh = 8'h00;
    assign digit = 8'h00;
    assign led = 8'h00;
    assign gpio = 4'bzzzz;
    assign uart_tx = 1'b1;

    // =================================================
    // 2. SEMÁFORO CON MÁQUINA DE ESTADOS
    // =================================================
    // Estados: 0=ROJO, 1=VERDE, 2=AMARILLO
    logic [1:0] estado;
    logic [7:0] tiempo;
    
    always_ff @(posedge slow_clock or posedge reset) begin
        if (reset) begin
            estado <= 2'b00;     // Comienza en ROJO
            tiempo <= 8'd5;      // 5 segundos
        end
        else begin
            if (tiempo > 0) begin
                tiempo <= tiempo - 1;
            end
            
            if (tiempo == 8'd0) begin
                case (estado)
                    2'b00: begin  // ROJO → VERDE
                        estado <= 2'b01;
                        tiempo <= 8'd4;
                    end
                    
                    2'b01: begin  // VERDE → AMARILLO
                        estado <= 2'b10;
                        tiempo <= 8'd2;
                    end
                    
                    2'b10: begin  // AMARILLO → ROJO
                        estado <= 2'b00;
                        tiempo <= 8'd5;
                    end
                endcase
            end
        end
    end

    // =================================================
    // 3. DIBUJAR SEMÁFORO EN LCD
    // =================================================
    // Posiciones del semáforo en la pantalla
    localparam CENTRO_X = 240;
    localparam CENTRO_Y = 136;
    localparam RADIO = 20;       // Ajustado de 40 a 20 para evitar superposición
    localparam SEPARACION = 55;  // Ajustado de 50 a 55 para que las luces estén separadas proporcionalmente
    
    // Posiciones verticales de cada círculo
    localparam ROJO_Y   = CENTRO_Y - SEPARACION;
    localparam AMARILLO_Y = CENTRO_Y;
    localparam VERDE_Y  = CENTRO_Y + SEPARACION;
    
    always_comb begin
        // Fondo: gris oscuro (fondo del semáforo)
        red = 5'h08;
        green = 6'h08;
        blue = 5'h08;
        
        // ---- Caja del semáforo (rectángulo gris) ----
        if (x > CENTRO_X - 50 && x < CENTRO_X + 50 &&
            y > CENTRO_Y - 80 && y < CENTRO_Y + 80) begin
            red = 5'h0A;
            green = 6'h0A;
            blue = 5'h0A;
        end
        
        // ---- LUZ ROJA (círculo superior) ----
        // Calcular distancia al centro de la luz roja
        if ((x - CENTRO_X)*(x - CENTRO_X) + (y - ROJO_Y)*(y - ROJO_Y) < RADIO*RADIO) begin
            if (estado == 2'b00) begin
                // ROJO encendido
                red = 5'h1F;    // Rojo máximo
                green = 6'h00;
                blue = 5'h00;
            end
            else begin
                // ROJO apagado (rojo oscuro)
                red = 5'h04;
                green = 6'h00;
                blue = 5'h00;
            end
        end
        
        // ---- LUZ AMARILLA (círculo central) ----
        if ((x - CENTRO_X)*(x - CENTRO_X) + (y - AMARILLO_Y)*(y - AMARILLO_Y) < RADIO*RADIO) begin
            if (estado == 2'b10) begin
                // AMARILLO encendido
                red = 5'h1F;
                green = 6'h3F;  // Verde + Rojo = Amarillo
                blue = 5'h00;
            end
            else begin
                // AMARILLO apagado
                red = 5'h04;
                green = 6'h04;
                blue = 5'h00;
            end
        end
        
        // ---- LUZ VERDE (círculo inferior) ----
        if ((x - CENTRO_X)*(x - CENTRO_X) + (y - VERDE_Y)*(y - VERDE_Y) < RADIO*RADIO) begin
            if (estado == 2'b01) begin
                // VERDE encendido
                red = 5'h00;
                green = 6'h3F;  // Verde máximo
                blue = 5'h00;
            end
            else begin
                // VERDE apagado
                red = 5'h00;
                green = 6'h04;
                blue = 5'h00;
            end
        end
        
        // ---- Marco del semáforo (borde negro) ----
        if ((x == CENTRO_X - 50 || x == CENTRO_X + 50) && 
            y > CENTRO_Y - 80 && y < CENTRO_Y + 80) begin
            red = 5'h00;
            green = 6'h00;
            blue = 5'h00;
        end
        
        if ((y == CENTRO_Y - 80 || y == CENTRO_Y + 80) && 
            x > CENTRO_X - 50 && x < CENTRO_X + 50) begin
            red = 5'h00;
            green = 6'h00;
            blue = 5'h00;
        end
    end

endmodule