
.PHONY: clean test_sram

test_sram: config_sram_data_tb_top.gcd

%.gcd: ./src/sim/%.v
	iverilog $< && vvp a.out

clean:
	rm -f *.gcd a.out