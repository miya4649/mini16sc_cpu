// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2016 miya All rights reserved.

// DEPTH >= 2
// Latency = DEPTH

module shift_register_vector
  #(
    parameter WIDTH = 8,
    parameter DEPTH = 3
    )
  (
   input              clk,
   input [WIDTH-1:0]  data_in,
   output [WIDTH-1:0] data_out
   );

  reg [WIDTH*DEPTH-1:0] s_reg;

  always @(posedge clk)
    begin
      s_reg <= {s_reg[WIDTH*(DEPTH-1)-1:0], data_in};
    end

  assign data_out = s_reg[WIDTH*DEPTH-1:WIDTH*(DEPTH-1)];

endmodule
