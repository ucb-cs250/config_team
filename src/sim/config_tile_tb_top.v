`timescale 1ns/1ps

module config_tile_tb_top;

  reg clk, set_soft, set_hard, shift_in_hard, shift_in_soft, rst;
  wire shift_out;
  wire [4:0] cconfig;
  reg [4:0] prev_stored_comb;
  wire [6:0] mconfig;
  reg [6:0] prev_stored_mem;

  wire [13:0] test_sequence = 56'b10101011010000111111110100101010001110011001010100010101;
  config_tile DUT(
    .clk(clk), 
    .comb_config(cconfig), 
    .mem_config(mconfig), 
    .set_soft(set_soft), 
    .set_hard(set_hard), 
    .shift_in_hard(shift_in_hard), 
    .shift_in_soft(shift_in_soft), 
    .shift_out(shift_out), 
    .rst(rst)
  );

  initial clk = 0;
  initial rst = 1;

  always #4 clk = ~clk;

  integer i;
  integer j;


  initial begin
    $dumpfile("tile_config_tb.vcd");
    $dumpvars;
    set_soft = 1; 
    set_hard = 1;
    shift_in_hard = 0;
    shift_in_soft = 0;
    #16;
    rst = 0;
    set_soft <= 0;
    set_hard <= 0;
    for (i = 0; i < 7; i = i + 1) begin //Load bits into comb shift register
      shift_in_soft <= test_sequence[i];
      if ((cconfig != 0) || (mconfig != 0) || (shift_out != 0)) begin
        $display("Mismatches when loading comb test_sequence bit %d nonzero shift_out=%b comb_config=%h, mem_config=%h", i, shift_out, cconfig, mconfig);
      end
      #8;
    end

    for (i = 7; i < 14; i = i + 1) begin //Test shift_out from comb shift register
      shift_in_soft <= test_sequence[i];
      if ((cconfig != 0) || (mconfig != 0)) begin
        $display("Mismatches when loading test_sequence nonzero comb_config=%h, mem_config=%h", cconfig, mconfig);
      end
      if (shift_out != test_sequence[i-7]) begin
        $display("Mismatches at bit %d where shift_out=%b when it should be %b", i-7, shift_out, test_sequence[i-7]);
      end
      #8;
    end

    set_soft <= 1;

    for (i = 14; i < 21; i = i + 1) begin //Load bits into mem shift register
      prev_stored_comb <= cconfig;
      shift_in_soft <= test_sequence[i];
      if ((cconfig != prev_stored_comb) || (mconfig != 0) || (shift_out != 0)) begin
        $display("Mismatches when loading mem test_sequence bit %d nonzero shift_out=%b or mem_config=%h or changed comb_config=%h instead of %h", i-14, shift_out, mconfig, cconfig, prev_stored_comb);
      end
      #8;
      set_soft <= 0;
    end

    for (i = 21; i < 28; i = i + 1) begin //Test shift_out from mem shift register
      shift_in_soft <= test_sequence[i];
      if ((cconfig != prev_stored_comb) || (mconfig != 0)) begin
        $display("Mismatches when loading test_sequence changed comb_config=%h instead of %h or nonzero mem_config=%h", cconfig, prev_stored_comb, mconfig);
      end
      if (shift_out != test_sequence[i-14]) begin
        $display("Mismatches at bit %d where shift_out=%b when it should be %b", i-14, shift_out, test_sequence[i-14]);
      end
      set_soft = 1;
      #8;
    end

    prev_stored_comb <= cconfig;
    prev_stored_mem <= mconfig;
    set_soft <= 0;

    for (i = 28; i < 35; i = i + 1) begin //Load bits into comb shift register
      shift_in_soft <= test_sequence[i];
      if ((cconfig != prev_stored_comb) || (mconfig != prev_stored_mem) || (shift_out != 0)) begin
        $display("Mismatches when loading comb test_sequence bit %d nonzero shift_out=%b comb_config=%h, mem_config=%h", i, shift_out, cconfig, mconfig);
      end
      #8;
    end

    for (i = 35; i < 42; i = i + 1) begin //Test shift_out from comb shift register
      shift_in_soft <= test_sequence[i];
      if ((cconfig != 0) || (mconfig != 0)) begin
        $display("Mismatches when loading test_sequence nonzero comb_config=%h, mem_config=%h", cconfig, mconfig);
      end
      if (shift_out != test_sequence[i-7]) begin
        $display("Mismatches at bit %d where shift_out=%b when it should be %b", i-7, shift_out, test_sequence[i-7]);
      end
      #8;
    end

    set_hard <= 1;

    for (i = 42; i < 49; i = i + 1) begin //Load bits into mem shift register
      prev_stored_comb <= cconfig;
      shift_in_soft <= test_sequence[i];
      if ((cconfig != prev_stored_comb) || (mconfig != 0) || (shift_out != 0)) begin
        $display("Mismatches when loading mem test_sequence bit %d nonzero shift_out=%b or mem_config=%h or changed comb_config=%h instead of %h", i-14, shift_out, mconfig, cconfig, prev_stored_comb);
      end
      #8;
      set_hard <= 0;
    end

    for (i = 49; i < 56; i = i + 1) begin //Test shift_out from mem shift register
      shift_in_soft <= test_sequence[i];
      if ((cconfig != prev_stored_comb) || (mconfig != 0)) begin
        $display("Mismatches when loading test_sequence changed comb_config=%h instead of %h or nonzero mem_config=%h", cconfig, prev_stored_comb, mconfig);
      end
      if (shift_out != test_sequence[i-14]) begin
        $display("Mismatches at bit %d where shift_out=%b when it should be %b", i-14, shift_out, test_sequence[i-14]);
      end
      #8;
    end


    $finish;
  end
endmodule

