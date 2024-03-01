// ----------------------------------------------------------------------------
// Copyright (c) 2020-2024 RISC-V Steel contributors
//
// This work is licensed under the MIT License, see LICENSE file for details.
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

`timescale 1ns / 1ps

module unit_tests();

  reg clock;
  reg reset;
  reg halt;
  
  reg read_response_test;
  reg write_response_test;  

  wire   [31:0]  rw_address;
  wire   [31:0]  read_data;
  wire           read_request;
  wire           read_response;
  wire   [31:0]  write_data;
  wire   [3:0 ]  write_strobe;
  wire           write_request;
  wire           write_response;
  
  rvsteel_core
  dut0 (

    // Global signals
  
    .clock                        (clock                        ),
    .reset                        (reset                        ),
    .halt                         (halt                         ),
  
    // IO interface
  
    .rw_address                   (rw_address                   ),
    .read_data                    (read_data                    ),
    .read_request                 (read_request                 ),
    .read_response                (read_response &
                                   read_response_test           ),
    .write_data                   (write_data                   ),
    .write_strobe                 (write_strobe                 ),
    .write_request                (write_request                ),
    .write_response               (write_response &
                                   write_response_test          ),
  
    // Interrupt signals (hardwire inputs to zero if unused)
  
    .irq_external                 (1'b0),
    .irq_external_response             (),
    .irq_timer                    (1'b0),
    .irq_timer_response                (),
    .irq_software                 (1'b0),  
    .irq_software_response             (),
  
    // Real Time Clock (hardwire to zero if unused)
  
    .real_time_clock              (64'b0)

  );
  
  ram_memory #(
    
    .MEMORY_SIZE                  (2097152                      )
  
  ) dut1 (
  
    // Global signals
  
    .clock                        (clock                        ),
    .reset                        (reset                        ),
    
    // IO interface
  
    .rw_address                   (rw_address                   ),
    .read_data                    (read_data                    ),
    .read_request                 (read_request                 ),
    .read_response                (read_response                ),
    .write_data                   (write_data                   ),
    .write_strobe                 (write_strobe                 ),
    .write_request                (write_request                ),
    .write_response               (write_response               )    

  );
  
  always #10 clock = !clock;
  
  reg [167:0] unit_test_programs_array [0:53] = {
    "add-01.hex",
    "addi-01.hex",
    "and-01.hex",
    "andi-01.hex",
    "auipc-01.hex",
    "beq-01.hex",
    "bge-01.hex",
    "bgeu-01.hex",
    "blt-01.hex",
    "bltu-01.hex",
    "bne-01.hex",
    "ebreak.hex",
    "ecall.hex",
    "fence-01.hex",
    "jal-01.hex",
    "jalr-01.hex",
    "lb-align-01.hex",
    "lbu-align-01.hex",
    "lh-align-01.hex",
    "lhu-align-01.hex",
    "lui-01.hex",
    "lw-align-01.hex",
    "misalign-beq-01.hex",
    "misalign-bge-01.hex",
    "misalign-bgeu-01.hex",
    "misalign-blt-01.hex",
    "misalign-bltu-01.hex",
    "misalign-bne-01.hex",
    "misalign-jal-01.hex",
    "misalign-lh-01.hex",
    "misalign-lhu-01.hex",
    "misalign-lw-01.hex",
    "misalign-sh-01.hex",
    "misalign-sw-01.hex",
    "misalign1-jalr-01.hex",
    "misalign2-jalr-01.hex",
    "or-01.hex",
    "ori-01.hex",
    "sb-align-01.hex",
    "sh-align-01.hex",
    "sll-01.hex",
    "slli-01.hex",
    "slt-01.hex",
    "slti-01.hex",
    "sltiu-01.hex",
    "sltu-01.hex",
    "sra-01.hex",
    "srai-01.hex",
    "srl-01.hex",
    "srli-01.hex",
    "sub-01.hex",
    "sw-align-01.hex",
    "xor-01.hex",
    "xori-01.hex"
  };
  
  reg [519:0] golden_reference_array [0:53] = {
    "add-01.reference.hex",
    "addi-01.reference.hex",
    "and-01.reference.hex",
    "andi-01.reference.hex",
    "auipc-01.reference.hex",
    "beq-01.reference.hex",
    "bge-01.reference.hex",
    "bgeu-01.reference.hex",
    "blt-01.reference.hex",
    "bltu-01.reference.hex",
    "bne-01.reference.hex",
    "ebreak.reference.hex",
    "ecall.reference.hex",
    "fence-01.reference.hex",
    "jal-01.reference.hex",
    "jalr-01.reference.hex",
    "lb-align-01.reference.hex",
    "lbu-align-01.reference.hex",
    "lh-align-01.reference.hex",
    "lhu-align-01.reference.hex",
    "lui-01.reference.hex",
    "lw-align-01.reference.hex",
    "misalign-beq-01.reference.hex",
    "misalign-bge-01.reference.hex",
    "misalign-bgeu-01.reference.hex",
    "misalign-blt-01.reference.hex",
    "misalign-bltu-01.reference.hex",
    "misalign-bne-01.reference.hex",
    "misalign-jal-01.reference.hex",
    "misalign-lh-01.reference.hex",
    "misalign-lhu-01.reference.hex",
    "misalign-lw-01.reference.hex",
    "misalign-sh-01.reference.hex",
    "misalign-sw-01.reference.hex",
    "misalign1-jalr-01.reference.hex",
    "misalign2-jalr-01.reference.hex",
    "or-01.reference.hex",
    "ori-01.reference.hex",
    "sb-align-01.reference.hex",
    "sh-align-01.reference.hex",
    "sll-01.reference.hex",
    "slli-01.reference.hex",
    "slt-01.reference.hex",
    "slti-01.reference.hex",
    "sltiu-01.reference.hex",
    "sltu-01.reference.hex",
    "sra-01.reference.hex",
    "srai-01.reference.hex",
    "srl-01.reference.hex",
    "srli-01.reference.hex",
    "sub-01.reference.hex",
    "sw-align-01.reference.hex",
    "xor-01.reference.hex",
    "xori-01.reference.hex"
  };
  
  // The tests below are expected to fail because 
  // RISC-V Steel Processor IP does not support
  // misaligned branch/jump instructions 
  reg [167:0] expected_to_fail [0:7] = {
    "misalign-beq-01.hex",
    "misalign-bge-01.hex",
    "misalign-bgeu-01.hex",
    "misalign-blt-01.hex",
    "misalign-bltu-01.hex",
    "misalign-bne-01.hex",
    "misalign-jal-01.hex",
    "misalign2-jalr-01.hex"
  };
  
  integer     i, j, k, m, n, t, u, z;
  integer     failing_tests_counter;
  integer     current_test_failed_flag;
  integer     expected_to_fail_flag;
  reg [31:0]  current_golden_reference [0:2047];
 
  always begin
    
    read_response_test = 1'b1;
    write_response_test = 1'b1;
    #200;
    
    for (t = 0; t < 10000; t=t+1) begin
      read_response_test = $random();
      write_response_test = $random();
      #20;
    end
    
    read_response_test = 1'b1;
    write_response_test = 1'b1;
    
  end
  
  always begin
    
    halt = 1'b0;
    #1000;
    
    for (u = 0; u < 10000; u=u+1) begin
      halt = $random();
      #20;
    end
    
    halt = 1'b0;
    
  end
 
  initial begin
    
    i = 0;
    j = 0;
    k = 0;
    m = 0;
    n = 0;
    t = 0;
    z = 0;    
    current_test_failed_flag = 0;
    expected_to_fail_flag = 0;
    failing_tests_counter = 0;
    clock   = 1'b0;
    reset   = 1'b0;
      
    $display("Running unit test programs from RISC-V Architectural Test Suite.");
    
    for(k = 0; k < 54; k=k+1) begin
    
      // Reset     
      reset = 1'b1;
      for(i = 0; i < 524287; i=i+1) dut1.ram[i] = 32'hdeadbeef;
      for(i = 0; i < 2048;   i=i+1) current_golden_reference[i] = 32'hdeadbeef;
      #40;
      reset = 1'b0;
      
      // Initialization
      $readmemh(unit_test_programs_array[k],  dut1.ram                );      
      $readmemh(golden_reference_array[k],    current_golden_reference);

      $display("Running test: %s", unit_test_programs_array[k]);
            
      // Main loop: run test
      for(j = 0; j < 500000; j=j+1) begin
                
        // After each clock cycle it tests whether the test program finished its execution
        // This event is signaled by writing 1 to the address 0x00001000
        #20;        
        if(rw_address == 32'h00001000 &&
           write_request == 1'b1 &&
           write_data == 32'h00000001) begin
           
          // The beginning and end of signature are stored at
          // 0x00001ffc (ram[2046]) and 0x00001ff8 (ram[2047]).
          m =  dut1.ram[2047][24:2]; // m holds the address of the beginning of the signature
          n =  dut1.ram[2046][24:2]; // n holds the address of the end of the signature
          
          // Compare signature with golden reference
          z = 0;
          current_test_failed_flag = 0;
          for(m = dut1.ram[2047][24:2]; m < n; m=m+1) begin
            if (dut1.ram[m] !== current_golden_reference[z]) begin
              // Is this test expected to fail?
              expected_to_fail_flag = 0;
              for (t = 0; t < 9; t=t+1) begin
                if (unit_test_programs_array[k] == expected_to_fail[t]) begin
                  expected_to_fail_flag = 1;
                  t = 9;
                end
              end
              // In case it is not, print failure message
              if (expected_to_fail_flag == 0) begin
                $display("TEST FAILED: %s", unit_test_programs_array[k]);
                $display("Signature at line %d differs from golden reference.", z+1);
                $display("Signature: %h. Golden reference: %h", dut1.ram[m], current_golden_reference[z]);
                failing_tests_counter = failing_tests_counter+1;
                current_test_failed_flag = 1;
                $stop();
              end
            end            
            z=z+1;
          end
          
          // Skip loop in a successful run 
          if (current_test_failed_flag == 0) j = 999999;
          
        end
      end
      
      // The program ran for 500000 cycles and did not finish (something is wrong)
      if (j == 500000) begin
        $info("TEST FAILED (probably hanging): %s", unit_test_programs_array[k]);
        $stop();
      end
      
    end
    
    if (failing_tests_counter == 0) begin
      $display("------------------------------------------------------------------------------------------");
      $display("RISC-V Steel Processor Core IP passed ALL unit tests from RISC-V Architectural Test Suite");
      $display("------------------------------------------------------------------------------------------");
    end    
    else begin      
      $display("FAILED on one or more unit tests.");
      $fatal();
    end
    
    $finish(0);
   
  end

endmodule

module ram_memory #(

  // Memory size in bytes
  parameter MEMORY_SIZE      = 8192,
  
  // File with program and data
  parameter MEMORY_INIT_FILE = ""

  ) (
  
  // Global signals

  input   wire          clock,
  input   wire          reset,

  // IO interface

  input  wire   [31:0]  rw_address,
  output reg    [31:0]  read_data,
  input  wire           read_request,
  output reg            read_response,
  input  wire   [31:0]  write_data,
  input  wire   [3:0 ]  write_strobe,
  input  wire           write_request,
  output reg            write_response

  );

  wire                        reset_internal;
  wire [31:0]                 effective_address;
  wire                        invalid_address;
  
  reg                         reset_reg;
  reg [31:0]                  ram [0:(MEMORY_SIZE/4)-1];
  
  always @(posedge clock)
    reset_reg <= reset;

  assign reset_internal = reset | reset_reg;
  assign invalid_address = $unsigned(rw_address) >= $unsigned(MEMORY_SIZE);

  integer i;  
  initial begin
    for (i = 0; i < MEMORY_SIZE/4; i = i + 1) ram[i] = 32'h00000000;
    if (MEMORY_INIT_FILE != "")      
      $readmemh(MEMORY_INIT_FILE,ram);
  end

  assign effective_address =
    $unsigned(rw_address[31:0] >> 2);
  
  always @(posedge clock) begin
    if (reset_internal | invalid_address)
      read_data <= 32'h00000000;
    else
      read_data <= ram[effective_address];
  end

  always @(posedge clock) begin
    if(write_request) begin
      if(write_strobe[0])
        ram[effective_address][7:0  ] <= write_data[7:0  ];
      if(write_strobe[1])
        ram[effective_address][15:8 ] <= write_data[15:8 ];
      if(write_strobe[2])
        ram[effective_address][23:16] <= write_data[23:16];
      if(write_strobe[3])
        ram[effective_address][31:24] <= write_data[31:24];
    end
  end

  always @(posedge clock) begin
    if (reset_internal) begin
      read_response  <= 1'b0;
      write_response <= 1'b0;
    end
    else begin
      read_response  <= read_request;
      write_response <= write_request;
    end
  end
  
endmodule