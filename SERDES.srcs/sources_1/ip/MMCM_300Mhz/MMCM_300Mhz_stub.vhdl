-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
-- Date        : Tue Apr 14 19:21:25 2020
-- Host        : megora-laptop running 64-bit Linux Mint 19.3 Tricia
-- Command     : write_vhdl -force -mode synth_stub {/home/megora/Documents/HDL
--               projects/GSoC/SERDES/SERDES.srcs/sources_1/ip/MMCM_300Mhz/MMCM_300Mhz_stub.vhdl}
-- Design      : MMCM_300Mhz
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MMCM_300Mhz is
  Port ( 
    clk_300_ph0 : out STD_LOGIC;
    clk_300_ph90 : out STD_LOGIC;
    clk_75 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in : in STD_LOGIC
  );

end MMCM_300Mhz;

architecture stub of MMCM_300Mhz is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_300_ph0,clk_300_ph90,clk_75,reset,locked,clk_in";
begin
end;
