// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2016 miya All rights reserved.

`timescale 1ns / 1ps
`define USE_UART
`define DEBUG

module testbench;

  localparam STEP  = 20; // 20 ns: 50MHz
  localparam TICKS = 20000;

  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;
  localparam CORES = 4;
  localparam DEPTH_REG = 5;
  localparam UART_CLK_HZ = 50000000;
  localparam UART_SCLK_HZ = 5000000;

  reg        clk;
  reg        reset;
  wire [15:0] led;
`ifdef USE_UART
  // uart
  wire        uart_txd;
  wire        uart_rxd;
  wire        uart_re;
  wire [7:0]  uart_data_rx;
`endif

  integer     i;
  initial
  begin
    $dumpfile("wave.vcd");
    $dumpvars(10, testbench);
    $monitor("time: %d reset: %d led: %d uart_re: %d uart_data_rx: %c", $time, reset, led, uart_re, uart_data_rx);
    for (i = 0; i < (1 << DEPTH_REG); i = i + 1)
    begin
      $dumpvars(0, testbench.mini16sc_soc_0.mini16sc_cpu_0.regfile[i]);
      //$dumpvars(0, testbench.mini16sc_soc_0.mini16sc_cpu_0.q0[i]);
    end
    for (i = 0; i < 4; i = i + 1)
    begin
      $dumpvars(0, testbench.mini16sc_soc_0.mini16sc_cpu_0.reg_sp[i]);
      //$dumpvars(0, testbench.mini16sc_soc_0.mini16sc_cpu_0.r0[i]);
    end
    for (i = 0; i < 32; i = i + 1)
    begin
      $dumpvars(0, testbench.mini16sc_soc_0.master_mem_d.ram[i]);
    end
  end

  // generate clk
  initial
  begin
    clk = 1'b1;
    forever
    begin
      #(STEP / 2) clk = ~clk;
    end
  end

  // generate reset signal
  initial
  begin
    reset = 1'b0;
    repeat (10) @(posedge clk) reset <= 1'b1;
    @(posedge clk) reset <= 1'b0;
  end

  // stop simulation after TICKS
  initial
  begin
    repeat (TICKS) @(posedge clk);
    $finish;
  end

  mini16sc_soc
    #(
      .UART_CLK_HZ (UART_CLK_HZ),
      .UART_SCLK_HZ (UART_SCLK_HZ)
      )
  mini16sc_soc_0
    (
     .clk (clk),
     .reset (reset),
`ifdef USE_UART
     .uart_rxd (uart_rxd),
     .uart_txd (uart_txd),
`endif
     .led (led)
     );

`ifdef USE_UART
  uart
    #(
      .CLK_HZ (UART_CLK_HZ),
      .SCLK_HZ (UART_SCLK_HZ),
      .WIDTH (8)
      )
  uart_0
    (
     .clk (clk),
     .reset (reset),
     .rxd (uart_txd),
     .start (),
     .data_tx (),
     .txd (),
     .busy (),
     .re (uart_re),
     .data_rx (uart_data_rx)
     );
`endif

endmodule
