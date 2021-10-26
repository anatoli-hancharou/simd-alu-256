`ifndef _SIMD_ALU_DEFINES_VH_
`define _SIMD_ALU_DEFINES_VH_
	parameter SIMD_DATA_WIDTH               = 256;
	parameter SIMD_OPC_WIDTH                = 5;
	parameter SIMD_ADDER_DATA_MODE_WIDTH    = 2;

	parameter MSB_8B                        = 7;//MostSignificantBit of 8-bits data

	parameter NOP                           = 0;
	parameter ADD8                          = 1;
	parameter ADD16                         = 2;
	parameter ADD32                         = 3;
	parameter ADD64                         = 4;
	parameter S_ADD8                        = 5;
	parameter S_ADD16                       = 6;
	parameter S_ADD32                       = 7;
	parameter S_ADD64                       = 8;

	parameter SUB8                          = 9;
	parameter SUB16                         = 10;
	parameter SUB32                         = 11;
	parameter SUB64                         = 12;
	parameter S_SUB8                        = 13;
	parameter S_SUB16                       = 14;
	parameter S_SUB32                       = 15;
	parameter S_SUB64                       = 16;

    parameter LSL8                          = 17;
	parameter LSL16                         = 18;
	parameter LSL32                         = 19;
	parameter LSL64                         = 20;
	parameter LSR8                          = 21;
	parameter LSR16                         = 22;
	parameter LSR32                         = 23;
	parameter LSR64                         = 24;

`endif
