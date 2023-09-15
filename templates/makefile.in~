# defaults
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

VHDL_SOURCES += $(PWD)/../vhdl/hdl/blockram.vhdl $(PWD)/../vhdl/hdl/bram_std_fifo.vhdl
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = bram_std_fifo

# MODULE is the basename of the Python test file
MODULE = test_bram_std_fifo

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
