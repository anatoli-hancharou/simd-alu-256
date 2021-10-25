module tb_top();
  
parameter CLOCK_PERIOD = 10;
  
  reg clock;
  reg reset_n;
  
  reg [8 - 1 : 0] a_arg8[SIMD_DATA_WIDTH/8];
  reg [8 - 1 : 0] b_arg8[SIMD_DATA_WIDTH/8];
  reg signed [8 - 1 : 0] s_a_arg8[SIMD_DATA_WIDTH/8];
  reg signed [8 - 1 : 0] s_b_arg8[SIMD_DATA_WIDTH/8];
  reg signed [8 - 1 : 0] r_s_res8;
  
  reg [16 - 1 : 0] a_arg16[SIMD_DATA_WIDTH/16];
  reg [16 - 1 : 0] b_arg16[SIMD_DATA_WIDTH/16];
  reg signed [16 - 1 : 0] s_a_arg16[SIMD_DATA_WIDTH/16];
  reg signed [16 - 1 : 0] s_b_arg16[SIMD_DATA_WIDTH/16];
  reg signed [16 - 1 : 0] r_s_res16;
  
  reg [32 - 1 : 0] a_arg32[SIMD_DATA_WIDTH/32];
  reg [32 - 1 : 0] b_arg32[SIMD_DATA_WIDTH/32];
  reg signed [32 - 1 : 0] s_a_arg32[SIMD_DATA_WIDTH/32];
  reg signed [32 - 1 : 0] s_b_arg32[SIMD_DATA_WIDTH/32];
  reg signed [32 - 1 : 0] r_s_res32;
  
  reg [64 - 1 : 0] a_arg64[SIMD_DATA_WIDTH/64];
  reg [64 - 1 : 0] b_arg64[SIMD_DATA_WIDTH/64];
  reg signed [64 - 1 : 0] s_a_arg64[SIMD_DATA_WIDTH/64];
  reg signed [64 - 1 : 0] s_b_arg64[SIMD_DATA_WIDTH/64];
  reg signed [64 - 1 : 0] r_s_res64;
  
  reg [SIMD_DATA_WIDTH - 1 : 0] 	simd_alu_arg_a;
  reg [SIMD_DATA_WIDTH - 1 : 0] 	simd_alu_arg_b;
  
  reg [SIMD_OPC_WIDTH - 1 : 0] 		simd_opcode;
  
  wire [SIMD_DATA_WIDTH - 1 : 0] 	simd_alu_out;
  wire [SIMD_DATA_WIDTH/8 - 1 : 0]	is_ovf;// two check that math operation overflow occured
  wire [SIMD_DATA_WIDTH/8 - 1 : 0]	is_udf;// two check that math operation underflow occured
  
  int data_idx, data_chunk_idx;//for loop iterator
  int error_cnt = 0;
  
  initial begin
    clock = 1;
    simd_opcode = NOP;
    reset_n = 0;//activate a negative reset
    #(CLOCK_PERIOD*2);
    reset_n = 1;//de-activate a reset
  end
  
  //clock generator
  always #(CLOCK_PERIOD/2) begin
  	clock = ~clock;
  end
  
  simd_alu_top simd_alu(
    .clk(clock),
    .rst_n(reset_n),
    .in_a(simd_alu_arg_a),
    .in_b(simd_alu_arg_b),
    .opcode(simd_opcode),
    .out(simd_alu_out),
    .out_overflow(is_ovf), // overflow while summ the data
    .out_underflow(is_udf)  // undeflow while substruct the data
  );
  
  // make SIMD ALU input Data vectors (A and B)
  always @(*) begin
    case (simd_opcode)
      ADD8, SUB8:
        // fill 256-bits data vector by chunk with unsigned data array elements
        for (data_chunk_idx = 0; data_chunk_idx < SIMD_DATA_WIDTH/8; data_chunk_idx++) begin
          simd_alu_arg_a[(data_chunk_idx + 1)*8 - 1 -: 8] = a_arg8[data_chunk_idx];
          simd_alu_arg_b[(data_chunk_idx + 1)*8 - 1 -: 8] = b_arg8[data_chunk_idx];
      end
      S_ADD8:
        // fill 256-bits data vector by chunk with Signed data array elements
        for (data_chunk_idx = 0; data_chunk_idx < SIMD_DATA_WIDTH/8; data_chunk_idx++) begin
          simd_alu_arg_a[(data_chunk_idx + 1)*8 - 1 -: 8] = s_a_arg8[data_chunk_idx];
          simd_alu_arg_b[(data_chunk_idx + 1)*8 - 1 -: 8] = s_b_arg8[data_chunk_idx];
      end
      ADD16, SUB16:
        for (data_chunk_idx = 0; data_chunk_idx < SIMD_DATA_WIDTH/16; data_chunk_idx++) begin
          simd_alu_arg_a[(data_chunk_idx + 1)*16 - 1 -: 16] = a_arg16[data_chunk_idx];
          simd_alu_arg_b[(data_chunk_idx + 1)*16 - 1 -: 16] = b_arg16[data_chunk_idx];
      end
      S_ADD16:
        for (data_chunk_idx = 0; data_chunk_idx < SIMD_DATA_WIDTH/16; data_chunk_idx++) begin
          simd_alu_arg_a[(data_chunk_idx + 1)*16 - 1 -: 16] = s_a_arg16[data_chunk_idx];
          simd_alu_arg_b[(data_chunk_idx + 1)*16 - 1 -: 16] = s_b_arg16[data_chunk_idx];
      end
      ADD32, SUB32:
        for (data_chunk_idx = 0; data_chunk_idx < SIMD_DATA_WIDTH/32; data_chunk_idx++) begin
          simd_alu_arg_a[(data_chunk_idx + 1)*32 - 1 -: 32] = a_arg32[data_chunk_idx];
          simd_alu_arg_b[(data_chunk_idx + 1)*32 - 1 -: 32] = b_arg32[data_chunk_idx];
      end
      S_ADD32:
        for (data_chunk_idx = 0; data_chunk_idx < SIMD_DATA_WIDTH/32; data_chunk_idx++) begin
          simd_alu_arg_a[(data_chunk_idx + 1)*32 - 1 -: 32] = s_a_arg32[data_chunk_idx];
          simd_alu_arg_b[(data_chunk_idx + 1)*32 - 1 -: 32] = s_b_arg32[data_chunk_idx];
      end
      ADD64, SUB64:
        for (data_chunk_idx = 0; data_chunk_idx < SIMD_DATA_WIDTH/64; data_chunk_idx++) begin
          simd_alu_arg_a[(data_chunk_idx + 1)*64 - 1 -: 64] = a_arg64[data_chunk_idx];
          simd_alu_arg_b[(data_chunk_idx + 1)*64 - 1 -: 64] = b_arg64[data_chunk_idx];
      end
      S_ADD64:
        for (data_chunk_idx = 0; data_chunk_idx < SIMD_DATA_WIDTH/64; data_chunk_idx++) begin
          simd_alu_arg_a[(data_chunk_idx + 1)*64 - 1 -: 64] = s_a_arg64[data_chunk_idx];
          simd_alu_arg_b[(data_chunk_idx + 1)*64 - 1 -: 64] = s_b_arg64[data_chunk_idx];
      end
      
      
      default : begin
        simd_alu_arg_a = 0;
        simd_alu_arg_b = 0;
      end 
    endcase
  end
  
  // TEST sequence
  initial begin
    
    // ************ 8-bits data ************ //
    #(CLOCK_PERIOD*2);
    $display("\n%tns: Start ADD8 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/8; data_idx++) begin
      a_arg8[data_idx] = 0 + data_idx;
      b_arg8[data_idx] = 32 - data_idx;
    end
    simd_opcode = ADD8;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results 
    $display("%tns: Check the results of the ADD8 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/8; data_idx++) begin
      if (simd_alu_out[(data_idx + 1)*8 - 1 -: 8] !== 32) begin
        $display("\tWrong ADD8 test result: got %0d (!= 32), while arg_a=%0d and arg_b=%0d", simd_alu_out[(data_idx + 1)*8 - 1 -: 8], a_arg8[data_idx], b_arg8[data_idx]);
        error_cnt++;
      end
    end
    
    #(CLOCK_PERIOD);
    $display("%tns: Start S_ADD8 operation:", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/8; data_idx++) begin
      s_a_arg8[data_idx] = 0 - data_idx;
      s_b_arg8[data_idx] = -32 + data_idx;
    end
    simd_opcode = S_ADD8;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results
    $display("%tns: Check the results of the S_ADD8 operation:", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/8; data_idx++) begin
      r_s_res8 = simd_alu_out[(data_idx + 1)*8 - 1 -: 8];
      if (r_s_res8 !== -32) begin
        $display("\tWrong S_ADD8 test result: got %0d (!= -32), while arg_a=%0d and arg_b=%0d", r_s_res8, s_a_arg8[data_idx], s_b_arg8[data_idx]);
        error_cnt++;
      end
    end
    
    #(CLOCK_PERIOD*2);
    $display("\n%tns: Start SUB8 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/8; data_idx++) begin
      a_arg8[data_idx] = 255;
      b_arg8[data_idx] = 0;
    end
    simd_opcode = SUB8;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results 
    $display("%tns: Check the results of the SUB8 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/8; data_idx++) begin
      if (simd_alu_out[(data_idx + 1)*8 - 1 -: 8] !== 255) begin
        $display("\tWrong SUB8 test result: got %0d (!= 255), while arg_a=%0d and arg_b=%0d", simd_alu_out[(data_idx + 1)*8 - 1 -: 8], a_arg8[data_idx], b_arg8[data_idx]);
        error_cnt++;
      end
    end
   
    // ************ check data overflow flags set ************* //
    #(CLOCK_PERIOD);
    $display("%tns: Start S_ADD8 operation with result data overflow:", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/8; data_idx++) begin
      s_a_arg8[data_idx] = 127;
      s_b_arg8[data_idx] = 127;
    end
    simd_opcode = S_ADD8;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results
    $display("%tns: Check the results of the S_ADD8 (data overflow) operation:", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/8; data_idx++) begin
      r_s_res8 = simd_alu_out[(data_idx + 1)*8 - 1 -: 8];
      //expected results(signed data): 0x7F + 0x7F = 0xFE -> decimal value "-2" and Data Overflow flag should be set
      if (r_s_res8 !== -2 || ~is_ovf[data_idx]) begin
        $display("\tWrong S_ADD8 with data overflow test result: got %0d (expected -2) and Overflow flag=b'%0b (expected b'1), while arg_a=%0d and arg_b=%0d", r_s_res8, is_ovf[data_idx], s_a_arg8[data_idx], s_b_arg8[data_idx]);
        error_cnt++;
      end
    end
    
    // ************ 16-bits data ************ //
    #(CLOCK_PERIOD);
    $display("%tns: Start ADD16 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/16; data_idx++) begin
      a_arg16[data_idx] = 0 + data_idx;
      b_arg16[data_idx] = 32767 - data_idx;
    end
    simd_opcode = ADD16;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results 
    $display("%tns: Check the results of the ADD16 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/16; data_idx++) begin
      if (simd_alu_out[(data_idx + 1)*16 - 1 -: 16] !== 32767) begin
        $display("\tWrong ADD16 test result: got %0d (!= 32767), while arg_a=%0d and arg_b=%0d", simd_alu_out[(data_idx + 1)*16 - 1 -: 16], a_arg16[data_idx], b_arg16[data_idx]);
        error_cnt++;
      end
    end
    
    #(CLOCK_PERIOD);
    $display("%tns: Start S_ADD16 operation:", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/16; data_idx++) begin
      s_a_arg16[data_idx] = 0 - data_idx;
      s_b_arg16[data_idx] = -1024 + data_idx;
    end
    simd_opcode = S_ADD16;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results
    $display("%tns: Check the results of the S_ADD16 operation:", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/16; data_idx++) begin
      r_s_res16 = simd_alu_out[(data_idx + 1)*16 - 1 -: 16];
      if (r_s_res16 !== -1024) begin
        $display("\tWrong S_ADD16 test result: got %0d (!= -1024), while arg_a=%0d and arg_b=%0d", r_s_res16, s_a_arg16[data_idx], s_b_arg16[data_idx]);
        error_cnt++;
      end
    end
    
    #(CLOCK_PERIOD*2);
    $display("\n%tns: Start SUB16 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/16; data_idx++) begin
      a_arg16[data_idx] = 255;
      b_arg16[data_idx] = 0;
    end
    simd_opcode = SUB16;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results 
    $display("%tns: Check the results of the SUB16 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/16; data_idx++) begin
      if (simd_alu_out[(data_idx + 1)*16 - 1 -: 16] !== 255) begin
        $display("\tWrong SUB16 test result: got %0d (!= 255), while arg_a=%0d and arg_b=%0d", simd_alu_out[(data_idx + 1)*16 - 1 -: 16], a_arg16[data_idx], b_arg16[data_idx]);
        error_cnt++;
      end
    end
    
    // ************ 32-bits data ************ //
    #(CLOCK_PERIOD);
    $display("%tns: Start ADD32 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/32; data_idx++) begin
      a_arg32[data_idx] = 0 + data_idx;
      b_arg32[data_idx] = 2147483647 - data_idx;
    end
    simd_opcode = ADD32;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results 
    $display("%tns: Check the results of the ADD32 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/32; data_idx++) begin
      if (simd_alu_out[(data_idx + 1)*32 - 1 -: 32] !== 2147483647) begin
        $display("\tWrong ADD32 test result: got %0d (!= 1024), while arg_a=%0d and arg_b=%0d", simd_alu_out[(data_idx + 1)*32 - 1 -: 32], a_arg32[data_idx], b_arg32[data_idx]);
        error_cnt++;
      end
    end
    
    #(CLOCK_PERIOD);
    $display("%tns: Start S_ADD32 operation:", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/32; data_idx++) begin
      s_a_arg32[data_idx] = 0 - data_idx;
      s_b_arg32[data_idx] = -1024 + data_idx;
    end
    simd_opcode = S_ADD32;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results
    $display("%tns: Check the results of the S_ADD32 operation:", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/32; data_idx++) begin
      r_s_res32 = simd_alu_out[(data_idx + 1)*32 - 1 -: 32];
      if (r_s_res32 !== -1024) begin
        $display("\tWrong S_ADD32 test result: got %0d (!= -1024), while arg_a=%0d and arg_b=%0d", r_s_res32, s_a_arg32[data_idx], s_b_arg32[data_idx]);
        error_cnt++;
      end
    end
    
    #(CLOCK_PERIOD);
    $display("%tns: Start SUB32 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/32; data_idx++) begin
      a_arg32[data_idx] = 1;
      b_arg32[data_idx] = 2147483647 - data_idx;
    end
    simd_opcode = SUB32;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results 
    $display("%tns: Check the results of the SUB32 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/32; data_idx++) begin
      if (simd_alu_out[(data_idx + 1)*32 - 1 -: 32] !== -2147483646 + data_idx) begin
        $display("\tWrong SUB32 test result: got %0d (!= %0d), while arg_a=%0d and arg_b=%0d", simd_alu_out[(data_idx + 1)*32 - 1 -: 32], -2147483646 + data_idx, a_arg32[data_idx], b_arg32[data_idx]);
        error_cnt++;
      end
    end
    // ************ 64-bits data ************ //
    #(CLOCK_PERIOD);
    $display("%tns: Start ADD64 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/64; data_idx++) begin
      a_arg64[data_idx] = 0 + data_idx;
      b_arg64[data_idx] = 2147483647 - data_idx;
    end
    simd_opcode = ADD64;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results 
    $display("%tns: Check the results of the ADD64 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/64; data_idx++) begin
      if (simd_alu_out[(data_idx + 1)*64 - 1 -: 64] !== 2147483647) begin
        $display("\tWrong ADD64 test result: got %0d (!= 1024), while arg_a=%0d and arg_b=%0d", simd_alu_out[(data_idx + 1)*64 - 1 -: 64], a_arg64[data_idx], b_arg64[data_idx]);
        error_cnt++;
      end
    end
    
    #(CLOCK_PERIOD);
    $display("%tns: Start S_ADD64 operation:", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/64; data_idx++) begin
      s_a_arg64[data_idx] = 0 - data_idx;
      s_b_arg64[data_idx] = -1024 + data_idx;
    end
    simd_opcode = S_ADD64;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results
    $display("%tns: Check the results of the S_ADD64 operation:", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/64; data_idx++) begin
      r_s_res64 = simd_alu_out[(data_idx + 1)*64 - 1 -: 64];
      if (r_s_res64 !== -1024) begin
        $display("\tWrong S_ADD64 test result: got %0d (!= -1024), while arg_a=%0d and arg_b=%0d", r_s_res64, s_a_arg64[data_idx], s_b_arg64[data_idx]);
        error_cnt++;
      end
    end
    
    #(CLOCK_PERIOD);
    $display("%tns: Start SUB64 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/64; data_idx++) begin
      a_arg64[data_idx] = 0;
      b_arg64[data_idx] = -1;
    end
    simd_opcode = SUB64;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results 
    $display("%tns: Check the results of the SUB64 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/64; data_idx++) begin
      if (simd_alu_out[(data_idx + 1)*64 - 1 -: 64] !== 1) begin
        $display("\tWrong SUB64 test result: got %0d (!= 1), while arg_a=%0d and arg_b=%0d", simd_alu_out[(data_idx + 1)*64 - 1 -: 64], a_arg64[data_idx], b_arg64[data_idx]);
        error_cnt++;
      end
    end
    
    #(CLOCK_PERIOD*10);
    if (error_cnt == 0) begin
      $display("\n\t\t\tTEST PASSED!!!");
    end else begin
      $display("\n\t\t\tTEST FAILED!!!");
    end
    $finish;
  end
  
  
  initial begin
    //to dump all variables in current module scope as well as all instantiated modules
    $dumpfile("dump.vcd"); $dumpvars(0, tb_top);
  end
   
endmodule : tb_top
