module simd_alu_adder_top (
  input [SIMD_DATA_WIDTH - 1 : 0] 				a,
  input [SIMD_DATA_WIDTH - 1 : 0] 				b,
  input [SIMD_ADDER_DATA_MODE_WIDTH - 1 : 0] 	data_mode,
  input											data_signed,
  output [SIMD_DATA_WIDTH - 1 : 0]				result
);
  
  reg [SIMD_DATA_WIDTH - 1 : 0] r_inner_res;
  reg signed [8 - 1 : 0] r_s_a8;
  reg signed [8 - 1 : 0] r_s_b8;
  reg signed [16 - 1 : 0] r_s_a16;
  reg signed [16 - 1 : 0] r_s_b16;
  
  
  int _idx;//for loop iterator
  
  always @(*) begin
    case(data_mode)
      0 : begin // 8-bits data chunk
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/8; _idx++) begin
          if (~data_signed) begin // unsigned data
          	r_inner_res[(_idx + 1)*8 - 1 -: 8] = a[(_idx + 1)*8 - 1 -: 8] + b[(_idx + 1)*8 - 1 -: 8];
          end else begin // signed two's complement data
            r_s_a8 = a[(_idx + 1)*8 - 1 -: 8];
            r_s_b8 = b[(_idx + 1)*8 - 1 -: 8];
            r_inner_res[(_idx + 1)*8 - 1 -: 8] = r_s_a8 + r_s_b8;
          end
      	end
      end
      1 : begin // 16-bits data chunk
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/16; _idx++) begin
          if (~data_signed) begin // unsigned data
          	r_inner_res[(_idx + 1)*16 - 1 -: 16] = a[(_idx + 1)*16 - 1 -: 16] + b[(_idx + 1)*16 - 1 -: 16];
          end else begin // signed two's complement data
            r_s_a16 = a[(_idx + 1)*16 - 1 -: 16];
            r_s_b16 = b[(_idx + 1)*16 - 1 -: 16];
            r_inner_res[(_idx + 1)*16 - 1 -: 16] = r_s_a16 + r_s_b16;
          end
      	end
      end
      default : r_inner_res = 0;
    endcase
  end
  
  assign result = r_inner_res;
  
endmodule : simd_alu_adder_top