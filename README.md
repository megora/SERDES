# SERDES
A serial to parallel converter (SERDES) which can be switched between 8, 10 and 12 bit.

## Motivation

This is a qualification task 1 in [T871 VHDL Challenge](https://lab.apertus.org/T871) for GSoC 2020.

## Task
Create VHDL code for a serial to parallel converter (SERDES) with varied bandwidth of 8, 10 and 12 bit.
- Serial speed: 600 MHz
- Clock: 100 MHz (fixed phase relation)
- Using existing library elements is allowed 
- Language - VHDL

## Description
- Target device: Artix-7 FPGA
- External clock: 100 MHz

## Project structure
* `clk_rst_gen.vhd`
This module is responsible for the clock and global reset signals generating.
* `deseriazlizer.vhd`
This module is responsible for the serial-parallel data transformation, and contains the Xilinx primitive ISERDESE2 configured in 8-bit mode. Although this primitive could be configured in higher bit width modes, it do not provide all required bit width values. Moreover, mode change is not available without reconfiguration.
* `data alignment.vhd`
This module reshapes 8-bit data received from the deseriazlizer module into properly aligned words according to the word length settings.
* `comma_detection.vhd`
This submodule performs asynchronous comma detection in the 19-bit shift register, fed from the deserializer. It outputs comma detection flag if the comma is detected and the detected word’s LSB index in the shift register.
