#!/usr/bin/python3
# -*- coding: utf-8 -*-
import sys, os, struct, re, codecs

word_list = [
  ['WIDTH_I', 'A'],
  ['WIDTH_D', 'B'],
  ['DEPTH_I', 'C'],
  ['DEPTH_D', 'D'],
  ['DEPTH_REG', 'E'],
  ['clk', 'a'],
  ['soft_reset', 'c'],
  ['reset', 'b'],
  ['mem_i_r_addr', 'd'],
  ['mem_i_r_data', 'e'],
  ['mem_d_r_addr', 'f'],
  ['mem_d_r_data', 'g'],
  ['mem_d_w_addr', 'h'],
  ['mem_d_w_data', 'u0'],
  ['mem_d_we', 'j'],
  ['TRUE', 'F'],
  ['FALSE', 'G'],
  ['ONE', 'H'],
  ['ZERO', 'I'],
  ['FFFF', 'J'],
  ['SHIFT_BITS', 'K'],
  ['DEPTH_OPERAND', 'L'],
  ['MUL_DELAY', 'M'],
  ['BL_OFFSET', 'N'],
  ['I_NOP', '5\'h0'],
  ['I_ST', '5\'h1'],
  ['I_MVC', '5\'h2'],
  ['I_BA', '5\'h3'],
  ['I_BC', '5\'h4'],
  ['I_MUL', '5\'h5'],
  ['I_SRA', '5\'h8'],
  ['I_SR', '5\'h6'],
  ['I_SL', '5\'h7'],
  ['I_ADD', '5\'h10'],
  ['I_SUB', '5\'h11'],
  ['I_AND', '5\'h12'],
  ['I_OR', '5\'h13'],
  ['I_XOR', '5\'h14'],
  ['I_MVS', '5\'h17'],
  ['I_MVIL', '5\'h16'],
  ['I_MV', '5\'h15'],
  ['I_BL', '5\'h18'],
  ['I_LD', '5\'h19'],
  ['I_CNZ', '5\'h1a'],
  ['I_CNM', '5\'h1b'],
  ['SP_REG_MVC', 'O'],
  ['SP_REG_MVIL', 'P'],
  ['inst', 'k'],
  ['ol_d', 'l'],
  ['ol_a', 'm'],
  ['im_l', 'n'],
  ['is_im', 'o'],
  ['op', 'p'],
  ['do_jump', 'q'],
  ['jump_addr', 'r'],
  ['reg_data_w', 's'],
  ['reg_data_r_d', 't'],
  ['reg_data_r_a', 'u'],
  ['reg_addr_a', 'v'],
  ['reg_addr_w', 'w'],
  ['reg_we', 'x'],
  ['alu_din_d', 'y'],
  ['alu_din_a', 'z'],
  ['result_sl', 'a0'],
  ['sl_pd', 'b0'],
  ['sl_pa', 'c0'],
  ['sl_b', 'd0'],
  ['result_sr', 'e0'],
  ['sr_pd', 'f0'],
  ['sr_pa', 'g0'],
  ['sr_b', 'h0'],
  ['result_sra', 'i0'],
  ['sra_pd', 'j0'],
  ['sra_pa', 'k0'],
  ['sra_b', 'l0'],
  ['result_mul', 'm0'],
  ['mul_pd', 'n0'],
  ['mul_pa', 'o0'],
  ['mul_b', 'p0'],
  ['regfile', 'q0'],
  ['reg_sp', 'r0'],
  ['reg_a_nz', 's0'],
  ['reg_a_nm', 't0'],
  [r'\s+', ' '],
  [r'^\s+', ''],
  [r'//.*', ''],
  ['\%', ''],
  ]

def replace_words():
  fr = codecs.open(sys.argv[1], 'r', 'utf-8')
  for line in fr:
    for wl in word_list:
      line = re.sub(wl[0], wl[1], line, flags=re.M|re.S)
    print(line.rstrip())

replace_words()
sys.exit()
