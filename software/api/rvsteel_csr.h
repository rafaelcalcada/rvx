// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

#ifndef __RVSTEEL_CSR__
#define __RVSTEEL_CSR__

#include <stdint.h>
#include "rvsteel_gcc.h"

#if __riscv_xlen != 32
#error "Unsupported XLEN"
#endif

// Machine Status Registers bits
#define MSTATUS_MIE_OFFSET 3U
#define MSTATUS_MPIE_OFFSET 7U

#define MSTATUS_MIE_MASK (1U << MSTATUS_MIE_OFFSET)
#define MSTATUS_MPIE_MASK (1U << MSTATUS_MPIE_OFFSET)

// Machine Trap-Vector Base-Address Register bits
#define MTVEC_MODE_OFFSET 0U
#define MTVEC_BASE_OFFSET 2U

#define MTVEC_MODE_MASK (0x3 << MTVEC_MODE_OFFSET)
#define MTVEC_BASE_MASK (0x3FFFFFFF << MTVEC_BASE_OFFSET)

// Machine Interrupt bit offset (mip and mie register)
#define MIP_MIE_OFFSET_MSI 3U  // Machine software interrupt
#define MIP_MIE_OFFSET_MTI 7U  // Machine timer interrupt
#define MIP_MIE_OFFSET_MEI 11U // Machine external interrupt
#define MIP_MIE_OFFSET_SSI 1U  // Supervisor software interrupt
#define MIP_MIE_OFFSET_STI 5U  // Supervisor timer interrupt
#define MIP_MIE_OFFSET_SEI 9U  // Supervisor external interrupt

#define MIP_MIE_OFFSET_F0I 16U // Designated for platform use
#define MIP_MIE_OFFSET_F1I 17U // ...
#define MIP_MIE_OFFSET_F2I 18U
#define MIP_MIE_OFFSET_F3I 19U
#define MIP_MIE_OFFSET_F4I 20U
#define MIP_MIE_OFFSET_F5I 21U
#define MIP_MIE_OFFSET_F6I 22U
#define MIP_MIE_OFFSET_F7I 23U
#define MIP_MIE_OFFSET_F8I 24U
#define MIP_MIE_OFFSET_F9I 25U
#define MIP_MIE_OFFSET_F10I 26U
#define MIP_MIE_OFFSET_F11I 27U
#define MIP_MIE_OFFSET_F12I 28U
#define MIP_MIE_OFFSET_F13I 29U
#define MIP_MIE_OFFSET_F14I 30U
#define MIP_MIE_OFFSET_F15I 30U

// Machine Interrupt mask (mip and mie register)
#define MIP_MIE_MASK_MSI (1U << MIP_MIE_OFFSET_MSI)
#define MIP_MIE_MASK_MTI (1U << MIP_MIE_OFFSET_MTI)
#define MIP_MIE_MASK_MEI (1U << MIP_MIE_OFFSET_MEI)
#define MIP_MIE_MASK_SSI (1U << MIP_MIE_OFFSET_SSI)
#define MIP_MIE_MASK_STI (1U << MIP_MIE_OFFSET_STI)
#define MIP_MIE_MASK_SEI (1U << MIP_MIE_OFFSET_SEI)

#define MIP_MIE_MASK_F0I (1U << MIP_MIE_OFFSET_F0I)
#define MIP_MIE_MASK_F1I (1U << MIP_MIE_OFFSET_F1I)
#define MIP_MIE_MASK_F2I (1U << MIP_MIE_OFFSET_F2I)
#define MIP_MIE_MASK_F3I (1U << MIP_MIE_OFFSET_F3I)
#define MIP_MIE_MASK_F4I (1U << MIP_MIE_OFFSET_F4I)
#define MIP_MIE_MASK_F5I (1U << MIP_MIE_OFFSET_F5I)
#define MIP_MIE_MASK_F6I (1U << MIP_MIE_OFFSET_F6I)
#define MIP_MIE_MASK_F7I (1U << MIP_MIE_OFFSET_F7I)
#define MIP_MIE_MASK_F8I (1U << MIP_MIE_OFFSET_F8I)
#define MIP_MIE_MASK_F9I (1U << MIP_MIE_OFFSET_F9I)
#define MIP_MIE_MASK_F10I (1U << MIP_MIE_OFFSET_F10I)
#define MIP_MIE_MASK_F11I (1U << MIP_MIE_OFFSET_F11I)
#define MIP_MIE_MASK_F12I (1U << MIP_MIE_OFFSET_F12I)
#define MIP_MIE_MASK_F13I (1U << MIP_MIE_OFFSET_F13I)
#define MIP_MIE_MASK_F14I (1U << MIP_MIE_OFFSET_F14I)
#define MIP_MIE_MASK_F15I (1U << MIP_MIE_OFFSET_F15I)

// Machine Cause Register (mcause)
#define MCAUSE_INTER_OFFSET (__riscv_xlen - 1)
#define MCAUSE_INTER_MASK (1U << MCAUSE_INTER_OFFSET)

#define MCAUSE_EXCP_CODE_OFFSET 0U
#define MCAUSE_EXCP_CODE_MASK (0x7FFFFFFFU)

#define MCAUSE_EXCP_INSTRUCTION_ADDRESS_MISALIGNED 0U // Instruction address misaligned
#define MCAUSE_EXCP_INSTRUCTION_ACCESS_FAULT 1U       // Instruction access fault
#define MCAUSE_EXCP_ILLEGAL_INSTRUCTION 2U            // Illegal instruction
#define MCAUSE_EXCP_BREAKPOINT 3U                     // Breakpoint
#define MCAUSE_EXCP_LOAD_ADDRESS_MISALIGNED 4U        // Load address misaligned
#define MCAUSE_EXCP_LOAD_ACCESS_FAULT 5U              // Load access fault
#define MCAUSE_EXCP_STORE_AMO_ADDRESS_MISALIGNED 6U   // Store/AMO address misaligned
#define MCAUSE_EXCP_STORE_AMO_ACCESS_FAULT 7U         // Store/AMO access fault
#define MCAUSE_EXCP_ENVIRONMENT_CALL_FROM_U_MODE 8U   // Environment call from U-mode
#define MCAUSE_EXCP_ENVIRONMENT_CALL_FROM_S_MODE 9U   // Environment call from S-mode
#define MCAUSE_EXCP_RESERVED10 10U                    // Reserved
#define MCAUSE_EXCP_ENVIRONMENT_CALL_FROM_M_MODE 11U  // Environment call from M-mode
#define MCAUSE_EXCP_INSTRUCTION_PAGE_FAULT 12U        // Instruction page fault
#define MCAUSE_EXCP_LOAD_PAGE_FAULT 13U               // Load page fault
#define MCAUSE_EXCP_RESERVED14 14U                    // Reserved
#define MCAUSE_EXCP_STORE_AMO_PAGE_FAULT 15U          // Store/AMO page fault

// GCC assembler template:
// asm asm-qualifiers ( AssemblerTemplate
//                    : OutputOperands
//                  [ : InputOperands
//                  [ : Clobbers ] ])

// asm asm-qualifiers (    AssemblerTemplate
//                       : OutputOperands
//                       : InputOperands
//                       : Clobbers
//                       : GotoLabels)

/// Read machine ISA register misa
static inline uint32_t csr_read_misa()
{
  uint32_t value;
  __ASM_VOLATILE("csrr %0, misa"
                 : "=r"(value));
  return value;
}

/// Write machine ISA register misa
static inline void csr_write_misa(uint32_t value)
{
  __ASM_VOLATILE("csrw misa, %0"
                 :
                 : "r"(value));
}

/// Read and write machine ISA register misa
static inline uint32_t csr_read_write_misa(uint32_t new_value)
{
  uint32_t prev_value;
  __ASM_VOLATILE("csrrw %0, misa, %1"
                 : "=r"(prev_value)
                 : "r"(new_value));
  return prev_value;
}

/// Read machine vendor ID register mvendorid
static inline uint32_t csr_read_mvendorid(void)
{
  uint32_t value;
  __ASM_VOLATILE("csrr %0, mvendorid"
                 : "=r"(value));
  return value;
}

/// Read machine architecture ID register marchid
static inline uint32_t csr_read_marchid(void)
{
  uint32_t value;
  __ASM_VOLATILE("csrr %0, marchid"
                 : "=r"(value));
  return value;
}

/// Read machine implementation ID register mimpid
static inline uint32_t csr_read_mimpid(void)
{
  uint32_t value;
  __ASM_VOLATILE("csrr %0, mimpid"
                 : "=r"(value));
  return value;
}

/// Read hart ID register mhartid
static inline uint32_t csr_read_mhartid(void)
{
  uint32_t value;
  __ASM_VOLATILE("csrr %0, mhartid"
                 : "=r"(value));
  return value;
}

/// Read machine status registers
static inline uint32_t csr_read_mstatus(void)
{
  uint32_t value;
  __ASM_VOLATILE("csrr %0, mstatus"
                 : "=r"(value));
  return value;
}

/// Write machine status registers
static inline void csr_write_mstatus(uint32_t value)
{
  __ASM_VOLATILE("csrw mstatus, %0"
                 :
                 : "r"(value));
}

/// Read and write machine status registers
static inline uint32_t csr_read_write_mstatus(uint32_t new_value)
{
  uint32_t prev_value;
  __ASM_VOLATILE("csrrw %0, mstatus, %1"
                 : "=r"(prev_value)
                 : "r"(new_value));
  return prev_value;
}

/// Set bits machine status registers
static inline void csr_set_bits_mstatus(uint32_t mask)
{
  __ASM_VOLATILE("csrrs zero, mstatus, %0"
                 :
                 : "r"(mask));
}

/// Clear bits machine status registers
static inline void csr_clr_bits_mstatus(uint32_t mask)
{
  __ASM_VOLATILE("csrrc zero, mstatus, %0"
                 :
                 : "r"(mask));
}

/// Read and set bits machine status registers
static inline uint32_t csr_read_set_bits_mstatus(uint32_t mask)
{
  uint32_t value;
  __ASM_VOLATILE("csrrs %0, mstatus, %1"
                 : "=r"(value)
                 : "r"(mask));
  return value;
}

/// Read and clear bits machine status registers
static inline uint32_t csr_read_clr_bits_mstatus(uint32_t mask)
{
  uint32_t value;
  __ASM_VOLATILE("csrrc %0, mstatus, %1"
                 : "=r"(value)
                 : "r"(mask));
  return value;
}

/// Write immediate machine status registers (only up to 5 bits)
static inline void csr_write_imm_mstatus(uint32_t value)
{
  __ASM_VOLATILE("csrrwi zero, mstatus, %0"
                 :
                 : "i"(value));
}

/// Set bits machine status registers (only up to 5 bits)
static inline void csr_set_bits_imm_mstatus(uint32_t mask)
{
  __ASM_VOLATILE("csrrsi zero, mstatus, %0"
                 :
                 : "i"(mask));
}

/// Clear bits machine status registers (only up to 5 bits)
static inline void csr_clr_bits_imm_mstatus(uint32_t mask)
{
  __ASM_VOLATILE("csrrci zero, mstatus, %0"
                 :
                 : "i"(mask));
}

/// Read machine trap-vector base-address register
static inline uint32_t csr_read_mtvec(void)
{
  uint32_t value;
  __ASM_VOLATILE("csrr %0, mtvec"
                 : "=r"(value));
  return value;
}

/// Write machine trap-vector base-address register
static inline void csr_write_mtvec(uint32_t value)
{
  __ASM_VOLATILE("csrw mtvec, %0"
                 :
                 : "r"(value));
}

/// Read and write machine trap-vector base-address register
static inline uint32_t csr_read_write_mtvec(uint32_t new_value)
{
  uint32_t prev_value;
  __ASM_VOLATILE("csrrw %0, mtvec, %1"
                 : "=r"(prev_value)
                 : "r"(new_value));
  return prev_value;
}

/// Set bits machine trap-vector base-address register
static inline void csr_set_bits_mtvec(uint32_t mask)
{
  __ASM_VOLATILE("csrrs zero, mtvec, %0"
                 :
                 : "r"(mask));
}

/// Clear bits machine trap-vector base-address register
static inline void csr_clr_bits_mtvec(uint32_t mask)
{
  __ASM_VOLATILE("csrrc zero, mtvec, %0"
                 :
                 : "r"(mask));
}

/// Read and set bits machine trap-vector base-address register
static inline uint32_t csr_read_set_bits_mtvec(uint32_t mask)
{
  uint32_t value;
  __ASM_VOLATILE("csrrs %0, mtvec, %1"
                 : "=r"(value)
                 : "r"(mask));
  return value;
}

/// Read and clear bits machine trap-vector base-address register
static inline uint32_t csr_read_clr_bits_mtvec(uint32_t mask)
{
  uint32_t value;
  __ASM_VOLATILE("csrrc %0, mtvec, %1"
                 : "=r"(value)
                 : "r"(mask));
  return value;
}

/// Write immediate machine trap-vector base-address register (only up to 5 bits)
static inline void csr_write_imm_mtvec(uint32_t value)
{
  __ASM_VOLATILE("csrrwi zero, mtvec, %0"
                 :
                 : "i"(value));
}

/// Set bits machine trap-vector base-address register (only up to 5 bits)
static inline void csr_set_bits_imm_mtvec(uint32_t mask)
{
  __ASM_VOLATILE("csrrsi zero, mtvec, %0"
                 :
                 : "i"(mask));
}

/// Clear bits machine trap-vector base-address register (only up to 5 bits)
static inline void csr_clr_bits_imm_mtvec(uint32_t mask)
{
  __ASM_VOLATILE("csrrci zero, mtvec, %0"
                 :
                 : "i"(mask));
}

/// Read machine interrupt registers mip
static inline uint32_t csr_read_mip(void)
{
  uint32_t value;
  __ASM_VOLATILE("csrr %0, mip"
                 : "=r"(value)
                 :);
  return value;
}

/// Write machine interrupt registers mip
static inline void csr_write_mip(uint32_t value)
{
  __ASM_VOLATILE("csrw mip, %0"
                 :
                 : "r"(value));
}

/// Read and write machine interrupt registers mip
static inline uint32_t csr_read_write_mip(uint32_t new_value)
{
  uint32_t prev_value;
  __ASM_VOLATILE("csrrw %0, mip, %1"
                 : "=r"(prev_value)
                 : "r"(new_value));
  return prev_value;
}

/// Set bits machine interrupt registers mip
static inline void csr_set_bits_mip(uint32_t mask)
{
  __ASM_VOLATILE("csrrs zero, mip, %0"
                 :
                 : "r"(mask));
}

/// Clear bits machine interrupt registers mip
static inline void csr_clr_bits_mip(uint32_t mask)
{
  __ASM_VOLATILE("csrrc zero, mip, %0"
                 :
                 : "r"(mask));
}

/// Read and set bits machine interrupt registers mip
static inline uint32_t csr_read_set_bits_mip(uint32_t mask)
{
  uint32_t value;
  __ASM_VOLATILE("csrrs %0, mip, %1"
                 : "=r"(value)
                 : "r"(mask));
  return value;
}

/// Read and clear bits machine interrupt registers mip
static inline uint32_t csr_read_clr_bits_mip(uint32_t mask)
{
  uint32_t value;
  __ASM_VOLATILE("csrrc %0, mip, %1"
                 : "=r"(value)
                 : "r"(mask));
  return value;
}

/// Write immediate machine interrupt registers mip (only up to 5 bits)
static inline void csr_write_imm_mip(uint32_t value)
{
  __ASM_VOLATILE("csrrwi zero, mip, %0"
                 :
                 : "i"(value));
}

/// Set bits machine interrupt registers mip (only up to 5 bits)
static inline void csr_set_bits_imm_mip(uint32_t mask)
{
  __ASM_VOLATILE("csrrsi zero, mip, %0"
                 :
                 : "i"(mask));
}

/// Clear bits machine interrupt registers mip (only up to 5 bits)
static inline void csr_clr_bits_imm_mip(uint32_t mask)
{
  __ASM_VOLATILE("csrrci zero, mip, %0"
                 :
                 : "i"(mask));
}

/// Read machine interrupt registers mie
static inline uint32_t csr_read_mie(void)
{
  uint32_t value;
  __ASM_VOLATILE("csrr %0, mie"
                 : "=r"(value)
                 :);
  return value;
}

/// Write machine interrupt registers mie
static inline void csr_write_mie(uint32_t value)
{
  __ASM_VOLATILE("csrw mie, %0"
                 :
                 : "r"(value));
}

/// Read and write machine interrupt registers mie
static inline uint32_t csr_read_write_mie(uint32_t new_value)
{
  uint32_t prev_value;
  __ASM_VOLATILE("csrrw %0, mie, %1"
                 : "=r"(prev_value)
                 : "r"(new_value));
  return prev_value;
}

/// Set bits machine interrupt registers mie
static inline void csr_set_bits_mie(uint32_t mask)
{
  __ASM_VOLATILE("csrrs zero, mie, %0"
                 :
                 : "r"(mask));
}

/// Clear bits machine interrupt registers mie
static inline void csr_clr_bits_mie(uint32_t mask)
{
  __ASM_VOLATILE("csrrc zero, mie, %0"
                 :
                 : "r"(mask));
}

/// Read and set bits machine interrupt registers mie
static inline uint32_t csr_read_set_bits_mie(uint32_t mask)
{
  uint32_t value;
  __ASM_VOLATILE("csrrs %0, mie, %1"
                 : "=r"(value)
                 : "r"(mask));
  return value;
}

/// Read and clear bits machine interrupt registers mie
static inline uint32_t csr_read_clr_bits_mie(uint32_t mask)
{
  uint32_t value;
  __ASM_VOLATILE("csrrc %0, mie, %1"
                 : "=r"(value)
                 : "r"(mask));
  return value;
}

/// Write immediate machine interrupt registers mie (only up to 5 bits)
static inline void csr_write_imm_mie(uint32_t value)
{
  __ASM_VOLATILE("csrrwi zero, mie, %0"
                 :
                 : "i"(value));
}

/// Set bits machine interrupt registers mie (only up to 5 bits)
static inline void csr_set_bits_imm_mie(uint32_t mask)
{
  __ASM_VOLATILE("csrrsi zero, mie, %0"
                 :
                 : "i"(mask));
}

/// Clear bits machine interrupt registers mie (only up to 5 bits)
static inline void csr_clr_bits_imm_mie(uint32_t mask)
{
  __ASM_VOLATILE("csrrci zero, mie, %0"
                 :
                 : "i"(mask));
}

/// Read machine exception program counter
static inline uint32_t csr_read_mepc(void)
{
  uint32_t value;
  __ASM_VOLATILE("csrr %0, mepc"
                 : "=r"(value)
                 :);
  return value;
}

/// Write machine exception program counter
static inline void csr_write_mepc(uint32_t value)
{
  __ASM_VOLATILE("csrw mepc, %0"
                 :
                 : "r"(value));
}

/// Read and write machine exception program counter
static inline uint32_t csr_read_write_mepc(uint32_t new_value)
{
  uint32_t prev_value;
  __ASM_VOLATILE("csrrw %0, mepc, %1"
                 : "=r"(prev_value)
                 : "r"(new_value));
  return prev_value;
}

/// Read machine cause register
static inline uint32_t csr_read_mcause(void)
{
  uint32_t value;
  __ASM_VOLATILE("csrr %0, mcause"
                 : "=r"(value));
  return value;
}

/// Write machine cause register
static inline void csr_write_mcause(uint32_t value)
{
  __ASM_VOLATILE("csrw mcause, %0"
                 :
                 : "r"(value));
}

/// Read and write machine cause register
static inline uint32_t csr_read_write_mcause(uint32_t new_value)
{
  uint32_t prev_value;
  __ASM_VOLATILE("csrrw %0, mcause, %1"
                 : "=r"(prev_value)
                 : "r"(new_value));
  return prev_value;
}

/// Set bits machine cause register
static inline void csr_set_bits_mcause(uint32_t mask)
{
  __ASM_VOLATILE("csrrs zero, mcause, %0"
                 :
                 : "r"(mask));
}

/// Clear bits machine cause register
static inline void csr_clr_bits_mcause(uint32_t mask)
{
  __ASM_VOLATILE("csrrc zero, mcause, %0"
                 :
                 : "r"(mask));
}

/// Read and set bits machine cause register
static inline uint32_t csr_read_set_bits_mcause(uint32_t mask)
{
  uint32_t value;
  __ASM_VOLATILE("csrrs %0, mcause, %1"
                 : "=r"(value)
                 : "r"(mask));
  return value;
}

/// Read and clear bits machine cause register
static inline uint32_t csr_read_clr_bits_mcause(uint32_t mask)
{
  uint32_t value;
  __ASM_VOLATILE("csrrc %0, mcause, %1"
                 : "=r"(value)
                 : "r"(mask));
  return value;
}

/// Write immediate machine cause register (only up to 5 bits)
static inline void csr_write_imm_mcause(uint32_t value)
{
  __ASM_VOLATILE("csrrwi zero, mcause, %0"
                 :
                 : "i"(value));
}

/// Set bits machine cause register (only up to 5 bits)
static inline void csr_set_bits_imm_mcause(uint32_t mask)
{
  __ASM_VOLATILE("csrrsi zero, mcause, %0"
                 :
                 : "i"(mask));
}

/// Clear bits machine cause register (only up to 5 bits)
static inline void csr_clr_bits_imm_mcause(uint32_t mask)
{
  __ASM_VOLATILE("csrrci zero, mcause, %0"
                 :
                 : "i"(mask));
}

/// Read machine trap value register
static inline uint32_t csr_read_mtval(void)
{
  uint32_t value;
  __ASM_VOLATILE("csrr %0, mtval"
                 : "=r"(value));
  return value;
}

/// Write machine trap value register
static inline void csr_write_mtval(uint32_t value)
{
  __ASM_VOLATILE("csrw mtval, %0"
                 :
                 : "r"(value));
}

/// Read and write trap value register
static inline uint32_t csr_read_write_mtval(uint32_t new_value)
{
  uint32_t prev_value;
  __ASM_VOLATILE("csrrw %0, mtval, %1"
                 : "=r"(prev_value)
                 : "r"(new_value));
  return prev_value;
}

/// Global IRQ enable
static inline void global_enable_irq()
{
  csr_set_bits_imm_mstatus(MSTATUS_MIE_MASK);
}

/// Gloabl IRQ disable
static inline void global_disable_irq()
{
  csr_clr_bits_imm_mstatus(MSTATUS_MIE_MASK);
}

/// Machine Interrupt-Enable
static inline void enable_irq(uint32_t offset_irq)
{
  csr_set_bits_mie(offset_irq);
}

/// Machine Interrupt-Disable
static inline void disable_irq(uint32_t offset_irq)
{
  csr_clr_bits_mie(offset_irq);
}

/// Machine trap-vector mode enable
static inline void enable_vector_mod_irq()
{
  csr_set_bits_imm_mtvec(1U);
}

/// Machine trap-vector mode disable
static inline void disable_vector_mod_irq()
{
  csr_clr_bits_imm_mtvec(1U);
}

#endif // __RVSTEEL_CSR__
