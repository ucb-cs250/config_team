`include "REGISTER.v"
module config_tile #(
  parameter comb_N = 7,
  parameter mem_N = 7
  
) (
  input clk,
  input rst,
  
  output [comb_N-3:0] comb_config,
  output [mem_N-1:0] mem_config,
  
  input set_soft,
  input set_hard,
  input shift_in_hard,
  input shift_in_soft,
    
  output shift_out
);
  
  wire shift_en;
  wire set_config = shift_en ? comb_shift_out[0] : set_config;
  assign shift_en = set_config ? set_soft : set_hard;
  wire shift_in = set_config ? shift_in_soft : shift_in_hard;
  
  wire [comb_N-1:0] comb_shift_out;
  wire mem_config_en = shift_en ? comb_shift_out[1] : mem_config_en;
  wire [comb_N-3:0] stored_comb = shift_en ? comb_shift_out[comb_N-1:2] : stored_comb;
  wire [comb_N-1:0] comb_shift_in = {comb_shift_out[comb_N - 2:0], shift_in};
  
  REGISTER #(.N(comb_N)) comb_shift (
    .q(comb_shift_out),
    .d(comb_shift_in),
    .clk(clk),
    .rst(rst)
  );
  
  wire mem_clk = mem_config_en && clk;
  wire [mem_N-1:0] mem_shift_out;
  wire [mem_N-1:0] stored_mem = shift_en ? mem_shift_out[mem_N-1:0] : stored_mem;
  wire [mem_N-1:0] mem_shift_in = {mem_shift_out[mem_N - 2:0], shift_in};
  
  REGISTER #(.N(mem_N)) mem_shift (
    .q(mem_shift_out),
    .d(mem_shift_in),
    .clk(mem_clk),
    .rst(rst)
  );
  
  wire shift_out_final = !mem_config_en ? stored_comb[comb_N - 3] : stored_mem[mem_N - 1];
  
  assign shift_out = shift_out_final;
  
endmodule
