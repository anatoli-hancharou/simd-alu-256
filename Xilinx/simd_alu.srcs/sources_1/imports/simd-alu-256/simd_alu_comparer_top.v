module simd_alu_comparer_top (
  input [SIMD_DATA_WIDTH - 1 : 0]               a,
  input [SIMD_DATA_WIDTH - 1 : 0]               b,
  input                                         gt_comparison,
  input [SIMD_ADDER_DATA_MODE_WIDTH - 1 : 0]    data_mode,
  
  output [SIMD_DATA_WIDTH - 1 : 0]              result
);
  
reg [SIMD_DATA_WIDTH - 1 : 0] r_res;
  
  reg [5:0] _idx;//for loop iterator

  always @(*) begin
    case(data_mode)
      0 : begin : cmp_8b_sel // 8-bits data chunk
        reg [7 : 0] A, B;
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/8; _idx = _idx + 1) begin
          A = a[(_idx + 1)*8 - 1 -: 8];
          B = b[(_idx + 1)*8 - 1 -: 8];
          r_res[(_idx + 1)*8 - 1 -: 8] = gt_comparison ? A > B : A === B;
      	end
      end
      1: begin : cmp_16b_sel // 16-bits data chunk
        reg [15 : 0] A, B;
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/16; _idx = _idx + 1) begin
          A = a[(_idx + 1)*16 - 1 -: 16];
          B = b[(_idx + 1)*16 - 1 -: 16];
          r_res[(_idx + 1)*16 - 1 -: 16] = gt_comparison ? A > B : A === B;
      	end
      end
      2: begin : cmp_32b_sel// 32-bits data chunk
        reg [31 : 0] A, B;
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/32; _idx = _idx + 1) begin
          A = a[(_idx + 1)*32 - 1 -: 32];
          B = b[(_idx + 1)*32 - 1 -: 32];
          r_res[(_idx + 1)*32 - 1 -: 32] = gt_comparison ? A > B : A === B;
      	end
      end
      3 : begin : cmp_64b_sel// 64-bits data chunk
        reg [63 : 0] A, B;
        //$display("##### A=%0d B=%0d", A[63:0], B[63:0]);
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/64; _idx = _idx + 1) begin
          A = a[(_idx + 1)*64 - 1 -: 64];
          B = b[(_idx + 1)*64 - 1 -: 64];
          r_res[(_idx + 1)*64 - 1 -: 64] = gt_comparison ? A > B : A === B;
      	end
      end
      default : r_res = 0;
    endcase
  end
  
  assign result = r_res;
  
endmodule : simd_alu_comparer_top