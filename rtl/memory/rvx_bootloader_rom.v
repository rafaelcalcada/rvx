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
    rom[0]   = 32'h400037B7;
    rom[1]   = 32'h0007A223;
    rom[2]   = 32'h00300693;
    rom[3]   = 32'h400037B7;
    rom[4]   = 32'h00D7A623;
    rom[5]   = 32'h01478713;
    rom[6]   = 32'h00072783;
    rom[7]   = 32'h0017F793;
    rom[8]   = 32'hFE079CE3;
    rom[9]   = 32'h400036B7;
    rom[10]  = 32'h400037B7;
    rom[11]  = 32'h01068693;
    rom[12]  = 32'h0006A683;
    rom[13]  = 32'h01478713;
    rom[14]  = 32'h0007A623;
    rom[15]  = 32'h00072783;
    rom[16]  = 32'h0017F793;
    rom[17]  = 32'hFE079CE3;
    rom[18]  = 32'h400036B7;
    rom[19]  = 32'h400037B7;
    rom[20]  = 32'h01068693;
    rom[21]  = 32'h0006A683;
    rom[22]  = 32'h01478713;
    rom[23]  = 32'h0007A623;
    rom[24]  = 32'h00072783;
    rom[25]  = 32'h0017F793;
    rom[26]  = 32'hFE079CE3;
    rom[27]  = 32'h400036B7;
    rom[28]  = 32'h400037B7;
    rom[29]  = 32'h01068693;
    rom[30]  = 32'h0006A683;
    rom[31]  = 32'h01478713;
    rom[32]  = 32'h0007A623;
    rom[33]  = 32'h00072783;
    rom[34]  = 32'h0017F793;
    rom[35]  = 32'hFE079CE3;
    rom[36]  = 32'h400036B7;
    rom[37]  = 32'h400037B7;
    rom[38]  = 32'h01068693;
    rom[39]  = 32'h0006A683;
    rom[40]  = 32'h01478713;
    rom[41]  = 32'h0007A623;
    rom[42]  = 32'h00072783;
    rom[43]  = 32'h0017F793;
    rom[44]  = 32'hFE079CE3;
    rom[45]  = 32'h400037B7;
    rom[46]  = 32'h0107A583;
    rom[47]  = 32'h400037B7;
    rom[48]  = 32'h0007A623;
    rom[49]  = 32'h0FF5F593;
    rom[50]  = 32'h01478713;
    rom[51]  = 32'h00072783;
    rom[52]  = 32'h0017F793;
    rom[53]  = 32'hFE079CE3;
    rom[54]  = 32'h400037B7;
    rom[55]  = 32'h0107A603;
    rom[56]  = 32'h400037B7;
    rom[57]  = 32'h0007A623;
    rom[58]  = 32'h0FF67613;
    rom[59]  = 32'h00861613;
    rom[60]  = 32'h01478713;
    rom[61]  = 32'h00072783;
    rom[62]  = 32'h0017F793;
    rom[63]  = 32'hFE079CE3;
    rom[64]  = 32'h400037B7;
    rom[65]  = 32'h0107A683;
    rom[66]  = 32'h400037B7;
    rom[67]  = 32'h0007A623;
    rom[68]  = 32'h0FF6F693;
    rom[69]  = 32'h01069693;
    rom[70]  = 32'h01478713;
    rom[71]  = 32'h00072783;
    rom[72]  = 32'h0017F793;
    rom[73]  = 32'hFE079CE3;
    rom[74]  = 32'h400037B7;
    rom[75]  = 32'h0107A703;
    rom[76]  = 32'h525667B7;
    rom[77]  = 32'h83078793;
    rom[78]  = 32'h01871713;
    rom[79]  = 32'h00B76733;
    rom[80]  = 32'h00C76733;
    rom[81]  = 32'h00D76733;
    rom[82]  = 32'h02F70863;
    rom[83]  = 32'h400036B7;
    rom[84]  = 32'h00100613;
    rom[85]  = 32'h00C6A223;
    rom[86]  = 32'h000016B7;
    rom[87]  = 32'h0006A683;
    rom[88]  = 32'h00F68463;
    rom[89]  = 32'h69D0006F;
    rom[90]  = 32'h000017B7;
    rom[91]  = 32'h00478793;
    rom[92]  = 32'h0007A783;
    rom[93]  = 32'h00078067;
    rom[94]  = 32'h400037B7;
    rom[95]  = 32'h0007A623;
    rom[96]  = 32'h01478693;
    rom[97]  = 32'h0006A783;
    rom[98]  = 32'h0017F793;
    rom[99]  = 32'hFE079CE3;
    rom[100] = 32'h400037B7;
    rom[101] = 32'h0107A503;
    rom[102] = 32'h400037B7;
    rom[103] = 32'h0007A623;
    rom[104] = 32'h0FF57513;
    rom[105] = 32'h01478693;
    rom[106] = 32'h0006A783;
    rom[107] = 32'h0017F793;
    rom[108] = 32'hFE079CE3;
    rom[109] = 32'h400037B7;
    rom[110] = 32'h0107A583;
    rom[111] = 32'h400037B7;
    rom[112] = 32'h0007A623;
    rom[113] = 32'h0FF5F593;
    rom[114] = 32'h00859593;
    rom[115] = 32'h01478693;
    rom[116] = 32'h0006A783;
    rom[117] = 32'h0017F793;
    rom[118] = 32'hFE079CE3;
    rom[119] = 32'h400037B7;
    rom[120] = 32'h0107A603;
    rom[121] = 32'h400037B7;
    rom[122] = 32'h0007A623;
    rom[123] = 32'h0FF67613;
    rom[124] = 32'h01061613;
    rom[125] = 32'h01478693;
    rom[126] = 32'h0006A783;
    rom[127] = 32'h0017F793;
    rom[128] = 32'hFE079CE3;
    rom[129] = 32'h400037B7;
    rom[130] = 32'h0107A803;
    rom[131] = 32'h400037B7;
    rom[132] = 32'h0007A623;
    rom[133] = 32'h01881813;
    rom[134] = 32'h00A86833;
    rom[135] = 32'h00B86833;
    rom[136] = 32'h00C86833;
    rom[137] = 32'h01478693;
    rom[138] = 32'h0006A783;
    rom[139] = 32'h0017F793;
    rom[140] = 32'hFE079CE3;
    rom[141] = 32'h400037B7;
    rom[142] = 32'h0107A883;
    rom[143] = 32'h400037B7;
    rom[144] = 32'h0007A623;
    rom[145] = 32'h0FF8F893;
    rom[146] = 32'h01478693;
    rom[147] = 32'h0006A783;
    rom[148] = 32'h0017F793;
    rom[149] = 32'hFE079CE3;
    rom[150] = 32'h400037B7;
    rom[151] = 32'h0107A583;
    rom[152] = 32'h400037B7;
    rom[153] = 32'h0007A623;
    rom[154] = 32'h0FF5F593;
    rom[155] = 32'h00859593;
    rom[156] = 32'h01478693;
    rom[157] = 32'h0006A783;
    rom[158] = 32'h0017F793;
    rom[159] = 32'hFE079CE3;
    rom[160] = 32'h400037B7;
    rom[161] = 32'h0107A603;
    rom[162] = 32'h400037B7;
    rom[163] = 32'h0007A623;
    rom[164] = 32'h0FF67613;
    rom[165] = 32'h01061613;
    rom[166] = 32'h01478693;
    rom[167] = 32'h0006A783;
    rom[168] = 32'h0017F793;
    rom[169] = 32'hFE079CE3;
    rom[170] = 32'h400037B7;
    rom[171] = 32'h0107A503;
    rom[172] = 32'h400037B7;
    rom[173] = 32'h0007A623;
    rom[174] = 32'h01851513;
    rom[175] = 32'h01156533;
    rom[176] = 32'h00B56533;
    rom[177] = 32'h00C56533;
    rom[178] = 32'h01478693;
    rom[179] = 32'h0006A783;
    rom[180] = 32'h0017F793;
    rom[181] = 32'hFE079CE3;
    rom[182] = 32'h400037B7;
    rom[183] = 32'h0107A303;
    rom[184] = 32'h400037B7;
    rom[185] = 32'h0007A623;
    rom[186] = 32'h0FF37313;
    rom[187] = 32'h01478693;
    rom[188] = 32'h0006A783;
    rom[189] = 32'h0017F793;
    rom[190] = 32'hFE079CE3;
    rom[191] = 32'h400037B7;
    rom[192] = 32'h0107A883;
    rom[193] = 32'h400037B7;
    rom[194] = 32'h0007A623;
    rom[195] = 32'h0FF8F893;
    rom[196] = 32'h00889893;
    rom[197] = 32'h01478693;
    rom[198] = 32'h0006A783;
    rom[199] = 32'h0017F793;
    rom[200] = 32'hFE079CE3;
    rom[201] = 32'h400037B7;
    rom[202] = 32'h0107A603;
    rom[203] = 32'h400037B7;
    rom[204] = 32'h0007A623;
    rom[205] = 32'h0FF67613;
    rom[206] = 32'h01061613;
    rom[207] = 32'h01478693;
    rom[208] = 32'h0006A783;
    rom[209] = 32'h0017F793;
    rom[210] = 32'hFE079CE3;
    rom[211] = 32'h400035B7;
    rom[212] = 32'h0105A783;
    rom[213] = 32'h00001EB7;
    rom[214] = 32'h00EEA023;
    rom[215] = 32'h01879793;
    rom[216] = 32'h0067E7B3;
    rom[217] = 32'h0117E7B3;
    rom[218] = 32'h010EA223;
    rom[219] = 32'h00C7E7B3;
    rom[220] = 32'h00AEA423;
    rom[221] = 32'h00FEA623;
    rom[222] = 32'h01000893;
    rom[223] = 32'h01058593;
    rom[224] = 32'h08A8FE63;
    rom[225] = 32'h40003337;
    rom[226] = 32'h400037B7;
    rom[227] = 32'h00C30313;
    rom[228] = 32'h01478793;
    rom[229] = 32'h00FF0F37;
    rom[230] = 32'h00032023;
    rom[231] = 32'h011E8E33;
    rom[232] = 32'h0007A703;
    rom[233] = 32'h00177713;
    rom[234] = 32'hFE071CE3;
    rom[235] = 32'h0005AF83;
    rom[236] = 32'h00032023;
    rom[237] = 32'h0FFFFF93;
    rom[238] = 32'h0007A703;
    rom[239] = 32'h00177713;
    rom[240] = 32'hFE071CE3;
    rom[241] = 32'h0005A603;
    rom[242] = 32'h00032023;
    rom[243] = 32'h0FF67613;
    rom[244] = 32'h00861613;
    rom[245] = 32'h0007A703;
    rom[246] = 32'h00177713;
    rom[247] = 32'hFE071CE3;
    rom[248] = 32'h0005A683;
    rom[249] = 32'h00032023;
    rom[250] = 32'h01069693;
    rom[251] = 32'h01E6F6B3;
    rom[252] = 32'h0007A703;
    rom[253] = 32'h00177713;
    rom[254] = 32'hFE071CE3;
    rom[255] = 32'h0005A703;
    rom[256] = 32'h00488893;
    rom[257] = 32'h01871713;
    rom[258] = 32'h01F76733;
    rom[259] = 32'h00C76733;
    rom[260] = 32'h00D76733;
    rom[261] = 32'h00EE2023;
    rom[262] = 32'hF8A8E0E3;
    rom[263] = 32'h400037B7;
    rom[264] = 32'h00100713;
    rom[265] = 32'h00E7A223;
    rom[266] = 32'h00080067;
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
