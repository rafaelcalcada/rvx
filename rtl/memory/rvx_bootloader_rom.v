// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

// RVX Bootloader Read-Only Memory (ROM) Module
module rvx_bootloader_rom #(

    // Size of the memory in bytes
    parameter SIZE_IN_BYTES = 2048

) (

    // Global signals
    input wire clock,
    input wire reset_n,

    // Read-only port
    input  wire [31:0] address,
    output reg  [31:0] rdata,
    input  wire        rrequest,
    output reg         rresponse

);

  reg  [31:0] rom               [0:SIZE_IN_BYTES/4-1];

  // verilator lint_off UNUSEDSIGNAL
  wire [31:0] effective_address;
  // verilator lint_on UNUSEDSIGNAL

  wire        invalid_address;

  assign invalid_address = $unsigned(address) >= $unsigned(SIZE_IN_BYTES);

  integer i;
  initial begin
    for (i = 0; i < SIZE_IN_BYTES / 4; i = i + 1) rom[i] = 32'h00000000;
    // Bootloader program (compiled from bootloader/rvx_bootloader.c)
    rom[0]   = 32'h7C0026F3;
    rom[1]   = 32'h40003737;
    rom[2]   = 32'h00072223;
    rom[3]   = 32'h00300793;
    rom[4]   = 32'h00F72623;
    rom[5]   = 32'h0106D593;
    rom[6]   = 32'h0086D613;
    rom[7]   = 32'h01472783;
    rom[8]   = 32'h0017F793;
    rom[9]   = 32'hFE079CE3;
    rom[10]  = 32'h0FF5F793;
    rom[11]  = 32'h00F72623;
    rom[12]  = 32'h40003737;
    rom[13]  = 32'h01472783;
    rom[14]  = 32'h0017F793;
    rom[15]  = 32'hFE079CE3;
    rom[16]  = 32'h0FF67793;
    rom[17]  = 32'h00F72623;
    rom[18]  = 32'h40003737;
    rom[19]  = 32'h01472783;
    rom[20]  = 32'h0017F793;
    rom[21]  = 32'hFE079CE3;
    rom[22]  = 32'h0FF6F693;
    rom[23]  = 32'h00D72623;
    rom[24]  = 32'h400037B7;
    rom[25]  = 32'h0147A583;
    rom[26]  = 32'h0015F593;
    rom[27]  = 32'hFE059CE3;
    rom[28]  = 32'h00000613;
    rom[29]  = 32'h400037B7;
    rom[30]  = 32'h02000513;
    rom[31]  = 32'h0007A623;
    rom[32]  = 32'h0147A683;
    rom[33]  = 32'h0016F693;
    rom[34]  = 32'hFE069CE3;
    rom[35]  = 32'h0107A703;
    rom[36]  = 32'h0FF77713;
    rom[37]  = 32'h00C71733;
    rom[38]  = 32'h00860613;
    rom[39]  = 32'h00E5E5B3;
    rom[40]  = 32'hFCA61EE3;
    rom[41]  = 32'h00000513;
    rom[42]  = 32'h400037B7;
    rom[43]  = 32'h02000813;
    rom[44]  = 32'h0007A623;
    rom[45]  = 32'h0147A603;
    rom[46]  = 32'h00167613;
    rom[47]  = 32'hFE061CE3;
    rom[48]  = 32'h0107A703;
    rom[49]  = 32'h0FF77713;
    rom[50]  = 32'h00A71733;
    rom[51]  = 32'h00850513;
    rom[52]  = 32'h00E6E6B3;
    rom[53]  = 32'hFD051EE3;
    rom[54]  = 32'h00000813;
    rom[55]  = 32'h40003737;
    rom[56]  = 32'h02000893;
    rom[57]  = 32'h00072623;
    rom[58]  = 32'h01472783;
    rom[59]  = 32'h0017F793;
    rom[60]  = 32'hFE079CE3;
    rom[61]  = 32'h01072503;
    rom[62]  = 32'h0FF57513;
    rom[63]  = 32'h01051533;
    rom[64]  = 32'h00880813;
    rom[65]  = 32'h00A66633;
    rom[66]  = 32'hFD181EE3;
    rom[67]  = 32'h00000813;
    rom[68]  = 32'h40003537;
    rom[69]  = 32'h02000893;
    rom[70]  = 32'h00052623;
    rom[71]  = 32'h01452703;
    rom[72]  = 32'h00177713;
    rom[73]  = 32'hFE071CE3;
    rom[74]  = 32'h01052703;
    rom[75]  = 32'h0FF77713;
    rom[76]  = 32'h01071733;
    rom[77]  = 32'h00880813;
    rom[78]  = 32'h00E7E7B3;
    rom[79]  = 32'hFD181EE3;
    rom[80]  = 32'hADA9D737;
    rom[81]  = 32'hCCE70713;
    rom[82]  = 32'h00E585B3;
    rom[83]  = 32'h08059C63;
    rom[84]  = 32'hADA9A737;
    rom[85]  = 32'h7CC70713;
    rom[86]  = 32'h00E787B3;
    rom[87]  = 32'h525635B7;
    rom[88]  = 32'h52566737;
    rom[89]  = 32'h83470713;
    rom[90]  = 32'h33258593;
    rom[91]  = 32'h06079C63;
    rom[92]  = 32'h00001337;
    rom[93]  = 32'h00B32023;
    rom[94]  = 32'h00D32223;
    rom[95]  = 32'h00C32423;
    rom[96]  = 32'h00E32623;
    rom[97]  = 32'h01000813;
    rom[98]  = 32'h40003737;
    rom[99]  = 32'h02000893;
    rom[100] = 32'h04D87263;
    rom[101] = 32'h00000593;
    rom[102] = 32'h00000513;
    rom[103] = 32'h00072623;
    rom[104] = 32'h01472783;
    rom[105] = 32'h0017F793;
    rom[106] = 32'hFE079CE3;
    rom[107] = 32'h01072783;
    rom[108] = 32'h0FF7F793;
    rom[109] = 32'h00B797B3;
    rom[110] = 32'h00858593;
    rom[111] = 32'h00F56533;
    rom[112] = 32'hFD159EE3;
    rom[113] = 32'h010307B3;
    rom[114] = 32'h00A7A023;
    rom[115] = 32'h00480813;
    rom[116] = 32'hFCD862E3;
    rom[117] = 32'h400037B7;
    rom[118] = 32'h00100713;
    rom[119] = 32'h00E7A223;
    rom[120] = 32'h00060067;
    rom[121] = 32'h400037B7;
    rom[122] = 32'h00100713;
    rom[123] = 32'h00E7A223;
    rom[124] = 32'h000017B7;
    rom[125] = 32'h0007A583;
    rom[126] = 32'h00478693;
    rom[127] = 32'h00878613;
    rom[128] = 32'h00C78713;
    rom[129] = 32'hADA9D7B7;
    rom[130] = 32'h0006A683;
    rom[131] = 32'hCCE78793;
    rom[132] = 32'h00062603;
    rom[133] = 32'h00072703;
    rom[134] = 32'h00F587B3;
    rom[135] = 32'h02079663;
    rom[136] = 32'hADA9A7B7;
    rom[137] = 32'h7CC78793;
    rom[138] = 32'h00F707B3;
    rom[139] = 32'h00079E63;
    rom[140] = 32'h00060067;
    rom[141] = 32'h52566737;
    rom[142] = 32'h525635B7;
    rom[143] = 32'h83470713;
    rom[144] = 32'h33258593;
    rom[145] = 32'hF2DFF06F;
    rom[146] = 32'h5B90006F;
    rom[147] = 32'hF25FF06F;
  end

  assign effective_address = $unsigned(address[31:0] >> 2);

  always @(posedge clock) begin
    if (!reset_n | invalid_address) rdata <= 32'h00000000;
    else rdata <= rom[effective_address];
  end

  always @(posedge clock) begin
    if (!reset_n) rresponse <= 1'b0;
    else rresponse <= rrequest;
  end

endmodule
