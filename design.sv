`include "simd_alu_defines.vh"
`include "simd_alu_adder_top.v"

module simd_alu_top(
  input     							clk,
  input									rst_n,
  input 	[SIMD_DATA_WIDTH - 1 : 0] 	in_a,
  input 	[SIMD_DATA_WIDTH - 1 : 0] 	in_b,
  input     [SIMD_OPC_WIDTH - 1 : 0]  	opcode,
  output 	[SIMD_DATA_WIDTH - 1 : 0] 	out,
  output	[SIMD_DATA_WIDTH/8 - 1 : 0]	out_overflow,
  output	[SIMD_DATA_WIDTH/8 - 1 : 0]	out_underflow
);
  
  reg [SIMD_DATA_WIDTH - 1 : 0] r_a;
  reg [SIMD_DATA_WIDTH - 1 : 0] r_b;
  reg [SIMD_ADDER_DATA_MODE_WIDTH - 1 : 0]	r_data_mode;
  reg [SIMD_DATA_WIDTH - 1 : 0] r_adder_out;
  reg [SIMD_DATA_WIDTH - 1 : 0] r_out;
  
  wire w_data_signed;
  wire sub;
  
  simd_alu_adder_top adder(
    .a(r_a),
    .b(r_b),
    .data_mode(r_data_mode),
    .data_signed(w_data_signed),
    .sub(sub),
    .result(r_adder_out),
    .ovf(out_overflow),
    .udf(out_underflow)
  );
  
  //when opcode defines signed data operation then this variable is set to "1"
  assign w_data_signed = 
    (opcode == S_ADD8)  ||
    (opcode == S_ADD16) ||
    (opcode == S_ADD32) ||
    (opcode == S_ADD64) ||
    (opcode == S_SUB8)  ||
    (opcode == S_SUB16) ||
    (opcode == S_SUB32) ||
    (opcode == S_SUB64);
  
  assign sub = 
    (opcode == SUB8)    ||
    (opcode == SUB16)   ||
    (opcode == SUB32)   ||
    (opcode == SUB64)   ||
    (opcode == S_SUB8)  ||
    (opcode == S_SUB16) ||
    (opcode == S_SUB32) ||
    (opcode == S_SUB64);
  
  assign out = r_out;
  
  //make registered inputs
  always @(posedge clk) begin
    r_a = in_a;
    r_b = in_b;
  end
  
  //select ALU input arguments data chunk size
  always @(posedge clk) begin
    case (opcode)
      ADD8, S_ADD8, SUB8, S_SUB8         : r_data_mode = 0;// 8-bits input argument chunks
      ADD16, S_ADD16, SUB16, S_SUB16     : r_data_mode = 1;// 16-bits input argument chunks
      ADD32, S_ADD32, SUB32, S_SUB32     : r_data_mode = 2;// 32-bits input argument chunks
      ADD64, S_ADD64, SUB64, S_SUB64     : r_data_mode = 3;// 64-bits input argument chunks 
      default : r_data_mode = 0;
    endcase
  end
  
  //math block's result operation selector
  always @(*) begin
    case (opcode)
      ADD8, S_ADD8, ADD16, S_ADD16, ADD32, S_ADD32, ADD64, S_ADD64, SUB8, SUB16, SUB32, SUB64, S_SUB8, S_SUB16, S_SUB32, S_SUB64  : r_out = r_adder_out;
      default : r_out = 0;
    endcase
  end
  
  always @(posedge clk)
    begin
      if (~rst_n) begin
        
      end else begin
        
      end
    end
  
endmodule : simd_alu_top