`ifndef __RVX__CONSTANTS__VH__
`define __RVX__CONSTANTS__VH__

/* ------------------------------------------------------------------
 * Control and Status Registers (CSRs) Addresses
 *
 * The addresses below are defined according to the
 * RISC-V Instruction Set Manual Volume II v20250508,
 * Section 2.2 "CSR Listing".
 * ------------------------------------------------------------------ */

// User Mode Performance Counters
`define RISCV_CSR_UCYCLE_ADDR 12'hC00
`define RISCV_CSR_UTIME_ADDR 12'hC01
`define RISCV_CSR_UINSTRET_ADDR 12'hC02
`define RISCV_CSR_UCYCLEH_ADDR 12'hC80
`define RISCV_CSR_UTIMEH_ADDR 12'hC81
`define RISCV_CSR_UINSTRETH_ADDR 12'hC82

// Machine Information
`define RISCV_CSR_MVENDORID_ADDR 12'hF11
`define RISCV_CSR_MARCHID_ADDR 12'hF12
`define RISCV_CSR_MIMPID_ADDR 12'hF13

// Machine Trap Setup
`define RISCV_CSR_MSTATUS_ADDR 12'h300
`define RISCV_CSR_MSTATUSH_ADDR 12'h310
`define RISCV_CSR_MISA_ADDR 12'h301
`define RISCV_CSR_MIE_ADDR 12'h304
`define RISCV_CSR_MTVEC_ADDR 12'h305

// Machine Trap Handling
`define RISCV_CSR_MSCRATCH_ADDR 12'h340
`define RISCV_CSR_MEPC_ADDR 12'h341
`define RISCV_CSR_MCAUSE_ADDR 12'h342
`define RISCV_CSR_MTVAL_ADDR 12'h343
`define RISCV_CSR_MIP_ADDR 12'h344

// Machine Performance Counters
`define RISCV_CSR_MCYCLE_ADDR 12'hB00
`define RISCV_CSR_MINSTRET_ADDR 12'hB02
`define RISCV_CSR_MCYCLEH_ADDR 12'hB80
`define RISCV_CSR_MINSTRETH_ADDR 12'hB82

/* ------------------------------------------------------------------
 * RISC-V ISA Instruction Encodings
 *
 * The macros below define opcodes, funct3, funct7, rs1, rs2 and rd
 * values for various RISC-V instructions according to the
 * RISC-V Instruction Set Manual Volume I v20250508.
 * ------------------------------------------------------------------ */

// Immediate format selection
`define RISCV_I_TYPE_IMMEDIATE 3'b001
`define RISCV_S_TYPE_IMMEDIATE 3'b010
`define RISCV_B_TYPE_IMMEDIATE 3'b011
`define RISCV_U_TYPE_IMMEDIATE 3'b100
`define RISCV_J_TYPE_IMMEDIATE 3'b101
`define RISCV_CSR_TYPE_IMMEDIATE 3'b110

// Opcodes
`define RISCV_OPCODE_OP 7'b0110011
`define RISCV_OPCODE_OP_IMM 7'b0010011
`define RISCV_OPCODE_LOAD 7'b0000011
`define RISCV_OPCODE_STORE 7'b0100011
`define RISCV_OPCODE_BRANCH 7'b1100011
`define RISCV_OPCODE_JAL 7'b1101111
`define RISCV_OPCODE_JALR 7'b1100111
`define RISCV_OPCODE_LUI 7'b0110111
`define RISCV_OPCODE_AUIPC 7'b0010111
`define RISCV_OPCODE_MISC_MEM 7'b0001111
`define RISCV_OPCODE_SYSTEM 7'b1110011

// FUNCT3
`define RISCV_FUNCT3_ADD 3'b000
`define RISCV_FUNCT3_SUB 3'b000
`define RISCV_FUNCT3_SLT 3'b010
`define RISCV_FUNCT3_SLTU 3'b011
`define RISCV_FUNCT3_AND 3'b111
`define RISCV_FUNCT3_OR 3'b110
`define RISCV_FUNCT3_XOR 3'b100
`define RISCV_FUNCT3_SLL 3'b001
`define RISCV_FUNCT3_SRL 3'b101
`define RISCV_FUNCT3_SRA 3'b101
`define RISCV_FUNCT3_ADDI 3'b000
`define RISCV_FUNCT3_SLTI 3'b010
`define RISCV_FUNCT3_SLTIU 3'b011
`define RISCV_FUNCT3_ANDI 3'b111
`define RISCV_FUNCT3_ORI 3'b110
`define RISCV_FUNCT3_XORI 3'b100
`define RISCV_FUNCT3_SLLI 3'b001
`define RISCV_FUNCT3_SRLI 3'b101
`define RISCV_FUNCT3_SRAI 3'b101
`define RISCV_FUNCT3_BEQ 3'b000
`define RISCV_FUNCT3_BNE 3'b001
`define RISCV_FUNCT3_BLT 3'b100
`define RISCV_FUNCT3_BGE 3'b101
`define RISCV_FUNCT3_BLTU 3'b110
`define RISCV_FUNCT3_BGEU 3'b111
`define RISCV_FUNCT3_SB 3'b000
`define RISCV_FUNCT3_SH 3'b001
`define RISCV_FUNCT3_SW 3'b010
`define RISCV_FUNCT3_ECALL 3'b000
`define RISCV_FUNCT3_EBREAK 3'b000
`define RISCV_FUNCT3_MRET 3'b000

`define RISCV_FUNCT3_MUL 3'b000
`define RISCV_FUNCT3_MULH 3'b001
`define RISCV_FUNCT3_MULHSU 3'b010
`define RISCV_FUNCT3_MULHU 3'b011

// FUNCT7
`define RISCV_FUNCT7_SUB 7'b0100000
`define RISCV_FUNCT7_SRA 7'b0100000
`define RISCV_FUNCT7_ADD 7'b0000000
`define RISCV_FUNCT7_SLT 7'b0000000
`define RISCV_FUNCT7_SLTU 7'b0000000
`define RISCV_FUNCT7_AND 7'b0000000
`define RISCV_FUNCT7_OR 7'b0000000
`define RISCV_FUNCT7_XOR 7'b0000000
`define RISCV_FUNCT7_SLL 7'b0000000
`define RISCV_FUNCT7_SRL 7'b0000000
`define RISCV_FUNCT7_SRAI 7'b0100000
`define RISCV_FUNCT7_SLLI 7'b0000000
`define RISCV_FUNCT7_SRLI 7'b0000000
`define RISCV_FUNCT7_ECALL 7'b0000000
`define RISCV_FUNCT7_EBREAK 7'b0000000
`define RISCV_FUNCT7_MRET 7'b0011000

`define RISCV_FUNCT7_MUL 7'b0000001
`define RISCV_FUNCT7_MULH 7'b0000001
`define RISCV_FUNCT7_MULHSU 7'b0000001
`define RISCV_FUNCT7_MULHU 7'b0000001

// RS1, RS2 and RD encodings for SYSTEM instructions
`define RISCV_RS1_ECALL 5'b00000
`define RISCV_RS1_EBREAK 5'b00000
`define RISCV_RS1_MRET 5'b00000
`define RISCV_RS2_ECALL 5'b00000
`define RISCV_RS2_EBREAK 5'b00001
`define RISCV_RS2_MRET 5'b00010
`define RISCV_RD_ECALL 5'b00000
`define RISCV_RD_EBREAK 5'b00000
`define RISCV_RD_MRET 5'b00000

// No operation
`define RISCV_NOP_INSTRUCTION 32'h00000013

/* ------------------------------------------------------------------
 * RVX Core Constants
 * ------------------------------------------------------------------ */

// Encoding for CSR operations
`define RVX_CSR_OPERATION_RW 2'b01
`define RVX_CSR_OPERATION_RS 2'b10
`define RVX_CSR_OPERATION_RC 2'b11

// Writeback Mux data source selection
`define RVX_WB_ALU 3'b000
`define RVX_WB_LOAD_UNIT 3'b001
`define RVX_WB_UPPER_IMM 3'b010
`define RVX_WB_TARGET_ADDER 3'b011
`define RVX_WB_CSR 3'b100
`define RVX_WB_PC_PLUS_4 3'b101
`define RVX_WB_MDU 3'b110

// Program Counter source selection
`define RVX_PC_BOOT 2'b00
`define RVX_PC_EPC 2'b01
`define RVX_PC_TRAP 2'b10
`define RVX_PC_NEXT 2'b11

// Load size encoding
`define RVX_LOAD_SIZE_BYTE 2'b00
`define RVX_LOAD_SIZE_HALF 2'b01
`define RVX_LOAD_SIZE_WORD 2'b10

// One-hot encoding of the processor core FSM states
`define RVX_STATE_RESET 4'b0001
`define RVX_STATE_OPERATING 4'b0010
`define RVX_STATE_TRAP_TAKEN 4'b0100
`define RVX_STATE_TRAP_RETURN 4'b1000

// UART register addresses
`define RVX_UART_WRITE_REG_ADDR 5'h00
`define RVX_UART_READ_REG_ADDR 5'h04
`define RVX_UART_STATUS_REG_ADDR 5'h08
`define RVX_UART_BAUD_REG_ADDR 5'h0c

// SPI register addresses
`define RVX_SPI_MODE_REG_ADDR 5'h00
`define RVX_SPI_CHIP_SELECT_REG_ADDR 5'h04
`define RVX_SPI_DIVIDER_REG_ADDR 5'h08
`define RVX_SPI_WRITE_REG_ADDR 5'h0c
`define RVX_SPI_READ_REG_ADDR 5'h10
`define RVX_SPI_STATUS_REG_ADDR 5'h14

// Timer register addresses
`define RVX_TIMER_COUNTER_ENABLE_REG_ADDR 5'h00
`define RVX_TIMER_COUNTERL_REG_ADDR 5'h04
`define RVX_TIMER_COUNTERH_REG_ADDR 5'h08
`define RVX_TIMER_COMPAREL_REG_ADDR 5'h0c
`define RVX_TIMER_COMPAREH_REG_ADDR 5'h10

`endif
