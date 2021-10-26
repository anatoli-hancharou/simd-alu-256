module simd_alu_shifter_top (
  input [SIMD_DATA_WIDTH - 1 : 0]               a,
  input [SIMD_DATA_WIDTH - 1 : 0]               b,
  input [SIMD_ADDER_DATA_MODE_WIDTH - 1 : 0]    data_mode,
  input                                         left,
  output [SIMD_DATA_WIDTH - 1 : 0]              result
);
  
  reg [SIMD_DATA_WIDTH - 1 : 0] r_res;
  
  int _idx;//for loop iterator

  always @(*) begin
    case(data_mode)
      0 : begin // 8-bits data chunk
        reg [7 : 0] A, B;
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/8; _idx++) begin
          A = a[(_idx + 1)*8 - 1 -: 8];
          B = b[(_idx + 1)*8 - 1 -: 8];
          r_res[(_idx + 1)*8 - 1 -: 8] = left ? A << B : A >> B;
      	end
      end
      1: begin // 16-bits data chunk
        reg [15 : 0] A, B;
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/16; _idx++) begin
          A = a[(_idx + 1)*16 - 1 -: 16];
          B = b[(_idx + 1)*16 - 1 -: 16];
          r_res[(_idx + 1)*16 - 1 -: 16] = left ? A << B : A >> B;
      	end
      end
      2: begin // 32-bits data chunk
        reg [31 : 0] A, B;
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/32; _idx++) begin
          A = a[(_idx + 1)*32 - 1 -: 32];
          B = b[(_idx + 1)*32 - 1 -: 32];
          r_res[(_idx + 1)*32 - 1 -: 32] = left ? A << B : A >> B;
      	end
      end
      3 : begin // 64-bits data chunk
        reg [63 : 0] A, B;
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/64; _idx++) begin
          A = a[(_idx + 1)*64 - 1 -: 64];
          B = b[(_idx + 1)*64 - 1 -: 64];
          r_res[(_idx + 1)*64 - 1 -: 64] = left ? A << B : A >> B;
      	end
      end
      default : r_res = 0;
    endcase
  end
  
  assign result = r_res;
  
endmodule : simd_alu_shifter_top