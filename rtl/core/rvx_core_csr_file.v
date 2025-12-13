// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_core_constants.vh"

module rvx_core_csr_file (

    // Global signals
    input wire clock,
    input wire clock_enable,
    input wire reset_n,

    // From pipeline stage 1
    input wire [ 3:0] core_state_s1,
    input wire        ebreak_s1,
    input wire        ecall_s1,
    input wire        illegal_instruction_s1,
    input wire        irq_external_s1,
    input wire [15:0] irq_fast_s1,
    input wire        irq_software_s1,
    input wire        irq_timer_s1,
    input wire [63:0] memory_mapped_timer_s1,
    input wire        misaligned_instruction_address_s1,
    input wire        misaligned_load_s1,
    input wire        misaligned_store_s1,
    input wire [31:0] program_counter_s1,
    input wire        take_trap_s1,
    input wire [31:0] target_address_s1,

    // From pipeline stage 2
    input wire [11:0] csr_address_s2,
    input wire [ 2:0] csr_operation_s2,
    input wire        csr_write_request_s2,
    input wire [ 4:0] immediate_4_0_s2,
    input wire [31:0] rs1_data_s2,

    // Data output
    output reg [31:0] csr_data_out_s2,

    // Trap, exception and interrupt handling signals
    output wire [31:0] exception_address_s1,
    output wire        global_interrupt_enable_s1,
    output wire        interrupt_pending_s1,
    output wire [31:0] trap_handler_address_s1

);

  wire [31:0] interrupt_address_offset;
  wire        misaligned_address_exception;
  wire [31:0] csr_data_mask;

  wire [31:0] csr_mstatus;
  reg         csr_mstatus_mie;
  reg         csr_mstatus_mpie;
  wire [31:0] csr_mie;
  reg  [15:0] csr_mie_mfie;
  reg         csr_mie_meie;
  reg         csr_mie_msie;
  reg         csr_mie_mtie;
  wire [31:0] csr_mip;
  reg  [15:0] csr_mip_mfip;
  reg         csr_mip_meip;
  reg         csr_mip_msip;
  reg         csr_mip_mtip;
  reg  [31:0] csr_mepc;
  reg  [31:0] csr_mtvec;
  reg  [31:0] csr_mcause;
  reg  [ 4:0] csr_mcause_code;
  reg         csr_mcause_interrupt_flag;
  reg  [31:0] csr_mtval;
  reg  [31:0] csr_mscratch;
  reg  [63:0] csr_minstret;
  reg  [63:0] csr_mcycle;
  reg  [63:0] csr_utime;
  reg  [31:0] csr_write_data;

  assign csr_data_mask = csr_operation_s2[2] == 1'b1 ? {27'b0, immediate_4_0_s2} : rs1_data_s2;

  assign misaligned_address_exception = misaligned_load_s1 | misaligned_store_s1 | misaligned_instruction_address_s1;

  assign interrupt_address_offset = {{25{1'b0}}, csr_mcause_code, 2'b00};

  assign trap_handler_address_s1 = (csr_mtvec[1:0] == 2'b01 && csr_mcause_interrupt_flag) ?
      {csr_mtvec[31:2], 2'b00} + interrupt_address_offset : {csr_mtvec[31:2], 2'b00};

  assign interrupt_pending_s1 = (csr_mie_meie & csr_mip_meip) | (csr_mie_mtie & csr_mip_mtip) |
      (csr_mie_msie & csr_mip_msip) | (|(csr_mie_mfie & csr_mip_mfip));

  assign global_interrupt_enable_s1 = csr_mstatus_mie;

  assign exception_address_s1 = csr_mepc;

  assign csr_mstatus = {
    19'b0,
    2'b11,  // M-mode Prior Privilege (always M-mode)
    3'b0,
    csr_mstatus_mpie,  // M-mode Prior Global Interrupt Enable
    3'b0,
    csr_mstatus_mie,  // M-mode Global Interrupt Enable
    3'b0
  };

  assign csr_mie = {
    csr_mie_mfie,  // RVX Fast Interrupt Enable
    4'b0,
    csr_mie_meie,  // M-mode External Interrupt Enable
    3'b0,
    csr_mie_mtie,  // M-mode Timer Interrupt Enable
    3'b0,
    csr_mie_msie,  // M-mode Software Interrupt Enable
    3'b0
  };

  assign csr_mip = {
    csr_mip_mfip,  // RVX Fast Interrupt Pending
    4'b0,
    csr_mip_meip,  // M-mode External Interrupt Pending
    3'b0,
    csr_mip_mtip,  // M-mode Timer Interrupt Pending
    3'b0,
    csr_mip_msip,  // M-mode Software Interrupt Pending
    3'b0
  };

  always @* begin : csr_write_data_mux
    case (csr_operation_s2[1:0])
      `RVX_CSR_OPERATION_RW: csr_write_data = csr_data_mask;
      `RVX_CSR_OPERATION_RS: csr_write_data = csr_data_out_s2 | csr_data_mask;
      `RVX_CSR_OPERATION_RC: csr_write_data = csr_data_out_s2 & ~csr_data_mask;
      default:               csr_write_data = csr_data_out_s2;
    endcase
  end

  always @* begin : csr_data_out_mux
    case (csr_address_s2)
      `RISCV_CSR_MARCHID_ADDR:   csr_data_out_s2 = 32'h00000018;  // RVX microarchitecture ID
      `RISCV_CSR_MIMPID_ADDR:    csr_data_out_s2 = 32'h00000007;  // Version 4.0.0
      `RISCV_CSR_UCYCLE_ADDR:    csr_data_out_s2 = csr_mcycle[31:0];
      `RISCV_CSR_UCYCLEH_ADDR:   csr_data_out_s2 = csr_mcycle[63:32];
      `RISCV_CSR_UTIME_ADDR:     csr_data_out_s2 = csr_utime[31:0];
      `RISCV_CSR_UTIMEH_ADDR:    csr_data_out_s2 = csr_utime[63:32];
      `RISCV_CSR_UINSTRET_ADDR:  csr_data_out_s2 = csr_minstret[31:0];
      `RISCV_CSR_UINSTRETH_ADDR: csr_data_out_s2 = csr_minstret[63:32];
      `RISCV_CSR_MSTATUS_ADDR:   csr_data_out_s2 = csr_mstatus;
      `RISCV_CSR_MSTATUSH_ADDR:  csr_data_out_s2 = 32'h00000000;
      `RISCV_CSR_MISA_ADDR:      csr_data_out_s2 = 32'h40000100;  // RV32I base ISA only
      `RISCV_CSR_MIE_ADDR:       csr_data_out_s2 = csr_mie;
      `RISCV_CSR_MTVEC_ADDR:     csr_data_out_s2 = csr_mtvec;
      `RISCV_CSR_MSCRATCH_ADDR:  csr_data_out_s2 = csr_mscratch;
      `RISCV_CSR_MEPC_ADDR:      csr_data_out_s2 = csr_mepc;
      `RISCV_CSR_MCAUSE_ADDR:    csr_data_out_s2 = csr_mcause;
      `RISCV_CSR_MTVAL_ADDR:     csr_data_out_s2 = csr_mtval;
      `RISCV_CSR_MIP_ADDR:       csr_data_out_s2 = csr_mip;
      `RISCV_CSR_MCYCLE_ADDR:    csr_data_out_s2 = csr_mcycle[31:0];
      `RISCV_CSR_MCYCLEH_ADDR:   csr_data_out_s2 = csr_mcycle[63:32];
      `RISCV_CSR_MINSTRET_ADDR:  csr_data_out_s2 = csr_minstret[31:0];
      `RISCV_CSR_MINSTRETH_ADDR: csr_data_out_s2 = csr_minstret[63:32];
      default:                   csr_data_out_s2 = 32'h00000000;
    endcase
  end

  always @(posedge clock) begin : csr_mstatus_update
    if (!reset_n) begin
      csr_mstatus_mie  <= 1'b0;
      csr_mstatus_mpie <= 1'b1;
    end
    else if (clock_enable) begin
      if (core_state_s1 == `RVX_STATE_TRAP_RETURN) begin
        csr_mstatus_mie  <= csr_mstatus_mpie;
        csr_mstatus_mpie <= 1'b1;
      end
      else if (core_state_s1 == `RVX_STATE_TRAP_TAKEN) begin
        csr_mstatus_mpie <= csr_mstatus_mie;
        csr_mstatus_mie  <= 1'b0;
      end
      else if (core_state_s1 == `RVX_STATE_OPERATING && csr_address_s2 == `RISCV_CSR_MSTATUS_ADDR &&
               csr_write_request_s2) begin
        csr_mstatus_mie  <= csr_write_data[3];
        csr_mstatus_mpie <= csr_write_data[7];
      end
    end
  end

  always @(posedge clock) begin : csr_mie_update
    if (!reset_n) begin
      csr_mie_mfie <= 16'b0;
      csr_mie_meie <= 1'b0;
      csr_mie_mtie <= 1'b0;
      csr_mie_msie <= 1'b0;
    end
    else if (clock_enable & csr_address_s2 == `RISCV_CSR_MIE_ADDR && csr_write_request_s2) begin
      csr_mie_mfie <= csr_write_data[31:16];
      csr_mie_meie <= csr_write_data[11];
      csr_mie_mtie <= csr_write_data[7];
      csr_mie_msie <= csr_write_data[3];
    end
  end

  always @(posedge clock) begin : csr_mip_update
    if (!reset_n) begin
      csr_mip_mfip <= 16'b0;
      csr_mip_meip <= 1'b0;
      csr_mip_mtip <= 1'b0;
      csr_mip_msip <= 1'b0;
    end
    else begin
      csr_mip_mfip <= irq_fast_s1;
      csr_mip_meip <= irq_external_s1;
      csr_mip_mtip <= irq_timer_s1;
      csr_mip_msip <= irq_software_s1;
    end
  end

  always @(posedge clock) begin : csr_mepc_update
    if (!reset_n) csr_mepc <= 32'h00000000;
    else if (clock_enable) begin
      if (take_trap_s1) csr_mepc <= program_counter_s1;
      else if (core_state_s1 == `RVX_STATE_OPERATING && csr_address_s2 == `RISCV_CSR_MEPC_ADDR && csr_write_request_s2)
        csr_mepc <= {csr_write_data[31:2], 2'b00};
    end
  end

  always @(posedge clock) begin : csr_mscratch_update
    if (!reset_n) csr_mscratch <= 32'h00000000;
    else if (clock_enable & csr_address_s2 == `RISCV_CSR_MSCRATCH_ADDR && csr_write_request_s2)
      csr_mscratch <= csr_write_data;
  end

  always @(posedge clock) begin : csr_mcycle_update
    if (!reset_n) csr_mcycle <= 64'b0;
    else begin
      if (clock_enable & csr_address_s2 == `RISCV_CSR_MCYCLE_ADDR && csr_write_request_s2)
        csr_mcycle <= {csr_mcycle[63:32], csr_write_data} + 1;
      else if (clock_enable & csr_address_s2 == `RISCV_CSR_MCYCLEH_ADDR && csr_write_request_s2)
        csr_mcycle <= {csr_write_data, csr_mcycle[31:0]} + 1;
      else csr_mcycle <= csr_mcycle + 1;
    end
  end

  always @(posedge clock) begin : csr_minstret_update
    if (!reset_n) csr_minstret <= 64'b0;
    else if (clock_enable) begin
      if (csr_address_s2 == `RISCV_CSR_MINSTRET_ADDR && csr_write_request_s2) begin
        if (core_state_s1 == `RVX_STATE_OPERATING) csr_minstret <= {csr_minstret[63:32], csr_write_data} + 1;
        else csr_minstret <= {csr_minstret[63:32], csr_write_data};
      end
      else if (csr_address_s2 == `RISCV_CSR_MINSTRETH_ADDR && csr_write_request_s2) begin
        if (core_state_s1 == `RVX_STATE_OPERATING) csr_minstret <= {csr_write_data, csr_minstret[31:0]} + 1;
        else csr_minstret <= {csr_write_data, csr_minstret[31:0]};
      end
      else begin
        if (core_state_s1 == `RVX_STATE_OPERATING) csr_minstret <= csr_minstret + 1;
        else csr_minstret <= csr_minstret;
      end
    end
  end

  always @(posedge clock) begin : csr_utime_update
    csr_utime <= memory_mapped_timer_s1;
  end

  always @(posedge clock) begin : csr_mcause_update
    if (!reset_n) csr_mcause <= 32'h00000000;
    else if (clock_enable) begin
      if (core_state_s1 == `RVX_STATE_TRAP_TAKEN) csr_mcause <= {csr_mcause_interrupt_flag, 26'b0, csr_mcause_code};
      else
          if (core_state_s1 == `RVX_STATE_OPERATING && csr_address_s2 == `RISCV_CSR_MCAUSE_ADDR && csr_write_request_s2)
        csr_mcause <= csr_write_data;
    end
  end

  always @(posedge clock) begin : csr_mcause_code_update
    if (!reset_n) begin
      csr_mcause_code           <= 5'd0;
      csr_mcause_interrupt_flag <= 1'b0;
    end
    if (clock_enable & core_state_s1 == `RVX_STATE_OPERATING) begin
      if (misaligned_instruction_address_s1) begin
        csr_mcause_code           <= 5'd0;
        csr_mcause_interrupt_flag <= 1'b0;
      end
      else if (illegal_instruction_s1) begin
        csr_mcause_code           <= 5'd2;
        csr_mcause_interrupt_flag <= 1'b0;
      end
      else if (ebreak_s1) begin
        csr_mcause_code           <= 5'd3;
        csr_mcause_interrupt_flag <= 1'b0;
      end
      else if (misaligned_load_s1) begin
        csr_mcause_code           <= 5'd4;
        csr_mcause_interrupt_flag <= 1'b0;
      end
      else if (misaligned_store_s1) begin
        csr_mcause_code           <= 5'd6;
        csr_mcause_interrupt_flag <= 1'b0;
      end
      else if (ecall_s1) begin
        csr_mcause_code           <= 5'd11;
        csr_mcause_interrupt_flag <= 1'b0;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[0] & csr_mip_mfip[0]) begin
        csr_mcause_code           <= 5'd16;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[1] & csr_mip_mfip[1]) begin
        csr_mcause_code           <= 5'd17;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[2] & csr_mip_mfip[2]) begin
        csr_mcause_code           <= 5'd18;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[3] & csr_mip_mfip[3]) begin
        csr_mcause_code           <= 5'd19;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[4] & csr_mip_mfip[4]) begin
        csr_mcause_code           <= 5'd20;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[5] & csr_mip_mfip[5]) begin
        csr_mcause_code           <= 5'd21;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[6] & csr_mip_mfip[6]) begin
        csr_mcause_code           <= 5'd22;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[7] & csr_mip_mfip[7]) begin
        csr_mcause_code           <= 5'd23;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[8] & csr_mip_mfip[8]) begin
        csr_mcause_code           <= 5'd24;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[9] & csr_mip_mfip[9]) begin
        csr_mcause_code           <= 5'd25;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[10] & csr_mip_mfip[10]) begin
        csr_mcause_code           <= 5'd26;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[11] & csr_mip_mfip[11]) begin
        csr_mcause_code           <= 5'd27;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[12] & csr_mip_mfip[12]) begin
        csr_mcause_code           <= 5'd28;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[13] & csr_mip_mfip[13]) begin
        csr_mcause_code           <= 5'd29;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[14] & csr_mip_mfip[14]) begin
        csr_mcause_code           <= 5'd30;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mfie[15] & csr_mip_mfip[15]) begin
        csr_mcause_code           <= 5'd31;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_msie & csr_mip_msip) begin
        csr_mcause_code           <= 5'd3;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_mtie & csr_mip_mtip) begin
        csr_mcause_code           <= 5'd7;
        csr_mcause_interrupt_flag <= 1'b1;
      end
      else if (csr_mstatus_mie & csr_mie_meie & csr_mip_meip) begin
        csr_mcause_code           <= 5'd11;
        csr_mcause_interrupt_flag <= 1'b1;
      end
    end
  end

  always @(posedge clock) begin : csr_mtval_update
    if (!reset_n) csr_mtval <= 32'h00000000;
    else if (clock_enable) begin
      if (take_trap_s1) begin
        if (misaligned_address_exception) csr_mtval <= target_address_s1;
        else if (ebreak_s1) csr_mtval <= program_counter_s1;
        else csr_mtval <= 32'h00000000;
      end
      else if (core_state_s1 == `RVX_STATE_OPERATING && csr_address_s2 == `RISCV_CSR_MTVAL_ADDR && csr_write_request_s2)
        csr_mtval <= csr_write_data;
    end
  end

  always @(posedge clock) begin : csr_mtvec_update
    if (!reset_n) csr_mtvec <= 32'h00000000;
    else if (clock_enable & csr_address_s2 == `RISCV_CSR_MTVEC_ADDR && csr_write_request_s2)
      csr_mtvec <= {csr_write_data[31:2], 1'b0, csr_write_data[0]};
  end

endmodule
