module simd_alu_adder_top (
  input [SIMD_DATA_WIDTH - 1 : 0]               a,
  input [SIMD_DATA_WIDTH - 1 : 0]               b,
  input [SIMD_ADDER_DATA_MODE_WIDTH - 1 : 0]    data_mode,
  input                                         data_signed,
  input                                         sub,
  output [SIMD_DATA_WIDTH - 1 : 0]              result,
  output [SIMD_DATA_WIDTH/8 - 1 : 0]            ovf,
  output [SIMD_DATA_WIDTH/8 - 1 : 0]            udf
);
  
  reg [SIMD_DATA_WIDTH - 1 : 0] r_res;
  reg [SIMD_DATA_WIDTH/8 - 1 : 0] r_ovf;
  reg signed [8 - 1 : 0] r_s_a8;
  reg signed [8 - 1 : 0] r_s_b8;
  reg signed [16 - 1 : 0] r_s_a16;
  reg signed [16 - 1 : 0] r_s_b16;
  reg signed [32 - 1 : 0] r_s_a32;
  reg signed [32 - 1 : 0] r_s_b32;
  reg signed [64 - 1 : 0] r_s_a64;
  reg signed [64 - 1 : 0] r_s_b64;
  
  
  int _idx;//for loop iterator
  
  wire [SIMD_DATA_WIDTH - 1 : 0] B_real = sub?(~b):b;

  // Data Overflow check is implemented for 8-bits data only
  always @(*) begin
    r_ovf = '0;
    case(data_mode)
      0 : begin // 8-bits data chunk
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/8; _idx++) begin
          if (~data_signed) begin // unsigned data
            r_res[(_idx + 1)*8 - 1 -: 8] = a[(_idx + 1)*8 - 1 -: 8] + B_real[(_idx + 1)*8 - 1 -: 8] + sub;
            //check data overflow condition
            r_ovf[_idx] = (r_s_a8[MSB_8B] | r_s_b8[MSB_8B]) & ~(r_res[MSB_8B]);
          end else begin // signed two's complement data
            r_s_a8 = a[(_idx + 1)*8 - 1 -: 8];
            r_s_b8 = B_real[(_idx + 1)*8 - 1 -: 8];
            r_res[(_idx + 1)*8 - 1 -: 8] = r_s_a8 + r_s_b8 + sub;
            //check data overflow condition
            r_ovf[_idx] = ~(r_s_a8[MSB_8B] ^ r_s_b8[MSB_8B]) & (r_s_a8[MSB_8B] ^ r_res[MSB_8B]);
          end
      	end
      end
      1 : begin // 16-bits data chunk
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/16; _idx++) begin
          if (~data_signed) begin // unsigned data
          	r_res[(_idx + 1)*16 - 1 -: 16] = a[(_idx + 1)*16 - 1 -: 16] + B_real[(_idx + 1)*16 - 1 -: 16] + sub;
          end else begin // signed two's complement data
            r_s_a16 = a[(_idx + 1)*16 - 1 -: 16];
            r_s_b16 = B_real[(_idx + 1)*16 - 1 -: 16];
            r_res[(_idx + 1)*16 - 1 -: 16] = r_s_a16 + r_s_b16 + sub;
          end
      	end
      end
      2 : begin // 32-bits data chunk 
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/32; _idx++) begin 
          if (~data_signed) begin // unsigned data 
            r_res[(_idx + 1)*32 - 1 -: 32] = a[(_idx + 1)*32 - 1 -: 32] + B_real[(_idx + 1)*32 - 1 -: 32] + sub; 
          end else begin // signed two's complement data 
            r_s_a32 = a[(_idx + 1)*32 - 1 -: 32]; 
            r_s_b32 = B_real[(_idx + 1)*32 - 1 -: 32]; 
            r_res[(_idx + 1)*32 - 1 -: 32] = r_s_a32 + r_s_b32 + sub; 
          end 
       end 
      end
      3 : begin //64-bits data chunk 
        for (_idx = 0; _idx < SIMD_DATA_WIDTH/64; _idx++) begin 
          if (~data_signed) begin // unsigned data 
            r_res[(_idx + 1)*64 - 1 -: 64] = a[(_idx + 1)*64 - 1 -: 64] + B_real[(_idx + 1)*64 - 1 -: 64] + sub; 
          end else begin // signed two's complement data 
            r_s_a64 = a[(_idx + 1)*64 - 1 -: 64]; 
            r_s_b64 = B_real[(_idx + 1)*64 - 1 -: 64]; 
            r_res[(_idx + 1)*64 - 1 -: 64] = r_s_a64 + r_s_b64 + sub; 
          end 
       end 
      end
      default : r_res = 0;
    endcase
  end
  
  assign result = r_res;
  assign ovf = r_ovf;
  
endmodule : simd_alu_adder_top