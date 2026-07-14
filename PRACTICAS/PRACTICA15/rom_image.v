module rom_image
#(
    parameter ADDR_WIDTH  = 15,
    parameter WIDTH       = 480,
    parameter HEIGHT      = 270,
    parameter IMAGE_PATH  = "image.mem"
)
(
    input clk, 
    input [8:0] x,
    input [8:0] y,
    output reg pixel
);

    wire [(ADDR_WIDTH - 1):0] addr;
    reg [7:0] rom[0:((WIDTH * HEIGHT / 8) - 1)]; /* synthesis syn_romstyle = "block_rom" */;

    initial begin
        $readmemh({"/home/jerry/Escritorio/FPGA_Principiantes/PRACTICAS/PRACTICA16/", IMAGE_PATH}, rom);
    end

    // Cada fila tiene 480 pixeles = 60 bytes.
    // x / 8 nos da el byte correspondiente en la fila.
    assign addr = (y * 60) + (x[8:3]);

    always @ (posedge clk) begin
        // np.packbits empaca el bit más significativo (x=0) en el bit 7 del byte
        pixel <= rom[addr][7 - x[2:0]];
    end

endmodule
