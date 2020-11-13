`timescale 1ns/1ps

`include "./src/behavioral/config_tile.v"
`include "./src/behavioral/config_latch.v"
`include "./src/behavioral/shift_chain.v"

module config_tile_tb_top;

  reg clk, set_soft, set_hard, shift_in_hard, shift_in_soft, rst, shift_enable;
  wire shift_out, comb_set, mem_set;
  wire [4:0] cconfig;
  wire [4:0] cconfig_stored;
  reg [4:0] prev_stored_comb;
  wire [4:0] mconfig;
  wire [4:0] mconfig_stored;
  reg [4:0] prev_stored_mem;

  wire [12:0] test_sequence_hard = 12'b00_11000_00111; // {input_mux, mem_ctrl}_{comb}_{mem}
  wire [12:0] test_sequence_soft = 12'b10_00111_11100;
  wire [12:0] test_sequence_memd = 12'b11_01010_10101;
  wire [12:0] test_sequence_last = 12'b11_10101_01010;

  config_tile #(.COMB_N(5), .MEM_N(5)) DUT(
    .clk(clk),
    .comb_config(cconfig),
    .mem_config(mconfig),
    .set_soft(set_soft),
    .set_hard(set_hard),
    .shift_in_hard(shift_in_hard),
    .shift_in_soft(shift_in_soft),
    .shift_out(shift_out),
    .rst(rst),
    .shift_enable(shift_enable),
    .comb_set(comb_set),
    .mem_set(mem_set)
  );

  config_latch #(.LENGTH(5)) comb_store(
    .clk(clk),
    .rst(rst),
    .set(comb_set),
    .shifter_data(cconfig),
    .config_bits(cconfig_stored)
  );

  config_latch #(.LENGTH(5)) mem_store(
    .clk(clk),
    .rst(rst),
    .set(mem_set),
    .shifter_data(mconfig),
    .config_bits(mconfig_stored)
  );

  initial clk = 0;
  initial rst = 1;
  initial shift_enable = 0;

  always #4 clk = ~clk;

  integer i;
  integer j;


  initial begin
    $dumpfile("tile_config_tb.vcd");
    $dumpvars;
    set_soft <= 1; 
    set_hard <= 1;
    shift_in_hard <= 0;
    shift_in_soft <= 0;
    #16;
    rst <= 0;
    set_soft <= 0;
    set_hard <= 0;

    // Test hard wired input on reset
    shift_enable <= 1;
    for (i = 0; i < 12; i = i + 1) begin
      shift_in_hard <= test_sequence_hard[i];
      #8;
    end
    shift_enable <= 0;
    set_hard <= 1;
    #8;
    set_hard <= 0;
    if (cconfig_stored !== test_sequence_hard[9:5]) begin
      $display("Mismatch between combinatorial output, and input bits: comb %h, input %h", cconfig, test_sequence_hard[9:5]);
    end
    if (mconfig_stored !== test_sequence_hard[4:0]) begin
      $display("Mismatch between memory output, and input bits: mem %h, input %h", mconfig, test_sequence_hard[4:0]);
    end
    #16;

    // Switch to soft chain
    shift_enable <= 1;
    for (i = 0; i < 12; i = i + 1) begin
      shift_in_hard <= test_sequence_soft[i];
      #8;
    end
    shift_enable <= 0;
    set_soft <= 1;
    set_hard <= 1;
    #8;
    set_soft <= 0;
    set_hard <= 0;
    if (cconfig_stored !== test_sequence_soft[9:5]) begin
      $display("Mismatch between combinatorial output, and input bits: comb %h, input %h", cconfig, test_sequence_soft[9:5]);
    end
    if (mconfig_stored !== test_sequence_soft[4:0]) begin
      $display("Mismatch between memory output, and input bits: mem %h, input %h", mconfig, test_sequence_soft[4:0]);
    end
    #16;

    // Disable memory setting
    shift_enable <= 1;
    for (i = 0; i < 12; i = i + 1) begin
      shift_in_soft <= test_sequence_memd[i];
      #8;
    end
    shift_enable <= 0;
    set_soft <= 1;
    #8;
    set_soft <= 0;
    if (cconfig_stored !== test_sequence_memd[9:5]) begin
      $display("Mismatch between combinatorial output, and input bits: comb %h, input %h", cconfig, test_sequence_memd[9:5]);
    end
    if (mconfig_stored !== test_sequence_memd[4:0]) begin
      $display("Mismatch between memory output, and input bits: mem %h, input %h", mconfig, test_sequence_memd[4:0]);
    end
    #16;

    // Test memory disablement
    shift_enable <= 1;
    for (i = 0; i < 12; i = i + 1) begin
      shift_in_soft <= test_sequence_last[i];
      #8;
    end
    shift_enable <= 0;
    set_soft <= 1;
    #8;
    set_soft <= 0;
    if (cconfig_stored !== test_sequence_last[9:5]) begin
      $display("Mismatch between combinatorial output, and input bits: comb %h, input %h", cconfig, test_sequence_last[9:5]);
    end
    if (mconfig_stored !== test_sequence_memd[4:0]) begin
      $display("Mismatch between memory output, and old bits: mem %h, input %h", mconfig, test_sequence_memd[4:0]);
    end
    #16

    $finish;
  end
endmodule

