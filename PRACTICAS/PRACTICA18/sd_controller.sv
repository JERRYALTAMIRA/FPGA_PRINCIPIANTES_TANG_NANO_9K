/* 
 * SD Card Controller in SystemVerilog (SPI Mode)
 * Dynamic high-speed reading capabilities for smooth video/image rendering.
 */

`timescale 1ns / 1ps

module sd_controller (
    // Physical SD Card interface (SPI)
    output logic       sd_cs,   // Connects to SD_DAT[3] / Chip Select
    output logic       sd_mosi, // Connects to SD_CMD / Master Out Slave In
    input  logic       sd_miso, // Connects to SD_DAT[0] / Master In Slave Out
    output logic       sd_sclk, // Connects to SD_SCK / Serial Clock

    // User/System Control Interface
    input  logic        clk,           // Master Clock (27 MHz)
    input  logic        clk_pulse_slow,// Clock pulse for startup/slow initialization (~400 KHz)
    input  logic        reset,         // Active high reset

    input  logic        rd,            // Start read block trigger
    input  logic [31:0] address,       // Sector block address
    output logic [7:0]  dout,          // Output byte data read from SD
    output logic        byte_available,// Pulses high for one cycle when dout is valid
    output logic        ready          // High when card is ready for commands
);

    // States
    typedef enum logic [4:0] {
        ST_RST               = 5'd0,
        ST_INIT              = 5'd1,
        ST_CMD0              = 5'd2,
        ST_CMD8              = 5'd3,
        ST_CMD55             = 5'd4,
        ST_CMD41             = 5'd5,
        ST_POLL_CMD          = 5'd6,
        ST_IDLE              = 5'd7,
        ST_READ_BLOCK        = 5'd8,
        ST_READ_BLOCK_WAIT   = 5'd9,
        ST_READ_BLOCK_DATA   = 5'd10,
        ST_READ_BLOCK_CRC    = 5'd11,
        ST_SEND_CMD          = 5'd12,
        ST_RECEIVE_BYTE_WAIT = 5'd13,
        ST_RECEIVE_BYTE      = 5'd14
    } state_t;

    state_t state = ST_RST;
    state_t return_state;

    logic        sclk_sig = 1'b0;
    logic [55:0] cmd_out = '1;
    logic        cmd_mode = 1'b1;
    logic [7:0]  data_sig = 8'hFF;
    logic [2:0]  response_type = 3'b1;
    logic [7:0]  recv_data;

    logic [9:0]  byte_counter;
    logic [9:0]  bit_counter;
    logic [26:0] boot_counter = 27'd50_000;
    logic [7:0]  reset_counter = 8'd0;

    // Generar pulso rápido para el modo de datos activo:
    // 27 MHz / 2 = 13.5 MHz para el SPI SCLK
    logic       fast_div = 1'b0;
    logic       clk_pulse_fast;

    always_ff @(posedge clk) begin
        fast_div <= ~fast_div;
    end
    assign clk_pulse_fast = fast_div;

    // Selección dinámica de la velocidad del reloj según el estado
    logic clk_pulse;
    assign clk_pulse = (state <= ST_POLL_CMD) ? clk_pulse_slow : clk_pulse_fast;

    always_ff @(posedge clk) begin
        if (reset) begin
            state               <= ST_RST;
            sclk_sig            <= 1'b0;
            boot_counter        <= 27'd5000;
            cmd_mode            <= 1'b1;
            sd_cs               <= 1'b1;
            cmd_out             <= '1;
            data_sig            <= 8'hFF;
            byte_available      <= 1'b0;
            if (clk_pulse_slow) begin
                reset_counter <= reset_counter + 1'b1;
                if (reset_counter[2]) sclk_sig <= ~sclk_sig;
            end
        end else begin
            if (clk_pulse) begin
                case (state)
                    ST_RST: begin
                        if (boot_counter == 0) begin
                            sclk_sig            <= 1'b0;
                            cmd_out             <= '1;
                            byte_counter        <= 10'd0;
                            byte_available      <= 1'b0;
                            cmd_mode            <= 1'b1;
                            bit_counter         <= 10'd160;
                            sd_cs               <= 1'b1;
                            state               <= ST_INIT;
                        end else begin
                            boot_counter <= boot_counter - 1'b1;
                            if (boot_counter[2]) sclk_sig <= ~sclk_sig;
                        end
                    end

                    ST_INIT: begin
                        if (bit_counter == 0) begin
                            sd_cs <= 1'b0;
                            state <= ST_CMD0;
                        end else begin
                            bit_counter <= bit_counter - 1'b1;
                            sclk_sig    <= ~sclk_sig;
                        end
                    end

                    ST_CMD0: begin
                        cmd_out       <= 56'hFF_40_00_00_00_00_95;
                        bit_counter   <= 10'd55;
                        response_type <= 3'b1;
                        return_state  <= ST_CMD8;
                        state         <= ST_SEND_CMD;
                    end

                    ST_CMD8: begin
                        cmd_out       <= 56'hFF_48_00_00_01_AA_87;
                        bit_counter   <= 10'd55;
                        response_type <= 3'b111;
                        return_state  <= ST_CMD55;
                        state         <= ST_SEND_CMD;
                    end

                    ST_CMD55: begin
                        cmd_out       <= 56'hFF_77_00_00_00_00_01;
                        bit_counter   <= 10'd55;
                        response_type <= 3'b1;
                        return_state  <= ST_CMD41;
                        state         <= ST_SEND_CMD;
                    end

                    ST_CMD41: begin
                        cmd_out       <= 56'hFF_69_40_00_00_00_01;
                        bit_counter   <= 10'd55;
                        response_type <= 3'b1;
                        return_state  <= ST_POLL_CMD;
                        state         <= ST_SEND_CMD;
                    end

                    ST_POLL_CMD: begin
                        if (recv_data[0] == 0) begin
                            state <= ST_IDLE;
                        end else begin
                            state <= ST_CMD55;
                        end
                    end

                    ST_IDLE: begin
                        if (rd) begin
                            state <= ST_READ_BLOCK;
                        end else begin
                            state <= ST_IDLE;
                        end
                    end

                    ST_READ_BLOCK: begin
                        cmd_out       <= {16'hFF_51, address, 8'hFF};
                        bit_counter   <= 10'd55;
                        response_type <= 3'b1;
                        return_state  <= ST_READ_BLOCK_WAIT;
                        state         <= ST_SEND_CMD;
                    end

                    ST_READ_BLOCK_WAIT: begin
                        if (sclk_sig == 1'b1 && sd_miso == 1'b0) begin
                            byte_counter <= 10'd511;
                            bit_counter  <= 10'd7;
                            return_state <= ST_READ_BLOCK_DATA;
                            state        <= ST_RECEIVE_BYTE;
                        end
                        sclk_sig <= ~sclk_sig;
                    end

                    ST_READ_BLOCK_DATA: begin
                        dout           <= recv_data;
                        byte_available <= 1'b1;
                        if (byte_counter == 0) begin
                            bit_counter  <= 10'd7;
                            return_state <= ST_READ_BLOCK_CRC;
                            state        <= ST_RECEIVE_BYTE;
                        end else begin
                            byte_counter <= byte_counter - 1'b1;
                            return_state <= ST_READ_BLOCK_DATA;
                            bit_counter  <= 10'd7;
                            state        <= ST_RECEIVE_BYTE;
                        end
                    end

                    ST_READ_BLOCK_CRC: begin
                        bit_counter  <= 10'd7;
                        return_state <= ST_IDLE;
                        state        <= ST_RECEIVE_BYTE;
                    end

                    ST_SEND_CMD: begin
                        if (sclk_sig == 1'b1) begin
                            if (bit_counter == 0) begin
                                state <= ST_RECEIVE_BYTE_WAIT;
                            end else begin
                                bit_counter <= bit_counter - 1'b1;
                                cmd_out     <= {cmd_out[54:0], 1'b1};
                            end
                        end
                        sclk_sig <= ~sclk_sig;
                    end

                    ST_RECEIVE_BYTE_WAIT: begin
                        if (sclk_sig == 1'b1) begin
                            if (sd_miso == 1'b0) begin
                                recv_data <= 8'd0;
                                case (response_type)
                                    3'b001:  bit_counter <= 10'd6;
                                    3'b111:  bit_counter <= 10'd38;
                                    default: bit_counter <= 10'd6;
                                endcase
                                state <= ST_RECEIVE_BYTE;
                            end
                        end
                        sclk_sig <= ~sclk_sig;
                    end

                    ST_RECEIVE_BYTE: begin
                        byte_available <= 1'b0;
                        if (sclk_sig == 1'b1) begin
                            recv_data <= {recv_data[6:0], sd_miso};
                            if (bit_counter == 0) begin
                                state <= return_state;
                            end else begin
                                bit_counter <= bit_counter - 1'b1;
                            end
                        end
                        sclk_sig <= ~sclk_sig;
                    end
                endcase
            end
        end
    end

    assign sd_sclk = sclk_sig;
    assign sd_mosi = cmd_mode ? cmd_out[55] : data_sig[7];
    assign ready   = (state == ST_IDLE);

endmodule
