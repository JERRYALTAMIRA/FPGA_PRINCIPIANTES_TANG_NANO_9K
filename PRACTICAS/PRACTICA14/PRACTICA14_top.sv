// Práctica 14: Radar / Sensor de distancia ultrasónico
// Concepto: Integrar un sensor de distancia ultrasónico (HC-SR04) y mostrar el valor de la distancia
//           convertida a centímetros reales en el display de 7 segmentos, activando un LED de alerta.

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
    // NOTA: ¡No apagues abcdefgh ni digit aquí! Son manejados por el módulo seven_segment_display más abajo.
    // Poner un assign concurrente a cero generaría un error de compilación (Múltiple Driver).
    assign red = 5'h00;
    assign green = 6'h00;
    assign blue = 5'h00;
    assign uart_tx = 1'b1; // UART inactivo
    
    // Los GPIO se manejan según el sensor
    assign gpio[3:2] = 2'bzz;

    // =================================================
    // 2. SENSOR ULTRASÓNICO
    // =================================================
    wire [15:0] distance; // 16 bits de ancho para almacenar la cuenta
    
    ultrasonic_distance_sensor
    # (
        .clk_frequency           ( 27 * 1000 * 1000 ),
        .relative_distance_width ( 16 ) // Corregido de 15 a 16 para que coincida con el ancho del cable
    )
    i_sensor
    (
        .clk               ( clock    ),
        .rst               ( reset    ),
        .trig              ( gpio[0]  ),
        .echo              ( gpio[1]  ),
        .relative_distance ( distance )
    );

    // =================================================
    // 3. CONVERSIÓN A CENTÍMETROS REALES
    // =================================================
    // A la frecuencia de 27 MHz:
    // ciclos_por_cm = (27,000,000 Hz * 2 (ida y vuelta del sonido)) / (343 m/s * 100 cm/m) ≈ 1574 ciclos/cm.
    // Dado que el sensor nos devuelve 'distance' que equivale a (echo_cnt / 16) debido al escalado interno,
    // la conversión a centímetros es:
    // distancia_cm = (distance * 16) / 1574 = distance / 98.375.
    // Aproximamos dividiendo entre 98.
    logic [15:0] distance_cm;
    assign distance_cm = distance / 16'd98;

    // =================================================
    // 4. MOSTRAR DISTANCIA EN DISPLAY 7 SEGMENTOS
    // =================================================
    seven_segment_display
    # (.w_digit (8))
    i_7segment
    (
        .clk      ( clock               ),
        .rst      ( reset               ),
        .number   ( 32'(distance_cm)    ), // Muestra la distancia en centímetros reales
        .dots     ( 8'b00000000         ),
        .abcdefgh ( abcdefgh            ), // Único driver de los segmentos
        .digit    ( digit               )  // Único driver de la habilitación de dígitos
    );

    // =================================================
    // 5. LEDs INDICADORES (Alerta de proximidad)
    // =================================================
    always_comb begin
        // Por defecto todos los LEDs apagados
        led = 8'b00000000;
        
        // Alerta si la distancia medida en cm es inferior a 30 cm
        if (distance_cm < 16'd30) begin
            led[0] = 1'b1; // Enciende LED 0 si está muy cerca
        end
    end

endmodule