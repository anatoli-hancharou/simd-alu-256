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
  
  reg [SIMD_DATA_WIDTH - 1 : 0] simd_alu_arg_a;
  reg [SIMD_DATA_WIDTH - 1 : 0] simd_alu_arg_b;
  
  reg [SIMD_OPC_WIDTH - 1 : 0] simd_opcode;
  
  wire [SIMD_DATA_WIDTH - 1 : 0] simd_alu_out;
  
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
    .out(simd_alu_out)
  );
  
  always @(*) begin
    case (simd_opcode)
      ADD8:
        for (data_chunk_idx = 0; data_chunk_idx < SIMD_DATA_WIDTH/8; data_chunk_idx++) begin
          simd_alu_arg_a[(data_chunk_idx + 1)*8 - 1 -: 8] = a_arg8[data_chunk_idx];
          simd_alu_arg_b[(data_chunk_idx + 1)*8 - 1 -: 8] = b_arg8[data_chunk_idx];
      end
      S_ADD8:
        for (data_chunk_idx = 0; data_chunk_idx < SIMD_DATA_WIDTH/8; data_chunk_idx++) begin
          simd_alu_arg_a[(data_chunk_idx + 1)*8 - 1 -: 8] = s_a_arg8[data_chunk_idx];
          simd_alu_arg_b[(data_chunk_idx + 1)*8 - 1 -: 8] = s_b_arg8[data_chunk_idx];
      end
      ADD16:
        for (data_chunk_idx = 0; data_chunk_idx < SIMD_DATA_WIDTH/16; data_chunk_idx++) begin
          simd_alu_arg_a[(data_chunk_idx + 1)*16 - 1 -: 16] = a_arg16[data_chunk_idx];
          simd_alu_arg_b[(data_chunk_idx + 1)*16 - 1 -: 16] = b_arg16[data_chunk_idx];
      end
      S_ADD16:
        for (data_chunk_idx = 0; data_chunk_idx < SIMD_DATA_WIDTH/16; data_chunk_idx++) begin
          simd_alu_arg_a[(data_chunk_idx + 1)*16 - 1 -: 16] = s_a_arg16[data_chunk_idx];
          simd_alu_arg_b[(data_chunk_idx + 1)*16 - 1 -: 16] = s_b_arg16[data_chunk_idx];
      end
      
      default : begin
        simd_alu_arg_a = 0;
        simd_alu_arg_b = 0;
      end 
    endcase
  end
  
  // TEST sequence
  initial begin
    //*** 8-bits data ***//
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
    
    // ************ DATA OVERFLOW ************* //
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
      if (r_s_res8 !== -2) begin
        $display("\tWrong S_ADD8 test result: got %0d (!= -32), while arg_a=%0d and arg_b=%0d", r_s_res8, s_a_arg8[data_idx], s_b_arg8[data_idx]);
        error_cnt++;
      end
    end
    
    //*** 16-bits data***//
    #(CLOCK_PERIOD);
    $display("\n%tns: Start ADD16 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/16; data_idx++) begin
      a_arg16[data_idx] = 0 + data_idx;
      b_arg16[data_idx] = 1024 - data_idx;
    end
    simd_opcode = ADD16;
    
    #(CLOCK_PERIOD);//delay in 1 cycle to get ALU results 
    $display("%tns: Check the results of the ADD8 operation", $time);
    for (data_idx = 0; data_idx < SIMD_DATA_WIDTH/16; data_idx++) begin
      if (simd_alu_out[(data_idx + 1)*16 - 1 -: 16] !== 1024) begin
        $display("\tWrong ADD8 test result: got %0d (!= 1024), while arg_a=%0d and arg_b=%0d", simd_alu_out[(data_idx + 1)*16 - 1 -: 16], a_arg16[data_idx], b_arg16[data_idx]);
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
