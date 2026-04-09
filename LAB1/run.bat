@echo off
iverilog -o bound_flasher_tb.vvp bound_flasher_tb.v
vvp bound_flasher_tb.vvp
gtkwave waves.vcd