// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2019 miya All rights reserved.

module mini16sc_soc
  #(
    parameter WIDTH_M_D = 16,
    parameter DEPTH_M_I = 10,
    parameter DEPTH_M_D = 8,
    parameter UART_CLK_HZ = 50000000,
    parameter UART_SCLK_HZ = 115200
    )
  (
   input  clk,
   input  reset,
`ifdef USE_UART
   input  uart_rxd,
   output uart_txd,
`endif
   output [15:0] led
   );

  // instruction width
  localparam WIDTH_I = 16;
  // register file depth
  localparam DEPTH_REG = 5;
  // I/O register depth
  localparam DEPTH_IO_REG = 5;
  // UART I/O addr depth
  localparam DEPTH_B_U = max(DEPTH_M_I, DEPTH_M_D);
  // UART I/O Virtual memory depth
  localparam DEPTH_V_U = (DEPTH_B_U + 2);
  // Master write addr depth
  localparam DEPTH_B_M_W = max(DEPTH_M_D, DEPTH_IO_REG);
  // Master read addr depth
  localparam DEPTH_B_M_R = max(DEPTH_M_D, DEPTH_IO_REG);
  // Master virtual memory write depth
  localparam DEPTH_V_M_W = (DEPTH_B_M_W + 1);
  // Master virtual memory read depth
  localparam DEPTH_V_M_R = (DEPTH_B_M_R + 2);
  // Master virtual memory depth (max(write, read))
  localparam DEPTH_V_M = max(DEPTH_V_M_W, DEPTH_V_M_R);

  localparam MASTER_W_BANK_MEM_D = 0;
  localparam MASTER_W_BANK_IO_REG = 1;
  localparam MASTER_R_BANK_MEM_D = 0;
  localparam MASTER_R_BANK_IO_REG = 1;
  localparam UART_BANK_MEM_I = 1;
  localparam UART_BANK_MEM_D = 2;
  localparam UART_BANK_RESET = 3;
  localparam IO_REG_R_UART_BUSY = 0;
  localparam IO_REG_W_LED = 1;
  localparam IO_REG_W_UART = 2;

  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;
  localparam ONE = 1'd1;
  localparam ZERO = 1'd0;

  function integer max (input integer a1, input integer a2);
    begin
      if (a1 > a2)
        begin
          max = a1;
        end
      else
        begin
          max = a2;
        end
    end
  endfunction

  // Master IO reg
  reg [WIDTH_M_D-1:0] io_reg_r[0:((1 << DEPTH_IO_REG) - 1)];
  reg [WIDTH_M_D-1:0] io_reg_w[0:((1 << DEPTH_IO_REG) - 1)];

  // LED
  assign led = io_reg_w[IO_REG_W_LED];

  // Master read
  wire [DEPTH_V_M_R-1:0] master_d_r_addr;
  reg [WIDTH_M_D-1:0]    master_d_r_data;
  wire [DEPTH_V_M_R-DEPTH_B_M_R-1:0] master_d_r_bank;
  wire [WIDTH_M_D-1:0]               master_mem_d_r_data;
  assign master_d_r_bank = master_d_r_addr[DEPTH_V_M_R-1:DEPTH_B_M_R];
  always @(posedge clk)
    begin
      case (master_d_r_bank)
        MASTER_R_BANK_MEM_D:
          begin
            master_d_r_data <= master_mem_d_r_data;
          end
        MASTER_R_BANK_IO_REG:
          begin
            master_d_r_data <= io_reg_r[master_d_r_addr[DEPTH_IO_REG-1:0]];
          end
        default:
          begin
            master_d_r_data <= ZERO;
          end
      endcase
    end

  // Master mem_d write
  wire [DEPTH_V_M_W-1:0] master_d_w_addr;
  reg [DEPTH_V_M_W-1:0] master_d_w_addr_d1;
  reg [WIDTH_M_D-1:0] master_d_w_data_d1;
  wire [WIDTH_M_D-1:0] master_d_w_data;
  reg master_mem_d_we_d1;
  wire master_d_we;
  wire [DEPTH_V_M_W-DEPTH_B_M_W-1:0] master_d_w_bank;
  reg reset_master;
`ifdef USE_UART
  // reset_master:TRUE -> writer:uart
  // reset_master:FALSE -> writer:cpu
  wire [31:0] uart_io_rx_addr;
  wire [31:0] uart_io_rx_data;
  wire uart_io_rx_we;
  wire [DEPTH_V_U-DEPTH_B_U-1:0] uart_io_rx_bank;
  wire uart_io_busy;
  always @(posedge clk)
    begin
      if (reset_master == TRUE)
        begin
          master_d_w_addr_d1 <= uart_io_rx_addr;
          master_d_w_data_d1 <= uart_io_rx_data;
        end
      else
        begin
          master_d_w_addr_d1 <= master_d_w_addr;
          master_d_w_data_d1 <= master_d_w_data;
        end
    end
  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          master_mem_d_we_d1 <= FALSE;
        end
      else
        begin
          if (reset_master == TRUE)
            begin
              if ((uart_io_rx_we == TRUE) && (uart_io_rx_bank == UART_BANK_MEM_D))
                begin
                  master_mem_d_we_d1 <= TRUE;
                end
              else
                begin
                  master_mem_d_we_d1 <= FALSE;
                end
            end
          else
            begin
              if ((master_d_we == TRUE) && (master_d_w_bank == MASTER_W_BANK_MEM_D))
                begin
                  master_mem_d_we_d1 <= TRUE;
                end
              else
                begin
                  master_mem_d_we_d1 <= FALSE;
                end
            end
        end
    end
`else
  always @(posedge clk)
    begin
      master_d_w_addr_d1 <= master_d_w_addr;
      master_d_w_data_d1 <= master_d_w_data;
    end
  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          master_mem_d_we_d1 <= FALSE;
        end
      else
        begin
          if ((master_d_we == TRUE) && (master_d_w_bank == MASTER_W_BANK_MEM_D))
            begin
              master_mem_d_we_d1 <= TRUE;
            end
          else
            begin
              master_mem_d_we_d1 <= FALSE;
            end
        end
    end
`endif

  // Master IO reg read
  always @(posedge clk)
    begin
`ifdef USE_UART
      io_reg_r[IO_REG_R_UART_BUSY] <= uart_io_busy;
`endif
    end

  // Master IO reg write
  reg [WIDTH_M_D-1:0] io_reg_w_data;
  wire [DEPTH_IO_REG-1:0] io_reg_w_addr;
  reg io_reg_we;
  assign io_reg_w_addr = master_d_w_addr_d1[DEPTH_IO_REG-1:0];

  always @(posedge clk)
    begin
      io_reg_w_data <= master_d_w_data;
    end

  always @(posedge clk)
    begin
      if ((master_d_we == TRUE) && (master_d_w_bank == MASTER_W_BANK_IO_REG))
        begin
          io_reg_we <= TRUE;
        end
      else
        begin
          io_reg_we <= FALSE;
        end
      if (io_reg_we == TRUE)
        begin
          io_reg_w[io_reg_w_addr] <= io_reg_w_data;
        end
    end

`ifdef USE_UART
  reg uart_io_tx_we;
  // Master IO reg write: UART TX we
  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          uart_io_tx_we <= FALSE;
        end
      else
        begin
          if ((io_reg_we == TRUE) && (io_reg_w_addr == IO_REG_W_UART))
            begin
              uart_io_tx_we <= TRUE;
            end
          else
            begin
              uart_io_tx_we <= FALSE;
            end
        end
    end
`endif

`ifdef USE_UART
  // UART IO: write to mem_i
  reg [31:0] uart_io_rx_addr_d1;
  reg [31:0] uart_io_rx_data_d1;
  reg master_mem_i_we;
  assign uart_io_rx_bank = uart_io_rx_addr[DEPTH_V_U-1:DEPTH_B_U];

  always @(posedge clk)
    begin
      uart_io_rx_addr_d1 <= uart_io_rx_addr;
      uart_io_rx_data_d1 <= uart_io_rx_data;
    end

  // mem_i write
  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          master_mem_i_we <= FALSE;
        end
      else
        begin
          if ((uart_io_rx_we == TRUE) && (uart_io_rx_bank == UART_BANK_MEM_I))
            begin
              master_mem_i_we <= TRUE;
            end
          else
            begin
              master_mem_i_we <= FALSE;
            end
        end
    end

  // UART IO: reset master
  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          reset_master <= FALSE;
        end
      else
        begin
          if ((uart_io_rx_we == TRUE) && (uart_io_rx_bank == UART_BANK_RESET))
            begin
              reset_master <= uart_io_rx_data[0];
            end
        end
    end

  uart_io
    #(
      .CLK_HZ (UART_CLK_HZ),
      .SCLK_HZ (UART_SCLK_HZ)
      )
  uart_io_0
    (
     .clk (clk),
     .reset (reset),
     .uart_rxd (uart_rxd),
     .tx_data (io_reg_w[IO_REG_W_UART][7:0]),
     .tx_we (uart_io_tx_we),
     .uart_txd (uart_txd),
     .uart_busy (uart_io_busy),
     .rx_addr (uart_io_rx_addr),
     .rx_data (uart_io_rx_data),
     .rx_we (uart_io_rx_we)
     );
`endif

  // Master core
  wire [DEPTH_M_I-1:0] master_i_r_addr;
  wire [WIDTH_I-1:0] master_i_r_data;
  assign master_d_w_bank = master_d_w_addr[DEPTH_V_M_W-1:DEPTH_B_M_W];

  mini16sc_cpu
    #(
      .WIDTH_I (WIDTH_I),
      .WIDTH_D (WIDTH_M_D),
      .DEPTH_I (DEPTH_M_I),
      .DEPTH_D (DEPTH_V_M),
      .DEPTH_REG (DEPTH_REG)
      )
  mini16sc_cpu_0
    (
     .clk (clk),
     .reset (reset),
`ifdef USE_UART
     .soft_reset (reset_master),
`else
     .soft_reset (FALSE),
`endif
     .mem_i_r_addr (master_i_r_addr),
     .mem_i_r_data (master_i_r_data),
     .mem_d_r_addr (master_d_r_addr),
     .mem_d_r_data (master_d_r_data),
     .mem_d_w_addr (master_d_w_addr),
     .mem_d_w_data (master_d_w_data),
     .mem_d_we (master_d_we)
     );

  default_master_code_mem
    #(
      .DATA_WIDTH (WIDTH_I),
      .ADDR_WIDTH (DEPTH_M_I)
      )
  master_mem_i
    (
     .clk (clk),
     .addr_r (master_i_r_addr),
`ifdef USE_UART
     .addr_w (uart_io_rx_addr_d1[DEPTH_M_I-1:0]),
     .data_in (uart_io_rx_data_d1[WIDTH_I-1:0]),
     .we (master_mem_i_we),
`else
     .addr_w ({DEPTH_M_I{1'b0}}),
     .data_in ({WIDTH_I{1'b0}}),
     .we (FALSE),
`endif
     .data_out (master_i_r_data)
     );

  default_master_data_mem
    #(
      .DATA_WIDTH (WIDTH_M_D),
      .ADDR_WIDTH (DEPTH_M_D)
      )
  master_mem_d
    (
     .clk (clk),
     .addr_r (master_d_r_addr[DEPTH_M_D-1:0]),
     .addr_w (master_d_w_addr_d1[DEPTH_M_D-1:0]),
     .data_in (master_d_w_data_d1),
     .we (master_mem_d_we_d1),
     .data_out (master_mem_d_r_data)
     );

endmodule
