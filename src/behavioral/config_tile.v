`include "REGISTER.v"
module config_tile #(
  parameter comb_N = 7,
  parameter mem_N = 7
  
) (
input clk,
  input rst,
  
  output reg [comb_N-3:0] comb_config,
  output reg [mem_N-1:0] mem_config,
  
  input set_soft,
  input set_hard,
  input shift_in_hard,
  input shift_in_soft,
    
  output shift_out
);
  
  initial comb_config = 0;
  initial mem_config = 0;
  
  wire shift_en, set_config, mem_config_en;
  wire [comb_N-1:0] comb_shift_out;
  wire set_config_in = shift_en ? comb_shift_out[0] : set_config;
  assign shift_en = set_config ? set_hard : set_soft;
  
  REGISTER #(.N(1)) set_config_reg (
    .q(set_config_in),
    .d(set_config),
    .clk(clk),
    .rst(rst)
  );
  
  wire shift_in = set_config ? shift_in_hard : shift_in_soft;
  wire mem_config_en_in = shift_en ? comb_shift_out[1] : mem_config_en;
  
  REGISTER #(.N(1)) mem_config_en_reg (
    .q(mem_config_en_in),
    .d(mem_config_en),
    .clk(clk),
    .rst(rst)
  );
  
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
  wire [mem_N-1:0] mem_shift_in = {mem_shift_out[mem_N - 2:0], stored_comb[comb_N - 3]};
  
  REGISTER #(.N(mem_N)) mem_shift (
    .q(mem_shift_out),
    .d(mem_shift_in),
    .clk(mem_clk),
    .rst(rst)
  );
  
  wire shift_out_final = mem_config_en ? mem_shift_out[mem_N - 1] : comb_shift_out[comb_N - 1];
  
  assign shift_out = shift_out_final;
endmodule
