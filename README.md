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

In the case, if the first symbolic sequence x"BAF" occurs in the last bit of the 8-bit package, we will need to store no more than 24 bits (3 8-bit packages).
1. Modules ISERDESE2 provided for Xilinx 7 generation FPGA allow cascading for increasing bitwidth, but the allowed values of bitwidth do not contain 12 bit.
2. Besides, switching bitwidth of deserializer will require resynthesizing firmware.
