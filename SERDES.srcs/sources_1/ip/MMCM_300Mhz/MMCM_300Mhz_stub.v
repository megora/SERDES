// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
// Date        : Tue Apr 14 19:21:25 2020
// Host        : megora-laptop running 64-bit Linux Mint 19.3 Tricia
// Command     : write_verilog -force -mode synth_stub {/home/megora/Documents/HDL
//               projects/GSoC/SERDES/SERDES.srcs/sources_1/ip/MMCM_300Mhz/MMCM_300Mhz_stub.v}
// Design      : MMCM_300Mhz
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module MMCM_300Mhz(clk_300_ph0, clk_300_ph90, clk_75, reset, locked, 
  clk_in)
/* synthesis syn_black_box black_box_pad_pin="clk_300_ph0,clk_300_ph90,clk_75,reset,locked,clk_in" */;
  output clk_300_ph0;
  output clk_300_ph90;
  output clk_75;
  input reset;
  output locked;
  input clk_in;
endmodule
