module rom_image
#(
    parameter ADDR_WIDTH  = 14, // 2^14 = 16384 (suficiente para 120x120 = 14400 pixeles)
    parameter WIDTH       = 120,
    parameter HEIGHT      = 120,
    parameter IMAGE_PATH  = "image.mem"
)
(
    input clk, 
    input [(ADDR_WIDTH - 1):0] x,
    input [(ADDR_WIDTH - 1):0] y,
    output reg [15:0] pixel
);

    reg [(ADDR_WIDTH - 1):0] addr;
    reg [15:0] rom[0:(WIDTH * HEIGHT - 1)]; /* synthesis syn_romstyle = "block_rom" */;

    initial begin
        $readmemh({"/home/jerry/Escritorio/FPGA_Principiantes/PRACTICAS/PRACTICA17/", IMAGE_PATH}, rom);
    end

    assign addr = (y * WIDTH) + x;

    always @ (posedge clk) begin
        pixel <= rom[addr];
    end

endmodule
