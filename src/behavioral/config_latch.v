// Synchronous flip-flop with enable for storing config data, may eventually be turned into an async latch

module config_latch #(
    parameter LENGTH = 8
) (
    input clk,
    input rst,
    input set,

    input [LENGTH-1:0] shifter_data,
    output [LENGTH-1:0] config_bits
);

    genvar i;
    for (i = 0; i < LENGTH; i = i + 1) begin
        `ifdef USE_NEGLATCH
            neglatch neglatch(.clk(clk), .d(shifter_data[i]), .rst(rst), .q(config_bits[i]));
        `else
            poslatch poslatch(.clk(clk), .d(shifter_data[i]), .rst(rst), .q(config_bits[i]));
        `endif
    end
endmodule

module poslatch #(
    input clk,
    input d,
    input rst,
    
    output q
);
    always @(posedge clk, rst) begin
        if (rst == 1) begin
            q <= 1'b0;
        end
        else begin
            q <= d;
        end
    end
endmodule

module neglatch #(
    input clk,
    input d,
    input rst,
    
    output q
);
    always @(negedge clk, rst) begin
        if (rst == 1) begin
            q <= 1'b0;
        end
        else begin
            q <= d;
        end
    end
endmodule
