module config_tile #(
    parameter COMB_N = 7,
    parameter MEM_N = 7
) (
    input clk,
    input rst,
    input shift_enable,

    output [COMB_N-1:0] comb_config,
    output [MEM_N-1:0] mem_config,
    output comb_set,
    output mem_set,

    input set_soft,
    input set_hard,
    input shift_in_hard,
    input shift_in_soft,

    output shift_out
);
    wire set_internal;
    wire shift_in_internal;

    wire mem_ctrl;
    wire input_mux;

    assign shift_in_internal = input_mux ? shift_in_soft : shift_in_hard;
    assign set_internal = input_mux ? set_soft : set_hard;

    assign mem_set = (~mem_ctrl) & set_internal;
    assign comb_set = set_internal;

    wire [1:0] internal_config_inter;

    config_latch #(.LENGTH(2)) internal_config (
        .clk(clk),
        .rst(rst),
        .set(set_internal),

        .shifter_data(internal_config_inter),
        .config_bits({mem_ctrl, input_mux})
    );

    wire comb_mem_bridge;

    shift_chain #(.LENGTH(COMB_N + 2)) comb_shifter (
        .clk(clk),
        .rst(rst),
        .shift_enable(shift_enable),
        .shift_in(shift_in_internal),
        .shift_out(comb_mem_bridge),
        .config_data({comb_config, internal_config_inter})
    );

    shift_chain #(.LENGTH(MEM_N)) mem_shifter (
        .clk(clk),
        .rst(rst),
        .shift_enable(shift_enable),
        .shift_in(comb_mem_bridge),
        .shift_out(shift_out),
        .config_data(mem_config)
    );
endmodule
