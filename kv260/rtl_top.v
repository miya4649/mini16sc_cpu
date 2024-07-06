// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2024 miya All rights reserved.

module rtl_top
  (
   input wire  clk,
`ifdef USE_UART
   input wire  uart_rxd,
   output wire uart_txd,
`endif
   input wire  resetn,
   output wire led
   );

  localparam UART_CLK_HZ = 400000000;
  localparam UART_SCLK_HZ = 115200;
  localparam ZERO = 1'd0;
  localparam ONE = 1'd1;
  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;

  wire [15:0] led_soc;
  assign led = led_soc[0];

  // reset
  reg reset;
  reg reset1;
  reg reset2;

  always @(posedge clk)
    begin
      reset1 <= resetn;
      reset2 <= reset1;
      reset <= ~reset2;
    end

  mini16sc_soc
    #(
      .UART_CLK_HZ (UART_CLK_HZ),
      .UART_SCLK_HZ (UART_SCLK_HZ)
      )
  mini16sc_soc_0
    (
`ifdef USE_UART
     .uart_rxd (uart_rxd),
     .uart_txd (uart_txd),
`endif
     .clk (clk),
     .reset (reset),
     .led (led_soc)
     );

endmodule
