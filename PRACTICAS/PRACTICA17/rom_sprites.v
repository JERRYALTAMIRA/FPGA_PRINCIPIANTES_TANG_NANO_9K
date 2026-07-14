module rom_sprites
#(
    parameter ADDR_WIDTH  = 16,
    parameter WIDTH       = 120,
    parameter HEIGHT      = 104,
    parameter FRAMES      = 8,
    parameter IMAGE_PATH  = "sprites_color.mem"
)
(
    input clk, 
    input [6:0] x, // 0 to 119
    input [6:0] y, // 0 to 103
    input [3:0] frame, // 0 to 7
    output reg [2:0] pixel
);

    wire [(ADDR_WIDTH - 1):0] addr;
    // 60 bytes por fila (120 px / 2), 104 filas, 8 frames = 49920 bytes
    reg [7:0] rom[0:(60 * HEIGHT * FRAMES - 1)]; /* synthesis syn_romstyle = "block_rom" */;

    initial begin
        $readmemh({"/home/jerry/Escritorio/FPGA_Principiantes/PRACTICAS/PRACTICA18/", IMAGE_PATH}, rom);
    end

    // x dividido entre 2 para obtener el byte
    wire [5:0] x_div2 = x[6:1];
    wire       x_odd  = x[0];

    // 60 bytes por fila, 104 filas = 6240 bytes por frame
    assign addr = (frame * 6240) + (y * 60) + x_div2;

    reg [7:0] rom_data;
    reg       x_odd_reg;

    always @ (posedge clk) begin
        rom_data  <= rom[addr];
        x_odd_reg <= x_odd;
    end

    always @ (*) begin
        if (!x_odd_reg)
            pixel = rom_data[5:3]; // Pixel par (primero)
        else
            pixel = rom_data[2:0]; // Pixel impar (segundo)
    end

endmodule
