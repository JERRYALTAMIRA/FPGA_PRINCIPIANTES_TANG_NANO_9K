module character_rom (
    input  logic [7:0] ascii_code,
    output logic [7:0] segments
);

    // Mapeo de caracteres ASCII a segmentos de 7 segmentos
    // Formato: DP G F E D C B A
    always_comb begin
        case (ascii_code)
            // Letras mayúsculas
            8'h41: segments = 8'b11101110; // A
            8'h42: segments = 8'b00111110; // B
            8'h43: segments = 8'b10011100; // C
            8'h44: segments = 8'b01111010; // D
            8'h45: segments = 8'b10011110; // E
            8'h46: segments = 8'b10001110; // F
            8'h47: segments = 8'b10111100; // G
            8'h48: segments = 8'b01101110; // H
            8'h49: segments = 8'b00001100; // I
            8'h4A: segments = 8'b01111000; // J
            8'h4B: segments = 8'b10101110; // K
            8'h4C: segments = 8'b00011100; // L
            8'h4D: segments = 8'b10101010; // M
            8'h4E: segments = 8'b00101010; // N
            8'h4F: segments = 8'b11111100; // O
            8'h50: segments = 8'b11001110; // P
            8'h51: segments = 8'b11110110; // Q
            8'h52: segments = 8'b00001010; // R
            8'h53: segments = 8'b10110110; // S
            8'h54: segments = 8'b00011110; // T
            8'h55: segments = 8'b01111100; // U
            8'h56: segments = 8'b01010100; // V
            8'h57: segments = 8'b01010110; // W
            8'h58: segments = 8'b01010010; // X
            8'h59: segments = 8'b01110110; // Y
            8'h5A: segments = 8'b11011010; // Z
            
            // Números
            8'h30: segments = 8'b11111100; // 0
            8'h31: segments = 8'b01100000; // 1
            8'h32: segments = 8'b11011010; // 2
            8'h33: segments = 8'b11110010; // 3
            8'h34: segments = 8'b01100110; // 4
            8'h35: segments = 8'b10110110; // 5
            8'h36: segments = 8'b10111110; // 6
            8'h37: segments = 8'b11100000; // 7
            8'h38: segments = 8'b11111110; // 8
            8'h39: segments = 8'b11110110; // 9
            
            // Espacio y caracteres especiales
            8'h20: segments = 8'b00000000; // Space
            8'h2D: segments = 8'b00000010; // -
            8'h3D: segments = 8'b00010010; // =
            8'h5F: segments = 8'b00010000; // _
            
            default: segments = 8'b00000000; // Caracter no reconocido
        endcase
    end

endmodule