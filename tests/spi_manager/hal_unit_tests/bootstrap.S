// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

.global rvx_boot
.section ".init.rvx_boot"
.option norvc;

rvx_boot:
  .option push
  .option norelax
  la gp, __global_pointer$
  .option pop
  la sp, __stack_top
  la t0, rvx_trap_vector
  csrw mtvec, t0

#ifdef STARTUP_DATA_ROM
  la a0, __data_target_start
  la a2, __data_target_end
  sub a2, a2, a0
  li a1, __data_source_start
  call memcpy
#endif

#ifdef NO_STARTUP_FILES
  call main
#else
  call _start
#endif
  j .

.section ".init.rvx_trap_vector"
.global rvx_trap_vector
rvx_trap_vector:
  .option push
  .option norvc
  j default_trap_handler    // Trap handler for non-vectored mode (default mode)
  j .
  j .
  j msi_irq_handler         // Machine software interrupt
  j .
  j .
  j .
  j mti_irq_handler         // Machine timer interrupt
  j .
  j .
  j .
  j mei_irq_handler         // Machine external interrupt
  j .
  j .
  j .
  j .
  j fast0_irq_handler       // Fast interrupt #0
  j fast1_irq_handler       // Fast interrupt #1
  j fast2_irq_handler       // Fast interrupt #2
  j fast3_irq_handler       // Fast interrupt #3
  j fast4_irq_handler       // Fast interrupt #4
  j fast5_irq_handler       // Fast interrupt #5
  j fast6_irq_handler       // Fast interrupt #6
  j fast7_irq_handler       // Fast interrupt #7
  j fast8_irq_handler       // Fast interrupt #8
  j fast9_irq_handler       // Fast interrupt #9
  j fast10_irq_handler      // Fast interrupt #10
  j fast11_irq_handler      // Fast interrupt #11
  j fast12_irq_handler      // Fast interrupt #12
  j fast13_irq_handler      // Fast interrupt #13
  j fast14_irq_handler      // Fast interrupt #14
  j fast15_irq_handler      // Fast interrupt #15
  .option pop

.weak default_trap_handler
default_trap_handler:
  mret

.weak msi_irq_handler
.weak mti_irq_handler
.weak mei_irq_handler
.weak fast0_irq_handler
.weak fast1_irq_handler
.weak fast2_irq_handler
.weak fast3_irq_handler
.weak fast4_irq_handler
.weak fast5_irq_handler
.weak fast6_irq_handler
.weak fast7_irq_handler
.weak fast8_irq_handler
.weak fast9_irq_handler
.weak fast10_irq_handler
.weak fast11_irq_handler
.weak fast12_irq_handler
.weak fast13_irq_handler
.weak fast14_irq_handler
.weak fast15_irq_handler
.set msi_irq_handler, default_trap_handler
.set mti_irq_handler, default_trap_handler
.set mei_irq_handler, default_trap_handler
.set fast0_irq_handler, default_trap_handler
.set fast1_irq_handler, default_trap_handler
.set fast2_irq_handler, default_trap_handler
.set fast3_irq_handler, default_trap_handler
.set fast4_irq_handler, default_trap_handler
.set fast5_irq_handler, default_trap_handler
.set fast6_irq_handler, default_trap_handler
.set fast7_irq_handler, default_trap_handler
.set fast8_irq_handler, default_trap_handler
.set fast9_irq_handler, default_trap_handler
.set fast10_irq_handler, default_trap_handler
.set fast11_irq_handler, default_trap_handler
.set fast12_irq_handler, default_trap_handler
.set fast13_irq_handler, default_trap_handler
.set fast14_irq_handler, default_trap_handler
.set fast15_irq_handler, default_trap_handler
