module shift_bit (
    input clk,
    input rst,

    input shift_enable,

    input shift_in,
    output shift_out
);
    reg bit;
    assign shift_out = bit;

    always @(posedge clk) begin
        if (rst == 1'b0) begin
            if (shift_enable == 1'b1) begin
                bit <= shift_in;
            end else begin
                bit <= bit;
            end
        end
        else data <= 1'b0;
    end
endmodule

module shift_chain #(
    parameter LENGTH = 8
) (
    input clk,
    input rst,

    input shift_enable,
    
    input shift_in,
    output shift_out,

    output [LENGTH-1:0] config_data
);
    wire [LENGTH-1:0] intermediate;

    assign config_data = intermediate;

    genvar i;
    generate
        if (LENGTH == 0) assign shift_out = shift_in;
        if (LENGTH >= 1) begin
            shift_bit head_bit (
                .clk(clk),
                .rst(rst),
                .shift_enable(shift_enable),
                .shift_in(shift_in),
                .shift_out(intermediate[0])
            );
            assign shift_out = intermediate[LENGTH - 1];
        end
        if (length > 1) begin
            for (genvar i = 1; i < LENGTH; i = i + 1) begin
                shift_bit shift_bit_i (
                    .clk(clk),
                    .rst(rst),
                    .shift_enable(shift_enable),
                    .shift_in(intermediate[i - 1]),
                    .shift_out(intermediate[i])
                );
            end
        end
    endgenerate
endmodule