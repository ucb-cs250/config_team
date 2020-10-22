`include "./src/behavioral/shift_chain.v"

module config_sram_data #(
    parameter ADDR_BITS = 8,
    parameter DATA_BITS = 8
) (
    input cclk,
    input rst,

    input config_set,
    input shift_enable,

    input shift_in,
    output shift_out,

    output write_enable,
    output [ADDR_BITS-1:0] write_address,
    output [DATA_BITS-1:0] write_data
);
    wire bridge;
    shift_chain #(.LENGTH(ADDR_BITS)) address_shifter (
        .clk(cclk),
        .rst(rst),
        .shift_enable(shift_enable),
        .shift_in(shift_in),
        .shift_out(bridge),
        .config_data(write_address)
    );
    shift_chain #(.LENGTH(DATA_BITS)) data_shifter (
        .clk(cclk),
        .rst(rst),
        .shift_enable(shift_enable),
        .shift_in(bridge),
        .shift_out(shift_out),
        .config_data(write_data)
    );

    assign write_enable = config_set;
endmodule