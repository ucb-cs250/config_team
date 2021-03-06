# Design
set ::env(DESIGN_NAME) "config_sram_data"

set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/config_team/src/behavioral/*.v]

set ::env(CLOCK_PERIOD) "1.0"
set ::env(CLOCK_PORT) "cclk"

set ::env(RUN_MAGIC) 1
set ::env(RUN_ROUTING_DETAILED) 1

set ::env(CLOCK_NET) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

# set ::env(FP_PIN_ORDER_CFG) $::env(OPENLANE_ROOT)/designs/config_tile/pin_order.cfg

set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
