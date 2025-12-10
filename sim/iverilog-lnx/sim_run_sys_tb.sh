#!/bin/bash -f
# iverilog quick sim with firmware preload (Linux)
cd "$(dirname "$0")" || exit 1

HEX=../../firmware/hello_world/Debug/ram.hex
OUT=wave.out

if [ ! -f "$HEX" ]; then
  echo "Missing firmware hex: $HEX"
  exit 1
fi

iverilog -g2005-sv -o "$OUT" -I ../../rtl/core sys_tb_top.sv ../gowin_sim_lib/gw2a/prim_sim.v \
  -DE203_LOAD_PROGRAM -DITCM_HEX_PATH=\"${HEX}\" \
  ../../rtl/ip/my_periph_example.v \
  ../../rtl/core/*.v

vvp "$OUT"