// Práctica 7: Multiplexación de display de 7 segmentos
// Concepto: Mostrar un número de múltiples dígitos (0-255) utilizando persistencia de la visión (POV)
//           y gestionar los botones mediante un filtro antirrebote (debouncing).
// Práctica 7: Prueba de botones y contador (sin TM1638)
// Concepto: Verificar detección de flancos y funcionamiento del contador

// Práctica 7: Prueba de botones y contador (sin TM1638)
// Concepto: Verificar detección de flancos y funcionamiento del contador

module practicas_top
(
    input  logic       clock,       // Reloj de la placa (27 MHz)
    input  logic       slow_clock,  // Reloj lento (~100 Hz)
    input  logic       reset,       // Reset activo en alto

    input  logic [7:0] key,         // Botones
    output logic [7:0] led,         // LEDs (muestra el contador y estados)

    output logic [7:0] abcdefgh,    // Display 7 segmentos (no usado)
    output logic [7:0] digit,       // Display dígitos (no usado)

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
    assign red = 5'h00;
    assign green = 6'h00;
    assign blue = 5'h00;
    assign gpio = 4'bzzzz;
    assign uart_tx = 1'b1;
    assign abcdefgh = 8'b00000000;  // Display apagado
    assign digit = 8'b00000000;     // Display apagado

    // =================================================
    // 2. BOTONES Y CONTADOR - VERSIÓN DE PRUEBA
    // =================================================
    logic b0, b1;           // Estado actual de los botones
    logic b0_prev, b1_prev; // Estado anterior
    logic b0_press, b1_press; // Flanco de presión
    logic [7:0] counter;    // Contador de 0 a 255

    // Botones activos en bajo (0 = presionado, 1 = no presionado)
    assign b0 = key[0];
    assign b1 = key[1];

    // Detectar flanco de BAJADA (cuando se presiona: 1 → 0)
    always_ff @(posedge clock) begin
        b0_prev <= b0;
        b1_prev <= b1;
    end

    // Flanco de presión (1 cuando se acaba de presionar el botón)
    assign b0_press = (~b0) & b0_prev;   // b0 pasa de 1 a 0
    assign b1_press = (~b1) & b1_prev;   // b1 pasa de 1 a 0

    // =================================================
    // 3. CONTADOR PRINCIPAL
    // =================================================
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            counter <= 8'b00000000;
        end
        else begin
            // Botón 0: incrementa contador
            if (b0_press) begin
                counter <= counter + 1;
            end
            
            // Botón 1: resetea contador a 0
            if (b1_press) begin
                counter <= 0;
            end
        end
    end

    // =================================================
    // 4. LEDs DE DEPURACIÓN (MUY IMPORTANTE)
    // =================================================
    // LED0: estado del botón 0 (1=no presionado, 0=presionado)
    // LED1: estado del botón 1 (1=no presionado, 0=presionado)
    // LED2: flanco detectado en botón 0 (destello al presionar)
    // LED3: flanco detectado en botón 1 (destello al presionar)
    // LED4: bit 0 del contador
    // LED5: bit 1 del contador
    // LED6: bit 2 del contador
    // LED7: bit 3 del contador
    
    assign led[0] = b0;           // LED0 = estado botón 0 (1=no presionado, 0=presionado)
    assign led[1] = b1;           // LED1 = estado botón 1
    assign led[2] = b0_press;     // LED2 = flanco botón 0 (debe destellar al presionar)
    assign led[3] = b1_press;     // LED3 = flanco botón 1 (debe destellar al presionar)
    assign led[4] = counter[0];   // LED4 = bit 0 del contador
    assign led[5] = counter[1];   // LED5 = bit 1 del contador
    assign led[6] = counter[2];   // LED6 = bit 2 del contador
    assign led[7] = counter[3];   // LED7 = bit 3 del contador

endmodule