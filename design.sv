`include "simd_alu_defines.vh"
`include "simd_alu_adder_top.v"
`include "simd_alu_shifter_top.v"
`include "simd_alu_comparer_top.v"

module simd_alu_top(
  input     							clk,
  input									rst_n,
  input 	[SIMD_DATA_WIDTH - 1 : 0] 	in_a,
  input 	[SIMD_DATA_WIDTH - 1 : 0] 	in_b,
  input     [SIMD_OPC_WIDTH - 1 : 0]  	opcode,
  output 	[SIMD_DATA_WIDTH - 1 : 0] 	out,
  output	[SIMD_DATA_WIDTH/8 - 1 : 0]	out_overflow
);
  
  reg [SIMD_DATA_WIDTH - 1 : 0] r_a;
  reg [SIMD_DATA_WIDTH - 1 : 0] r_b;
  reg [SIMD_OPC_WIDTH - 1 : 0] r_opcode;
  reg [SIMD_ADDER_DATA_MODE_WIDTH - 1 : 0]	r_data_mode;
  reg [SIMD_DATA_WIDTH - 1 : 0] r_adder_out;
  reg [SIMD_DATA_WIDTH - 1 : 0] r_shifter_out;
  reg [SIMD_DATA_WIDTH - 1 : 0] r_comparer_out;
  reg [SIMD_DATA_WIDTH - 1 : 0] r_out;
  
  wire w_data_signed;
  wire w_sub;
  wire w_left;
  wire w_gt_comp;
  
  simd_alu_adder_top adder(
    .a(r_a),
    .b(r_b),
    .data_mode(r_data_mode),
    .data_signed(w_data_signed),
    .sub(w_sub),
    .result(r_adder_out),
    .ovf(out_overflow)
  );
  
  simd_alu_shifter_top shifter(
    .a(r_a),
    .b(r_b),
    .data_mode(r_data_mode),
    .left(w_left),
    .result(r_shifter_out)
  );
  
  simd_alu_comparer_top comparer(
    .a(r_a),
    .b(r_b),
    .data_mode(r_data_mode),
    .gt_comparison(w_gt_comp),
    .result(r_comparer_out)
  );
  
  //when opcode defines signed data operation then w_data_signed is set to "1"
  assign w_data_signed = 
    (r_opcode == S_ADD8)  ||
    (r_opcode == S_ADD16) ||
    (r_opcode == S_ADD32) ||
    (r_opcode == S_ADD64) ||
    (r_opcode == S_SUB8)  ||
    (r_opcode == S_SUB16) ||
    (r_opcode == S_SUB32) ||
    (r_opcode == S_SUB64);
  
  //when opcode defines substruction operation then w_sub is set to "1"
  assign w_sub = 
    (r_opcode == SUB8)    ||
    (r_opcode == SUB16)   ||
    (r_opcode == SUB32)   ||
    (r_opcode == SUB64)   ||
    (r_opcode == S_SUB8)  ||
    (r_opcode == S_SUB16) ||
    (r_opcode == S_SUB32) ||
    (r_opcode == S_SUB64);
  
  //when opcode defines left shift operation then w_left is set to "1", otherwise it defines right shift
  assign w_left = 
    (r_opcode == LSL8)  ||
    (r_opcode == LSL16) ||
    (r_opcode == LSL32) ||
    (r_opcode == LSL64);
  
  //when opcode defines greater comparison operation then w_gt_comp is set to "1", otherwise it defines equality comparison
  assign w_gt_comp = 
    (r_opcode == GT8)  ||
    (r_opcode == GT16) ||
    (r_opcode == GT32) ||
    (r_opcode == GT64);
  
  assign out = r_out;
  
  //make registered inputs
  always @(posedge clk) begin
    if (~rst_n) begin
      r_a <= 0;
      r_b <= 0;
    end else begin
      r_a <= in_a;
      r_b <= in_b;
    end
  end
  
  always @(posedge clk) begin
      if (~rst_n) begin
        r_opcode <= 0;
      end else begin
        r_opcode <= opcode;
      end
  end
  
  //select ALU input arguments data chunk size
  always @(*) begin
    case (r_opcode)
      ADD8, S_ADD8, SUB8, S_SUB8, LSL8, LSR8, CMP8, GT8          : r_data_mode <= 0;// 8-bits input argument chunks
      ADD16, S_ADD16, SUB16, S_SUB16, LSL16, LSR16, CMP16, GT16  : r_data_mode <= 1;// 16-bits input argument chunks
      ADD32, S_ADD32, SUB32, S_SUB32, LSL32, LSR32, CMP32, GT32  : r_data_mode <= 2;// 32-bits input argument chunks
      ADD64, S_ADD64, SUB64, S_SUB64, LSL64, LSR64, CMP64, GT64  : r_data_mode <= 3;// 64-bits input argument chunks 
      default : r_data_mode = 0;
    endcase
  end
  
  //math block's result operation selector
  always @(*) begin
    case (r_opcode)
      ADD8, S_ADD8, ADD16, S_ADD16, ADD32, S_ADD32, ADD64, S_ADD64, SUB8, SUB16, SUB32, SUB64, S_SUB8, S_SUB16, S_SUB32, S_SUB64  : r_out = r_adder_out;
      LSL8, LSL16, LSL32, LSL64, LSR8, LSR16, LSR32, LSR64   : r_out = r_shifter_out;
      CMP8, CMP16, CMP32, CMP64, GT8, GT16, GT32, GT64       : r_out = r_comparer_out;
      default : r_out = 0;
    endcase
  end
  
endmodule : simd_alu_top