// Práctica 8: Semáforo con LEDs (Máquina de Estados)
// Concepto: Modelar una Máquina de Estados Finitos (FSM) de un semáforo utilizando enumeraciones
//           y contadores de tiempo en SystemVerilog.

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

    // Apagar todo lo que no usamos
    assign abcdefgh = 8'h00;
    assign digit = 8'h00;
    assign red = 5'h00;
    assign green = 6'h00;
    assign blue = 5'h00;
    assign gpio = 4'bzzzz;
    assign uart_tx = 1'b1;

    // -------------------------------------------------
    // MÁQUINA DE ESTADOS FINITOS (FSM)
    // -------------------------------------------------
    // Usamos 'typedef enum' para que el código sea auto-documentado y legible
    // en lugar de usar números mágicos binarios.
    typedef enum logic [1:0] {
        ROJO            = 2'b00,
        ROJO_AMARILLO   = 2'b01,
        VERDE           = 2'b10,
        AMARILLO        = 2'b11
    } estado_t;

    estado_t estado;
    logic [7:0] tiempo; // Contador de segundos
    
    // Lógica secuencial de la FSM
    always_ff @(posedge slow_clock or posedge reset) begin
        if (reset) begin
            estado <= ROJO;
            tiempo <= 8'd5;       // Permanecer 5 segundos en Rojo al inicio
        end
        else begin
            // Decrementar el contador en cada segundo (cada ciclo de slow_clock)
            if (tiempo > 0) begin
                tiempo <= tiempo - 8'd1;
            end
            
            // Transición de estado cuando el tiempo se agota
            if (tiempo == 8'd0) begin
                case (estado)
                    ROJO: begin
                        estado <= ROJO_AMARILLO;
                        tiempo <= 8'd2;   // 2 segundos
                    end
                    
                    ROJO_AMARILLO: begin
                        estado <= VERDE;
                        tiempo <= 8'd4;   // 4 segundos
                    end
                    
                    VERDE: begin
                        estado <= AMARILLO;
                        tiempo <= 8'd2;   // 2 segundos
                    end
                    
                    AMARILLO: begin
                        estado <= ROJO;
                        tiempo <= 8'd5;   // 5 segundos
                    end
                    
                    default: begin
                        estado <= ROJO;
                        tiempo <= 8'd5;
                    end
                endcase
            end
        end
    end
    
    // -------------------------------------------------
    // LÓGICA DE SALIDA COMBINACIONAL (Mapear estados a LEDs)
    // -------------------------------------------------
    always_comb begin
        // Valores por defecto (apagar LEDs no usados)
        led = 8'b00000000;
        
        case (estado)
            ROJO: begin
                led[0] = 1'b1; // led[0] = Rojo
            end
            ROJO_AMARILLO: begin
                led[0] = 1'b1; // Rojo
                led[1] = 1'b1; // Amarillo
            end
            VERDE: begin
                led[2] = 1'b1; // led[2] = Verde
            end
            AMARILLO: begin
                led[1] = 1'b1; // led[1] = Amarillo
            end
        endcase
    end

endmodule