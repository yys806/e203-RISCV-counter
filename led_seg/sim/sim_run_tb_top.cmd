iverilog -g2005-sv -o wave.out ./tb_top.sv ../rtl/led_seg_display.v ../rtl/clk_mng.v
vvp -n wave.out -lxt2
gtkwave waveout.vcd
