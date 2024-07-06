// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2024 miya All rights reserved.
module mini16sc_cpu_4k
  #(parameter WIDTH_%I = 16, WIDTH_%D = 16, DEPTH_%I = 8, DEPTH_%D = 8, DEPTH_%REG = 5)
  (
   input                    cl%k,
   input                    res%et,
   input                    soft_r%eset,
   output wire [DEPTH_I-1:0] mem%_i_r_addr,
   input [WIDTH_I-1:0]      mem%_i_r_data,
   output wire [DEPTH_D-1:0] mem%_d_r_addr,
   input [WIDTH_D-1:0]      mem%_d_r_data,
   output wire [DEPTH_D-1:0] mem%_d_w_addr,
   output wire [WIDTH_D-1:0] mem%_d_w_data,
   output wire               mem%_d_we
   );

  localparam WIDTH_I = WIDTH_%I, WIDTH_D = WIDTH_%D, DEPTH_I = DEPTH_%I, DEPTH_D = DEPTH_%D, DEPTH_REG = DEPTH_%REG;
  wire clk = cl%k;
  wire reset = res%et;
  wire soft_reset = soft_r%eset;
  wire [WIDTH_I-1:0] mem_i_r_data = mem%_i_r_data;
  wire [WIDTH_D-1:0] mem_d_r_data = mem%_d_r_data;
  output reg [DEPTH_I-1:0] mem_i_r_addr;
  output reg [DEPTH_D-1:0] mem_d_r_addr, mem_d_w_addr;
  output reg [WIDTH_D-1:0] mem_d_w_data;
  output reg               mem_d_we;
  assign mem%_i_r_addr = mem_i_r_addr;
  assign mem%_d_r_addr = mem_d_r_addr;
  assign mem%_d_w_addr = mem_d_w_addr;
  assign mem%_d_w_data = mem_d_w_data;
  assign mem%_d_we = mem_d_we;

  localparam TRUE = 1'b1, FALSE = 1'b0, ONE = 1'd1, ZERO = 1'd0, FFFF = {WIDTH_D{1'b1}}, SHIFT_BITS = $clog2(WIDTH_D), DEPTH_OPERAND = 5, MUL_DELAY = 3, BL_OFFSET = 1'd1, SP_REG_MVC = 0, SP_REG_MVIL = 1;

  reg [WIDTH_I-1:0]        inst;
  wire [DEPTH_OPERAND-1:0] ol_d, ol_a;
  wire [10:0]              im_l;
  wire                     is_im;
  wire [4:0]               op;
  reg                      do_jump, reg_we, reg_a_nz, reg_a_nm;
  reg [DEPTH_I-1:0]        jump_addr;
  wire [WIDTH_D-1:0]       reg_addr_a;
  reg [DEPTH_REG-1:0]      reg_addr_w;
  reg [WIDTH_D-1:0]        reg_data_w, reg_data_r_d, reg_data_r_a, alu_din_d,  alu_din_a, result_sl,  sl_pd,  sl_pa,  sl_b, result_sr,  sr_pd,  sr_pa,  sr_b, result_sra, sra_pd, sra_pa, sra_b, result_mul, mul_pd, mul_pa;
  reg [WIDTH_D-1:0]        mul_b [0:MUL_DELAY];
  reg [WIDTH_D-1:0]        regfile [0:(1<<DEPTH_REG)-1];
  reg [WIDTH_D-1:0]        reg_sp [0:3];
  integer                  i;

  assign ol_d = inst[15:11];
  assign ol_a = inst[10:6];
  assign is_im = inst[5];
  assign op = inst[4:0];
  assign im_l = inst[15:5];

  always @*
  begin
    reg_data_r_d = regfile[ol_d];
    reg_data_r_a = regfile[ol_a];
    reg_a_nz = (reg_data_r_a != ZERO);
    reg_a_nm = (reg_data_r_a[WIDTH_D-1] == 1'b0);

    case (op)
      I_MVC:   reg_addr_w = SP_REG_MVC;
      I_MVIL:  reg_addr_w = SP_REG_MVIL;
      default: reg_addr_w = ol_d;
    endcase
    if ((op[4] == TRUE) || ((op == I_MVC) && (reg_a_nz == TRUE)))
      reg_we = TRUE;
    else
      reg_we = FALSE;

    if ((op == I_BA) || ((op == I_BC) && (reg_data_r_d != ZERO)) || (op == I_BL))
    begin
      do_jump = TRUE;
      jump_addr = reg_data_r_a;
    end
    else
    begin
      do_jump = FALSE;
      jump_addr = ZERO;
    end

    alu_din_d = reg_data_r_d;
    if (is_im == TRUE)
      alu_din_a = $signed(ol_a);
    else
      alu_din_a = reg_data_r_a;

    case (op)
      I_ADD: reg_data_w = alu_din_d + alu_din_a;
      I_SUB: reg_data_w = alu_din_d - alu_din_a;
      I_AND: reg_data_w = alu_din_d & alu_din_a;
      I_OR:  reg_data_w = alu_din_d | alu_din_a;
      I_XOR: reg_data_w = alu_din_d ^ alu_din_a;
      I_MV:  reg_data_w = alu_din_a;
      I_MVC: reg_data_w = alu_din_d;
      I_MVS: reg_data_w = reg_sp[alu_din_a];
      I_BL:  reg_data_w = mem_i_r_addr + BL_OFFSET;
      I_LD:  reg_data_w = mem_d_r_data;
      I_MVIL: reg_data_w = im_l;
      I_CNZ:
        begin
          if (reg_a_nz == TRUE)
            reg_data_w = {WIDTH_D{TRUE}};
          else
            reg_data_w = {WIDTH_D{FALSE}};
        end
      I_CNM:
        begin
          if (reg_a_nm == TRUE)
            reg_data_w = {WIDTH_D{TRUE}};
          else
            reg_data_w = {WIDTH_D{FALSE}};
        end
      default: reg_data_w = ZERO;
    endcase
  end

  always @(posedge clk)
  begin
    if (reg_we == 1'b1)
    begin
      regfile[reg_addr_w] <= reg_data_w;
    end

    if (reset == TRUE)
    begin
      mem_i_r_addr <= ZERO;
    end
    else
    begin
      if (soft_reset == TRUE)
      begin
        mem_i_r_addr <= ZERO;
      end
      else
      begin
        if (do_jump == TRUE)
        begin
          mem_i_r_addr <= jump_addr;
        end
        else
        begin
          mem_i_r_addr <= mem_i_r_addr + ONE;
        end
      end
    end

    if (reset == TRUE)
      inst <= ZERO;
    else
      inst <= mem_i_r_data;

    if (op == I_LD)
      mem_d_r_addr <= reg_data_r_a;
    if (op == I_ST)
      mem_d_w_addr <= reg_data_r_d;
    if (op == I_ST)
      mem_d_w_data <= reg_data_r_a;
    if (op == I_ST)
      mem_d_we <= TRUE;
    else
      mem_d_we <= FALSE;

    if (op == I_MUL)
    begin
      mul_pd <= alu_din_d;
      mul_pa <= alu_din_a;
    end
    mul_b[0] <= mul_pd * mul_pa;
    for (i = 0; i < MUL_DELAY; i = i + 1)
    begin: gen_mul_b
      mul_b[i + 1] <= mul_b[i];
    end
    reg_sp[3] <= mul_b[MUL_DELAY];

    if (op == I_SL)
    begin
      sl_pd <= alu_din_d;
      sl_pa <= alu_din_a;
    end
    sl_b <= sl_pd << sl_pa;
    reg_sp[0] <= sl_b;

    if (op == I_SR)
    begin
      sr_pd <= alu_din_d;
      sr_pa <= alu_din_a;
    end
    sr_b <= sr_pd >> sr_pa;
    reg_sp[1] <= sr_b;

    if (op == I_SRA)
    begin
      sra_pd <= alu_din_d;
      sra_pa <= alu_din_a;
    end
    sra_b <= $signed(sra_pd) >>> sra_pa;
    reg_sp[2] <= sra_b;
  end
endmodule
