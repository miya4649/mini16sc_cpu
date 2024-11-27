# Mini16SC-CPU

Simple, Fast and Small Single-Cycle CPU written in Verilog HDL

## Features

Most instructions are completed in one clock cycle, so there are no dependency stalls. (except load, multiply and barrel-shift)

Multiply, barrel-shift, and load instructions are executed in pipeline.

16bit ISA

Variable register, bus width (16, 32, 64bits ...)

Highly parameterized design

## FPGA logic usage

(with UART interface, Multiplier, Barrel-shifter)

AMD Kria KV260: 109 CLB, 1 DSP

## Maximum frequency

AMD Kria KV260: 400 MHz (Proofed)

## ISA

NOP: None

ST: memory[reg_a] = reg_b

MVC: if (reg_b != 0) reg_0 = reg_a

BA: jump to reg_b

BC: if (reg_a != 0) jump to reg_b

ADD: reg_a += reg_b

SUB: reg_a -= reg_b

AND: reg_a &= reg_b

OR: reg_a |= reg_b

XOR: reg_a ^= reg_b

MV: reg_a = reg_b

MVIL: reg_a = 10bit unsigned immediate

BL: jump to reg_b, reg_a = return-address

CNZ: reg_a = (reg_b != 0)

CNM: reg_a = (reg_b >= 0)

LD: memory-address = reg_b, reg_a = previously loaded data, latency: 3

MUL: reg_sp[3] = reg_a * reg_b, latency: 6

SR: reg_sp[1] = reg_a >> reg_b, latency: 3

SL: reg_sp[0] = reg_a << reg_b, latency: 3

SRA: reg_sp[2] = reg_a >>> reg_b, latency: 3

MVS: reg_a = reg_sp[reg_b]

Immediate Operation (ADDI, SUBI, ...): reg_b:5bit signed immediate

## An implementation of a many-core processor using this CPU core

Mini16-manycore

https://github.com/miya4649/mini16_manycore
