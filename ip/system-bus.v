/**************************************************************************************************

MIT License

Copyright (c) 2020-present Rafael Calcada

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

**************************************************************************************************/

/**************************************************************************************************

Project Name:  RISC-V Steel System-on-Chip - System Bus
Project Repo:  github.com/riscv-steel/riscv-steel
Author:        Rafael Calcada 
E-mail:        rafaelcalcada@gmail.com

Top Module:    system_bus
 
**************************************************************************************************/

module system_bus #(

  parameter DEVICE0_START_ADDRESS = 32'h00000000,
  parameter DEVICE0_FINAL_ADDRESS = 32'h7fffffff,
  parameter DEVICE1_START_ADDRESS = 32'h80000000,
  parameter DEVICE1_FINAL_ADDRESS = 32'hffffffff,
  parameter DEVICE2_START_ADDRESS = 32'hdeadbeef,
  parameter DEVICE2_FINAL_ADDRESS = 32'hdeadbeef

  /* Uncomment to add new devices
  
  parameter DEVICE3_START_ADDRESS = 32'hdeadbeef,
  parameter DEVICE3_FINAL_ADDRESS = 32'hdeadbeef
  
  */

  )(

  input   wire       clock,
  input   wire       reset,

  // Interface with the Manager Device

  input   wire  [31:0]  rw_address,
  output  reg   [31:0]  read_data,
  input   wire          read_request,
  output  reg           read_response,
  input   wire  [31:0]  write_data,
  input   wire  [3:0 ]  write_strobe,
  input   wire          write_request,
  output  reg           write_response,
  
  // Device #0

  output  wire  [31:0]  device0_rw_address,
  input   wire  [31:0]  device0_read_data,
  output  wire          device0_read_request,
  input   wire          device0_read_response,
  output  wire  [31:0]  device0_write_data,
  output  wire  [3:0 ]  device0_write_strobe,
  output  wire          device0_write_request,
  input   wire          device0_write_response,

  // Device #1

  output  wire  [31:0]  device1_rw_address,
  input   wire  [31:0]  device1_read_data,
  output  wire          device1_read_request,
  input   wire          device1_read_response,
  output  wire  [31:0]  device1_write_data,
  output  wire  [3:0 ]  device1_write_strobe,
  output  wire          device1_write_request,
  input   wire          device1_write_response,

  // Device #2

  output  wire  [31:0]  device2_rw_address,
  input   wire  [31:0]  device2_read_data,
  output  wire          device2_read_request,
  input   wire          device2_read_response,
  output  wire  [31:0]  device2_write_data,
  output  wire  [3:0 ]  device2_write_strobe,
  output  wire          device2_write_request,
  input   wire          device2_write_response

  /* Uncomment to add new devices

  // Device #3

  output  wire  [31:0]  device3_rw_address,
  input   wire  [31:0]  device3_read_data,
  output  wire          device3_read_request,
  input   wire          device3_read_response,
  output  wire  [31:0]  device3_write_data,
  output  wire  [3:0 ]  device3_write_strobe,
  output  wire          device3_write_request,
  input   wire          device3_write_response
  
  */

  );

  wire          reset_internal;

  localparam    RESET       = 7;
  localparam    DEVICE0     = 0;
  localparam    DEVICE1     = 1;
  localparam    DEVICE2     = 2;

  /* Uncomment to add new devices

  localparam    DEVICE3     = 3;

  */

  wire          device0_valid_access;
  wire          device1_valid_access;
  wire          device2_valid_access;

  /* Uncomment to add new devices

  wire          device3_valid_access;

  */

  reg           reset_reg;
  reg [2:0]     selected_response;

  always @(posedge clock)
    reset_reg <= reset;

  assign reset_internal = reset | reset_reg;

  assign device0_valid_access =
    $unsigned(rw_address) >= $unsigned(DEVICE0_START_ADDRESS) && 
    $unsigned(rw_address) <= $unsigned(DEVICE0_FINAL_ADDRESS);
  
  assign device1_valid_access =
    $unsigned(rw_address) >= $unsigned(DEVICE1_START_ADDRESS) && 
    $unsigned(rw_address) <= $unsigned(DEVICE1_FINAL_ADDRESS);

  assign device2_valid_access =
    $unsigned(rw_address) >= $unsigned(DEVICE2_START_ADDRESS) && 
    $unsigned(rw_address) <= $unsigned(DEVICE2_FINAL_ADDRESS);

  /* Uncomment to add new devices
  
  assign device3_valid_access =
    $unsigned(rw_address) >= $unsigned(DEVICE3_START_ADDRESS) && 
    $unsigned(rw_address) <= $unsigned(DEVICE3_FINAL_ADDRESS);

  */

  assign device0_rw_address    = device0_valid_access ? rw_address    : 1'b0;
  assign device0_write_data    = device0_valid_access ? write_data    : 32'h0;
  assign device0_write_strobe  = device0_valid_access ? write_strobe  : 4'h0;
  assign device0_read_request  = device0_valid_access ? read_request  : 1'b0;
  assign device0_write_request = device0_valid_access ? write_request : 1'b0;

  assign device1_rw_address    = device1_valid_access ? rw_address    : 1'b0;
  assign device1_write_data    = device1_valid_access ? write_data    : 32'h0;
  assign device1_write_strobe  = device1_valid_access ? write_strobe  : 4'h0;
  assign device1_read_request  = device1_valid_access ? read_request  : 1'b0;
  assign device1_write_request = device1_valid_access ? write_request : 1'b0;

  assign device2_rw_address    = device2_valid_access ? rw_address    : 1'b0;
  assign device2_write_data    = device2_valid_access ? write_data    : 32'h0;
  assign device2_write_strobe  = device2_valid_access ? write_strobe  : 4'h0;
  assign device2_read_request  = device2_valid_access ? read_request  : 1'b0;
  assign device2_write_request = device2_valid_access ? write_request : 1'b0;

  /* Uncomment to add new devices

  assign device3_rw_address    = device3_valid_access ? rw_address    : 1'b0;
  assign device3_write_data    = device3_valid_access ? write_data    : 32'h0;
  assign device3_write_strobe  = device3_valid_access ? write_strobe  : 4'h0;
  assign device3_read_request  = device3_valid_access ? read_request  : 1'b0;
  assign device3_write_request = device3_valid_access ? write_request : 1'b0;

  */

  always @(posedge clock) begin
    if (reset_internal) begin
      selected_response <= RESET;
    end
    else if (device0_valid_access) begin
      selected_response <= DEVICE0;
    end
    else if (device1_valid_access) begin
      selected_response <= DEVICE1;
    end
    else if (device2_valid_access) begin
      selected_response <= DEVICE2;
    end

    /* Uncomment to add new devices

    else if (device3_valid_access) begin
      selected_response <= DEVICE3;
    end

    */

    else begin
      selected_response <= RESET;
    end
  end

  always @* begin
    case (selected_response)
      default: begin
        write_response  <= 1'b1;
        read_data       <= 32'h00000000;
        read_response   <= 2'b1;
      end
      RESET: begin
        write_response  <= 1'b1;
        read_data       <= 32'h00000000;
        read_response   <= 2'b1;
      end
      DEVICE0: begin
        write_response  <= device0_write_response;
        read_data       <= device0_read_data;
        read_response   <= device0_read_response;
      end
      DEVICE1: begin
        write_response  <= device1_write_response;
        read_data       <= device1_read_data;
        read_response   <= device1_read_response;
      end
      DEVICE2: begin
        write_response  <= device2_write_response;
        read_data       <= device2_read_data;
        read_response   <= device2_read_response;
      end

      /* Uncomment to add new devices

      DEVICE3: begin
        write_response  <= device3_write_response;
        read_data       <= device3_read_data;
        read_response   <= device3_read_response;
      end
      
      */

    endcase
  end

endmodule