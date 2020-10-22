# Config Team

The config team is building a set of modules to enable the initilization of the device, and to enable dynamic reconfiguration of the device. Behavioral verilog modules are stored in `src/verilog` with testbenches for each in `sim/`. (Hopefully) Up to date diagrams of each module are stored in the `docs/` folder, in both svg and xcircuit Postscript files.

## Tile Config

The config_tile module holds the configuration bits for every configurable option in a given tile (excluding SRAM bits). The `config_tile` module is designed to be fed from either a hardwired shift chain that spans a column of tiles, or from the fabric, allowing for arbitrarily granular dynamic reconfiguration of tiles.

### Notional Startup and Configuration

1. After a reset the on-chip RISC-V core would feed in a full bitstream of configuration to each column and then deassert a global `shift_enable` signal to freeze the bitstream in place in the chain.
2. The RISC-V cores can then assert the `set` signal on each column which will load the bits into their respective configuration latches
3. On selective tiles destined for dynamic reconfiguration, the first config bit in each tile would be set, this would switch the muxes attached to the `shift_in` and `set` inputs away from the hardwired column inputs, and to inputs that come from the regular device interconnect.
4. Some softcore built into the fabric can then feed new configuration data into the tile at anytime to change its behavior.

## SRAM Data Config

The `config_sram_data` module performs boot-time initilization of the SRAM Blocks with contents, and resides within every SRAM Block tile.

Each block has a shift register with an address segment followed by a data segment. Each segment feeds the appropriate signal of the write port on the SRAM Block. When the `set` signal of the `config_sram_data` module is asserted, the module asserts the `write_enable` signal on its associated SRAM Block which writes the data contained in the shift register at the appropriate address. In order to configure a column, every `config_sram_data` module in a column is linked end to end to create one long shift register. The RISC-V pump in address-data pairs and assert the `set` signal to load data into the every SRAM block.