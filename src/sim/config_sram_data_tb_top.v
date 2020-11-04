`timescale 1ns/1ps

`include "./src/behavioral/config_sram_data.v"
`include "./src/behavioral/shift_chain.v"

module WOM8X255 (
    input clk,
    input [7:0] address,
    input [7:0] data,
    input write_enable
);
    reg [7:0] data_store [255:0];

    always @(posedge clk) begin
        if (write_enable == 1'b1) data_store[address] <= data;
    end
endmodule


module config_sram_data_tb_top;
    reg clk = 0;
    reg rst = 1;

    reg set = 0;
    reg shift_enable = 0;
    reg shift_in = 0;
    wire shift_out;

    wire [7:0] address;
    wire [7:0] data;
    wire wen;

    reg [7:0] counter = 0; 

    WOM8X255 data_store (
        .clk(clk),
        .address(address),
        .data(data),
        .write_enable(wen)
    );
    config_sram_data #(.ADDR_BITS(8), .DATA_BITS(8)) c_shifter (
        .cclk(clk),
        .rst(rst),
        .config_set(set),
        .shift_enable(shift_enable),
        .shift_in(shift_in),
        .shift_out(shift_out),
        .write_address(address),
        .write_data(data),
        .write_enable(wen)
    );

    always #5 clk = ~clk;
    always #5 rst = 0;

    integer i;
    integer j;


    initial begin
        $dumpfile("config_sram_data_tb_top.gcd");
        $dumpvars;
        #20;
        for (i = 0; i < 256; i = i + 1) begin
            shift_enable <= 1;
            for (j = 0; j < 8; j = j + 1) begin
                shift_in <= counter[7 - j];
                repeat(1) @(posedge clk);
            end
            for (j = 0; j < 8; j = j + 1) begin
                shift_in <= counter[7 - j];
                repeat(1) @(posedge clk);
            end
            shift_enable <= 0;
            repeat(1) @(posedge clk);
            set <= 1;
            repeat(1) @(posedge clk);
            set <= 0;
            repeat(1) @(posedge clk);
            counter <= counter + 1;
        end
        $finish;
    end
endmodule // config_sram_data_tb_top
