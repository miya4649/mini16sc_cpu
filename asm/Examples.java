// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2019 miya All rights reserved.

import java.lang.Math;

public class Examples extends AsmLib
{
  private int DEBUG = 0;

  private int U2M_ADDR_H;
  private int U2M_ADDR_SHIFT;
  private int IO_REG_W_ADDR_H;
  private int IO_REG_W_ADDR_SHIFT;
  private int IO_REG_R_ADDR_H;
  private int IO_REG_R_ADDR_SHIFT;

  private void f_get_io_reg_w_addr()
  {
    // input: R3: device reg num
    // output: R3:io_reg_w_addr
    int io_reg_w_addr = 3;
    int tmp0 = LREG0;
    // io_reg_w_addr = (IO_REG_W_ADDR_H << IO_REG_W_ADDR_SHIFT) + R3;
    label("f_get_io_reg_w_addr");
    lib_push(SP_REG_LINK);
    lib_set_im(tmp0, IO_REG_W_ADDR_H);
    as_sli(tmp0, IO_REG_W_ADDR_SHIFT);
    lib_nop(2);
    as_mvsi(tmp0, MVS_SL);
    as_add(io_reg_w_addr, tmp0);
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  private void f_get_io_reg_r_addr()
  {
    // input: R3: device reg num
    // output: R3:io_reg_r_addr
    int io_reg_r_addr = 3;
    int tmp0 = LREG0;
    // io_reg_r_addr = (IO_REG_R_ADDR_H << IO_REG_R_ADDR_SHIFT) + R3;
    label("f_get_io_reg_r_addr");
    lib_push(SP_REG_LINK);
    lib_set_im(tmp0, IO_REG_R_ADDR_H);
    as_sli(tmp0, IO_REG_R_ADDR_SHIFT);
    lib_nop(2);
    as_mvsi(tmp0, MVS_SL);
    as_add(io_reg_r_addr, tmp0);
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  private void f_get_u2m_addr()
  {
    // output: R3:u2m_addr
    int u2m_addr = 3;
    // u2m_addr = U2M_ADDR_H << U2M_ADDR_SHIFT;
    label("f_get_u2m_addr");
    lib_push(SP_REG_LINK);
    lib_set_im(u2m_addr, U2M_ADDR_H);
    as_sli(u2m_addr, U2M_ADDR_SHIFT);
    lib_nop(2);
    as_mvsi(u2m_addr, MVS_SL);
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  private void example_led()
  {
    // for 16bit register machine
    /*
    led_addr = (MASTER_W_BANK_IO_REG << DEPTH_B_M_W) + IO_REG_W_LED;
    counter = 0;
    counter2 = 0;
    shift = 7;
    do
    {
      led = counter >> shift;
      mem[led_addr] = counter;
      counter++;
      do
      {
        counter2++;
      } while (counter2 != 0);
    } while (1);
    */
    int led_addr = R3;
    int counter = R4;
    int counter2 = R5;
    int led = R6;
    int shift = R7;
    as_nop();
    lib_init_stack();
    lib_set_im(R3, IO_REG_W_LED);
    lib_call("f_get_io_reg_w_addr");
    as_mvi(counter, 0);
    as_mvi(counter2, 0);
    // normal: shift=5
    as_mvi(shift, 5);
    label("example_led_L_0");
    as_mv(led, counter);
    as_sr(led, shift);
    as_addi(counter, 1);
    as_nop();
    as_mvsi(led, MVS_SR);
    as_st(led_addr, led);
    label("example_led_L_1");
    as_cnz(R8, counter2);
    as_addi(counter2, 1);
    lib_bc(R8, "example_led_L_1");
    lib_ba("example_led_L_0");
    // link library
    f_get_io_reg_w_addr();
  }

  private void example_counter()
  {
    as_nop();
    lib_init_stack();
    as_mvi(R3, 0);
    as_mvi(R4, 0);
    label("example_counter_L_0");
    lib_call("f_uart_hex_word_ln");
    as_mv(R3, R4);
    as_addi(R4, 1);
    lib_ba("example_counter_L_0");
    // link library
    f_uart_char();
    f_uart_hex();
    f_uart_hex_word();
    f_uart_hex_word_ln();
  }

  private void example_helloworld()
  {
    as_nop();
    lib_init_stack();
    as_mvi(R4, MASTER_R_BANK_MEM_D);
    as_sli(R4, DEPTH_B_M_R);
    lib_set_im(R3, addr_abs("d_helloworld"));
    as_mvsi(R4, MVS_SL);
    as_add(R3, R4);
    if (WIDTH_M_D == 32)
    {
      lib_call("f_uart_print_32");
    }
    else
    {
      lib_call("f_uart_print_16");
    }
    lib_call("f_halt");
    // link library
    f_uart_char();
    if (WIDTH_M_D == 32)
    {
      f_uart_print_32();
    }
    else
    {
      f_uart_print_16();
    }
    f_halt();
    f_get_u2m_data();
  }

  private void example_helloworld_data()
  {
    label("d_helloworld");
    if (WIDTH_M_D == 32)
    {
      string_data32("Hello, world!\r\n");
    }
    else
    {
      string_data16("Hello, world!\r\n");
    }
  }

  // copy data from U2M to MEM_D
  // call before lib_init_stack()
  public void f_get_u2m_data()
  {
    int addr_dst = LREG0;
    int addr_src = LREG1;
    int size = LREG2;
    int data = LREG3;
    label("f_get_u2m_data");
    lib_push(SP_REG_LINK);
    as_mvi(size, 1);
    as_mvi(addr_src, U2M_ADDR_H);
    as_sli(addr_src, U2M_ADDR_SHIFT);
    as_mvi(addr_dst, 0);
    as_nop();
    as_mvsi(addr_src, MVS_SL);
    as_sli(size, DEPTH_M_D);
    lib_nop(2);
    as_mvsi(size, MVS_SL);
    label("f_get_u2m_data_L_0");
    as_ld(data, addr_src);
    as_subi(size, 1);
    as_addi(addr_src, 1);
    as_ld(data, addr_src);
    as_st(addr_dst, data);
    as_cnz(LREG4, size);
    as_addi(addr_dst, 1);
    lib_bc(LREG4, "f_get_u2m_data_L_0");
    lib_pop(SP_REG_LINK);
    lib_return();
  }

  @Override
  public void init(String[] args)
  {
    super.init(args);
    U2M_ADDR_H = MASTER_R_BANK_U2M;
    U2M_ADDR_SHIFT = DEPTH_B_M_R;
    IO_REG_W_ADDR_H = MASTER_W_BANK_IO_REG;
    IO_REG_W_ADDR_SHIFT = DEPTH_B_M_W;
    IO_REG_R_ADDR_H = MASTER_R_BANK_IO_REG;
    IO_REG_R_ADDR_SHIFT = DEPTH_B_M_R;
  }

  private void test2()
  {
    // example of Continuous MUL
    as_nop();
    as_mvi(R3, -2);
    as_mvi(R4, -3);
    as_mvi(R5, 5);
    as_mvi(R6, 7);
    as_mul(R3, R3);
    as_mul(R3, R4);
    as_mul(R3, R5);
    as_mul(R3, R6);
    as_mul(R4, R3);
    as_mul(R4, R4);
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_mul(R4, R5);
    as_mul(R4, R6);
    as_mul(R5, R3);
    as_mul(R5, R4);
    as_mul(R5, R5);
    as_mul(R5, R6);
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_mul(R6, R3);
    as_mul(R6, R4);
    as_mul(R6, R5);
    as_mul(R6, R6);
    as_nop();
    as_nop();
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_mvsi(R7, MVS_MUL);
    as_nop();
    as_nop();
    as_nop();
    as_nop();
    as_nop();
    as_nop();
  }

  private void test3()
  {
    // example of shift
    as_nop();
    as_mvi(R3, 2);
    as_mvi(R4, -5);
    as_mvi(R5, -7);
    as_sli(R3, 5);
    as_sri(R4, 1);
    as_srai(R5, 1);
    as_mvsi(R7, MVS_SL);
    as_mvsi(R7, MVS_SR);
    as_mvsi(R7, MVS_SRA);
  }

  private void test4()
  {
    // Example to load 4 words from memory address 0 into R4-7
    as_nop(); // line 0
    as_mvil(0);
    as_mv(R3, SP_REG_MVIL);
    as_ld(R4, R3); // R4 is garbage. Reserve to load from address R3
    as_addi(R3, 1); // Calculate the next address to load
    as_ld(R4, R3); // Still R4 is garbage. Set the next address to load
    as_addi(R3, 1); // The value can be read for the first time from this cycle
    as_ld(R4, R3); // The first ld value is written to R4 normally
    as_addi(R3, 1);
    as_ld(R5, R3); // value of line 5 ld goes into R5
    as_ld(R6, R3); // value of line 7 ld goes into R6, address is dummy
    as_nop(); // wait for line 9 ld
    as_ld(R7, R3); // value of line 9 ld goes into R7, address is dummy
  }

  private void test5()
  {
    // test lib_push lib_pop
    as_nop();
    lib_init_stack();
    as_mvi(R3, 1);
    lib_push(R3);
    as_mvi(R3, 2);
    lib_pop(R3);
    as_mv(R4, R3);
  }

  private void test6()
  {
    // test memcpy
    as_nop();
    lib_init_stack();
    as_mvi(R3, 10);
    as_mvi(R4, 2);
    as_mvi(R5, 3);
    lib_call("f_memcpy");
    lib_call("f_halt");
    // link library
    f_memcpy();
    f_halt();
  }

  private void test7()
  {
    // test uart_char
    as_nop();
    lib_init_stack();
    lib_set_im(R3, 'A');
    lib_call("f_uart_char");
    lib_call("f_halt");
    // link library
    f_uart_char();
    f_halt();
  }

  private void test8()
  {
    // test uart_hex
    as_nop();
    lib_init_stack();
    lib_set_im(R3, 12);
    lib_call("f_uart_hex");
    lib_call("f_halt");
    // link library
    f_uart_char();
    f_uart_hex();
    f_halt();
  }

  private void test9()
  {
    // test push_regs, pop_regs
    as_nop();
    lib_init_stack();
    as_mvi(R3, 1);
    as_mvi(R4, 2);
    as_mvi(R5, 3);
    as_mvi(R6, 4);
    as_mvi(R7, 5);
    lib_push_regs(R3, 5);
    as_mvi(R3, 0);
    as_mvi(R4, 0);
    as_mvi(R5, 0);
    as_mvi(R6, 0);
    as_mvi(R7, 0);
    lib_pop_regs(R3, 5);
  }

  private void test10()
  {
    // test f_uart_hex_word
    as_nop();
    lib_init_stack();
    as_mvi(R4, 1);
    as_mvi(R5, 2);
    as_mvi(R6, 3);
    as_mvi(R7, 4);
    lib_ld(R3, "test2");
    lib_call("f_uart_hex_word");
    lib_call("f_halt");
    // link library
    f_uart_char();
    f_uart_hex();
    f_uart_hex_word();
    f_halt();
  }

  private void test11()
  {
    // test f_memory_dump
    as_nop();
    lib_init_stack();
    as_mvi(R3, 0);
    lib_set_im(R4, 256);
    lib_call("f_uart_memory_dump");
    lib_call("f_halt");
    // link library
    f_uart_char();
    f_uart_hex();
    f_uart_hex_word();
    f_uart_hex_word_ln();
    f_uart_memory_dump();
    f_halt();
  }

  private void test12()
  {
    // test loop
    as_nop();
    as_mvi(R3, 15);
    label("test12_L_0");
    as_subi(R3, 1);
    as_cnm(R4, R3);
    lib_bc(R4, "test12_L_0");
    lib_call("f_halt");
    // link library
    f_halt();
  }

  @Override
  public void program()
  {
    set_filename("default_master_code");
    set_rom_width(WIDTH_I);
    set_rom_depth(DEPTH_M_I);
    example_led();
    //example_counter();
    //example_helloworld();
    //test12();
  }

  @Override
  public void data()
  {
    set_filename("default_master_data");
    set_rom_width(WIDTH_M_D);
    set_rom_depth(DEPTH_M_D);
    label("test2");
    dat(0x1111);
    dat(0x2222);
    dat(0x3333);
    dat(0x4444);
    example_helloworld_data();
  }
}
