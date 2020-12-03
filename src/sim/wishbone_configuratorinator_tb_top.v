`timescale 1ns/1ps

`include "./src/behavioral/wishbone_configuratorinator.v"

module wishbone_configuratorinator_tb_top;
    reg clk = 0;
    reg rst = 1;

    reg [31:0] address = 32'h3000_0000;
    reg [31:0] write_data = 0;
    reg transact = 0;
    reg we = 0;
    reg [3:0] select = 4'b1111;

    wire ack;
    wire [31:0] read_data;

    wire cen;
    wire [3:0] shift;
    wire [3:0] set;

    wishbone_configuratorinator confthing (
        .wb_clk_i(clk),
        .wb_rst_i(rst),
        .wbs_stb_i(transact),
        .wbs_cyc_i(transact),
        .wbs_we_i(we),
        .wbs_sel_i(select),
        .wbs_data_i(write_data),
        .wbs_addr_i(address),
        .wbs_ack_o(ack),
        .wbs_data_o(read_data),
        .cen(cen),
        .shift_out(shift),
        .set_out(set)
    );

    always #5 clk = ~clk;
    always #20 rst = 0;

    initial begin
        $dumpfile("wishbone_configuratorinator_tb_top.gcd");
        $dumpvars;

        repeat(5) @(posedge clk);


        address <= 32'h3000_0001;
        write_data <= {8'h03, 8'h04, 8'h05, 8'hFF};
        we <= 1;
        transact <= 1;

        @(posedge ack);
        transact <= 0;
        we <= 0;
        @(negedge ack);

        repeat(5) @(posedge clk);

        address <= 32'h3000_0002;
        write_data <= {8'b00001111, 8'b10101010, 8'b01010101, 8'b11110000};
        we <= 1;
        transact <= 1;

        @(posedge ack);
        transact <= 0;
        we <= 0;
        @(negedge ack);
        
        repeat(5) @(posedge clk);

        address <= 32'h3000_0002;
        write_data <= {8'b11110000, 8'b01010101, 8'b10101010, 8'b00001111};
        we <= 1;
        transact <= 1;

        @(posedge ack);
        transact <= 0;
        we <= 0;
        @(negedge ack);

        repeat(5) @(posedge clk);

        address <= 32'h3000_0000;
        write_data <= 1;
        we <= 1;
        transact <= 1;

        @(posedge ack);
        transact <= 0;
        we <= 0;
        @(negedge ack);

        repeat(5) @(posedge clk);

        $finish;
    end
endmodule