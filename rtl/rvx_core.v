// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2025 RVX Project Contributors

`include "rvx_constants.vh"

module rvx_core #(

    parameter [31:0] BOOT_ADDRESS = 32'h00000000

) (

    // Global signals

    input wire clock,
    input wire reset_n,
    input wire halt_n,

    // Instruction bus

    output wire [31:0] ibus_address,
    input  wire [31:0] ibus_rdata,
    output wire        ibus_rrequest,
    input  wire        ibus_rresponse,

    // Data bus

    output wire [31:0] dbus_address,
    input  wire [31:0] dbus_rdata,
    output wire        dbus_rrequest,
    input  wire        dbus_rresponse,
    output wire [31:0] dbus_wdata,
    output wire [ 3:0] dbus_wstrobe,
    output wire        dbus_wrequest,
    input  wire        dbus_wresponse,

    // Interrupt signals

    input  wire        irq_external,
    output wire        irq_external_response,
    input  wire        irq_timer,
    output wire        irq_timer_response,
    input  wire        irq_software,
    output wire        irq_software_response,
    input  wire [15:0] irq_fast,
    output wire [15:0] irq_fast_response,

    // Memory-mapped timer

    input wire [63:0] memory_mapped_timer

);

  // Global clock enable
  // ---------------------------------------------------------------------------

  wire        clock_enable;

  // Pipeline stage 0 signals
  // ---------------------------------------------------------------------------

  wire [31:0] program_counter_s0;

  // Pipeline stage 1 signals
  // ---------------------------------------------------------------------------

  wire        alu_2nd_operand_source_s1;
  wire [ 3:0] alu_operation_code_s1;
  wire        branch_s1;
  wire        csr_write_request_s1;
  wire [ 2:0] csr_operation_s1;
  wire [ 3:0] current_state_s1;
  wire        ebreak_s1;
  wire        ecall_s1;
  wire [31:0] exception_address_s1;
  wire        flush_pipeline_s1;
  wire        global_interrupt_enable_s1;
  wire        illegal_instruction_s1;
  wire [31:0] immediate_s1;
  wire [ 2:0] immediate_type_s1;
  wire        integer_file_write_request_s1;
  wire        interrupt_pending_s1;
  wire [31:0] instruction_s1;
  wire [ 2:0] funct3_s1;
  wire [11:0] csr_address_s1;
  wire [ 4:0] rd_address_s1;
  wire [ 4:0] rs1_address_s1;
  wire [ 4:0] rs2_address_s1;
  wire        jump_s1;
  wire        load_s1;
  wire [ 1:0] load_size_s1;
  wire        load_unsigned_s1;
  wire        misaligned_instruction_address_s1;
  wire        misaligned_load_s1;
  wire        misaligned_store_s1;
  wire        mret_s1;
  wire [31:0] next_program_counter_s1;
  reg  [31:0] program_counter_s1;
  wire [31:0] rs1_data_s1;
  wire [31:0] rs2_data_s1;
  wire        store_s1;
  wire [31:0] store_aligned_data_s1;
  wire [ 3:0] store_strobe_s1;
  wire        take_branch_s1;
  wire        take_trap_s1;
  wire [31:0] target_address_s1;
  wire        target_address_source_s1;
  wire [ 4:0] trap_cause_s1;
  wire [31:0] trap_handler_address_s1;
  wire [ 2:0] writeback_mux_sel_s1;

  // Pipeline stage 2 signals
  // ---------------------------------------------------------------------------

  reg         alu_2nd_operand_source_s2;
  reg  [ 3:0] alu_operation_code_s2;
  wire [31:0] alu_output_s2;
  wire [31:0] csr_data_out_s2;
  reg         csr_write_request_s2;
  reg  [ 2:0] csr_operation_s2;
  reg  [31:0] immediate_s2;
  reg  [11:0] csr_address_s2;
  reg  [ 4:0] instruction_rd_address_s2;
  reg         integer_file_write_request_s2;
  wire [31:0] load_aligned_data_s2;
  reg  [ 1:0] load_size_s2;
  reg         load_unsigned_s2;
  reg  [31:0] program_counter_plus_4_s2;
  reg  [31:0] rs1_data_s2;
  reg  [31:0] rs2_data_s2;
  reg  [31:0] target_address_adder_s2;
  reg  [ 2:0] writeback_mux_sel_s2;
  reg  [31:0] writeback_output_s2;

  wire        prev_dbus_rrequest;
  wire        prev_dbus_wrequest;
  wire        prev_ibus_rrequest;

  // Global clock enable
  // ---------------------------------------------------------------------------

  assign clock_enable = !(!halt_n | (prev_dbus_rrequest & !dbus_rresponse) | (prev_dbus_wrequest & !dbus_wresponse) |
                          (prev_ibus_rrequest & !ibus_rresponse));

  // Bus interface logic
  // ---------------------------------------------------------------------------

  rvx_core_ibus rvx_core_ibus_instance (

      .clock             (clock),
      .reset_n           (reset_n),
      .clock_enable      (clock_enable),
      .program_counter_s0(program_counter_s0),

      .ibus_address      (ibus_address),
      .ibus_rdata        (ibus_rdata),
      .ibus_rrequest     (ibus_rrequest),
      .prev_ibus_rrequest(prev_ibus_rrequest),

      .instruction_s1   (instruction_s1),
      .flush_pipeline_s1(flush_pipeline_s1)

  );

  rvx_core_dbus rvx_core_dbus_instance (

      .clock       (clock),
      .clock_enable(clock_enable),
      .reset_n     (reset_n),

      .target_address_31_2_s1(target_address_s1[31:2]),
      .load_s1               (load_s1),
      .misaligned_load_s1    (misaligned_load_s1),
      .store_s1              (store_s1),
      .misaligned_store_s1   (misaligned_store_s1),
      .take_trap_s1          (take_trap_s1),

      .store_aligned_data_s1(store_aligned_data_s1),
      .store_strobe_s1      (store_strobe_s1),

      .dbus_rrequest     (dbus_rrequest),
      .dbus_address      (dbus_address),
      .dbus_wrequest     (dbus_wrequest),
      .dbus_wdata        (dbus_wdata),
      .dbus_wstrobe      (dbus_wstrobe),
      .prev_dbus_rrequest(prev_dbus_rrequest),
      .prev_dbus_wrequest(prev_dbus_wrequest)

  );

  // Pipeline stage 0
  // ---------------------------------------------------------------------------

  assign funct3_s1      = instruction_s1[14:12];
  assign rs1_address_s1 = instruction_s1[19:15];
  assign rs2_address_s1 = instruction_s1[24:20];
  assign rd_address_s1  = instruction_s1[11:7];
  assign csr_address_s1 = instruction_s1[31:20];

  rvx_core_pc_gen #(

      .BOOT_ADDRESS(BOOT_ADDRESS)

  ) rvx_core_pc_gen_instance (

      .current_state_s1       (current_state_s1),
      .exception_address_s1   (exception_address_s1),
      .trap_handler_address_s1(trap_handler_address_s1),
      .next_program_counter_s1(next_program_counter_s1),
      .program_counter_s0     (program_counter_s0)

  );

  always @(posedge clock) begin : pipeline_s0_to_s1_registers
    if (!reset_n) begin
      program_counter_s1 <= BOOT_ADDRESS;
    end
    else if (clock_enable) begin
      program_counter_s1 <= program_counter_s0;
    end
  end

  // Pipeline stage 1 
  // ---------------------------------------------------------------------------

  rvx_core_address_gen rvx_core_address_gen_instance (

      .immediate_s1            (immediate_s1),
      .instruction_funct3_1_0  (funct3_s1[1:0]),
      .load_s1                 (load_s1),
      .program_counter_s1      (program_counter_s1),
      .rs1_data_s1             (rs1_data_s1),
      .store_s1                (store_s1),
      .take_branch_s1          (take_branch_s1),
      .target_address_source_s1(target_address_source_s1),

      .misaligned_instruction_address_s1(misaligned_instruction_address_s1),
      .misaligned_load_s1               (misaligned_load_s1),
      .misaligned_store_s1              (misaligned_store_s1),
      .target_address_s1                (target_address_s1),
      .next_program_counter_s1          (next_program_counter_s1)

  );

  rvx_core_immediate_gen rvx_core_immediate_gen_instance (

      .instruction_31_7_s1(instruction_s1[31:7]),
      .immediate_type_s1  (immediate_type_s1),
      .immediate_s1       (immediate_s1)

  );

  rvx_core_decoder rvx_core_decoder_instance (

      .instruction_s1(instruction_s1),

      .branch_s1                    (branch_s1),
      .jump_s1                      (jump_s1),
      .load_s1                      (load_s1),
      .store_s1                     (store_s1),
      .ecall_s1                     (ecall_s1),
      .ebreak_s1                    (ebreak_s1),
      .mret_s1                      (mret_s1),
      .alu_2nd_operand_source_s1    (alu_2nd_operand_source_s1),
      .alu_operation_code_s1        (alu_operation_code_s1),
      .load_size_s1                 (load_size_s1),
      .load_unsigned_s1             (load_unsigned_s1),
      .target_address_source_s1     (target_address_source_s1),
      .integer_file_write_request_s1(integer_file_write_request_s1),
      .csr_write_request_s1         (csr_write_request_s1),
      .csr_operation_s1             (csr_operation_s1),
      .writeback_mux_sel_s1         (writeback_mux_sel_s1),
      .immediate_type_s1            (immediate_type_s1),
      .illegal_instruction_s1       (illegal_instruction_s1)

  );

  rvx_core_state rvx_core_state_instance (

      .clock               (clock),
      .clock_enable        (clock_enable),
      .reset_n             (reset_n),
      .mret_s1             (mret_s1),
      .interrupt_pending_s1(interrupt_pending_s1),
      .take_trap_s1        (take_trap_s1),
      .current_state_s1    (current_state_s1),
      .flush_pipeline_s1   (flush_pipeline_s1)

  );

  rvx_core_trap rvx_core_trap_instance (

      .current_state_s1                 (current_state_s1),
      .ecall_s1                         (ecall_s1),
      .ebreak_s1                        (ebreak_s1),
      .global_interrupt_enable_s1       (global_interrupt_enable_s1),
      .illegal_instruction_s1           (illegal_instruction_s1),
      .interrupt_pending_s1             (interrupt_pending_s1),
      .misaligned_instruction_address_s1(misaligned_instruction_address_s1),
      .misaligned_load_s1               (misaligned_load_s1),
      .misaligned_store_s1              (misaligned_store_s1),
      .trap_cause_s1                    (trap_cause_s1),
      .take_trap_s1                     (take_trap_s1),
      .irq_external_response_s1         (irq_external_response),
      .irq_timer_response_s1            (irq_timer_response),
      .irq_software_response_s1         (irq_software_response),
      .irq_fast_response_s1             (irq_fast_response)

  );

  rvx_core_branch rvx_core_branch_instance (

      .rs1_data_s1   (rs1_data_s1),
      .rs2_data_s1   (rs2_data_s1),
      .funct3_s1     (funct3_s1),
      .branch_s1     (branch_s1),
      .jump_s1       (jump_s1),
      .take_branch_s1(take_branch_s1)

  );

  rvx_core_store_unit rvx_core_store_unit_instance (

      .rs2_data_s1                (rs2_data_s1),
      .target_address_adder_1_0_s1(target_address_s1[1:0]),
      .funct3_s1                  (funct3_s1),
      .dbus_wrequest              (dbus_wrequest),
      .store_aligned_data_s1      (store_aligned_data_s1),
      .store_strobe_s1            (store_strobe_s1)

  );

  always @(posedge clock) begin : pipeline_s1_to_s2_registers
    if (!reset_n | flush_pipeline_s1) begin
      alu_2nd_operand_source_s2     <= 1'b0;
      alu_operation_code_s2         <= 4'b0000;
      rs1_data_s2                   <= 32'h00000000;
      rs2_data_s2                   <= 32'h00000000;
      immediate_s2                  <= 32'h00000000;
      integer_file_write_request_s2 <= 1'b0;
      target_address_adder_s2       <= 32'h00000000;
      program_counter_plus_4_s2     <= 32'h00000000;
      load_size_s2                  <= 2'b00;
      load_unsigned_s2              <= 1'b0;
      csr_write_request_s2          <= 1'b0;
      csr_operation_s2              <= 3'b000;
      csr_address_s2                <= 12'h000;
      instruction_rd_address_s2     <= 5'h00;
      writeback_mux_sel_s2          <= 3'b000;
    end
    else if (clock_enable) begin
      alu_2nd_operand_source_s2     <= alu_2nd_operand_source_s1;
      alu_operation_code_s2         <= alu_operation_code_s1;
      rs1_data_s2                   <= rs1_data_s1;
      rs2_data_s2                   <= rs2_data_s1;
      immediate_s2                  <= immediate_s1;
      integer_file_write_request_s2 <= integer_file_write_request_s1;
      target_address_adder_s2       <= target_address_s1;
      program_counter_plus_4_s2     <= program_counter_s1 + 32'h00000004;
      load_size_s2                  <= load_size_s1;
      load_unsigned_s2              <= load_unsigned_s1;
      csr_write_request_s2          <= csr_write_request_s1;
      csr_operation_s2              <= csr_operation_s1;
      csr_address_s2                <= csr_address_s1;
      instruction_rd_address_s2     <= rd_address_s1;
      writeback_mux_sel_s2          <= writeback_mux_sel_s1;
    end
  end

  // Pipeline stage 2
  // ---------------------------------------------------------------------------

  always @* begin : writeback_output_s2_mux
    case (writeback_mux_sel_s2)
      `RVX_WB_ALU:          writeback_output_s2 = alu_output_s2;
      `RVX_WB_LOAD_UNIT:    writeback_output_s2 = load_aligned_data_s2;
      `RVX_WB_UPPER_IMM:    writeback_output_s2 = immediate_s2;
      `RVX_WB_TARGET_ADDER: writeback_output_s2 = target_address_adder_s2;
      `RVX_WB_CSR:          writeback_output_s2 = csr_data_out_s2;
      `RVX_WB_PC_PLUS_4:    writeback_output_s2 = program_counter_plus_4_s2;
      default:              writeback_output_s2 = alu_output_s2;
    endcase
  end

  rvx_core_load_unit rvx_core_load_unit_instance (

      .read_data_s2               (dbus_rdata),
      .load_size_s2               (load_size_s2),
      .load_unsigned_s2           (load_unsigned_s2),
      .target_address_adder_1_0_s2(target_address_adder_s2[1:0]),
      .load_aligned_data_s2       (load_aligned_data_s2)

  );

  rvx_core_alu rvx_core_alu_instance (

      .alu_2nd_operand_source_s2(alu_2nd_operand_source_s2),
      .alu_operation_code_s2    (alu_operation_code_s2),
      .rs1_data_s2              (rs1_data_s2),
      .rs2_data_s2              (rs2_data_s2),
      .immediate_s2             (immediate_s2),
      .alu_output_s2            (alu_output_s2)

  );

  // Integer and CSR Register files
  // ---------------------------------------------------------------------------

  rvx_core_integer_file rvx_core_integer_file_instance (

      .clock       (clock),
      .clock_enable(clock_enable & !flush_pipeline_s1),
      .reset_n     (reset_n),

      // Read port 1
      .rs1_address_s1(rs1_address_s1),
      .rs1_data_s1   (rs1_data_s1),

      // Read port 2
      .rs2_address_s1(rs2_address_s1),
      .rs2_data_s1   (rs2_data_s1),

      // Write port
      .write_request_s2(integer_file_write_request_s2),
      .rd_address_s2   (instruction_rd_address_s2),
      .rd_data_s2      (writeback_output_s2)

  );

  rvx_core_csr_file rvx_core_csr_file_instance (

      .clock       (clock),
      .clock_enable(clock_enable),
      .reset_n     (reset_n),

      // From pipeline stage 1
      .current_state_s1                 (current_state_s1),
      .ecall_s1                         (ecall_s1),
      .ebreak_s1                        (ebreak_s1),
      .illegal_instruction_s1           (illegal_instruction_s1),
      .irq_external_s1                  (irq_external),
      .irq_timer_s1                     (irq_timer),
      .irq_software_s1                  (irq_software),
      .irq_fast_s1                      (irq_fast),
      .memory_mapped_timer_s1           (memory_mapped_timer),
      .misaligned_instruction_address_s1(misaligned_instruction_address_s1),
      .misaligned_load_s1               (misaligned_load_s1),
      .misaligned_store_s1              (misaligned_store_s1),
      .program_counter_s1               (program_counter_s1),
      .take_trap_s1                     (take_trap_s1),
      .target_address_s1                (target_address_s1),

      // From pipeline stage 2
      .csr_address_s2      (csr_address_s2),
      .csr_operation_s2    (csr_operation_s2),
      .csr_write_request_s2(csr_write_request_s2),
      .immediate_4_0_s2    (immediate_s2[4:0]),
      .rs1_data_s2         (rs1_data_s2),

      // Data output
      .csr_data_out_s2(csr_data_out_s2),

      // To pipeline stage 1
      .trap_handler_address_s1   (trap_handler_address_s1),
      .trap_cause_s1             (trap_cause_s1),
      .interrupt_pending_s1      (interrupt_pending_s1),
      .global_interrupt_enable_s1(global_interrupt_enable_s1),
      .exception_address_s1      (exception_address_s1)

  );

endmodule
