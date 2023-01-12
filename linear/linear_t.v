module linear_t;
  parameter N = 256;
  parameter P = 16;
  reg clk, rst_n, trigger, add;
  reg [6:0] row;
  
  parameter cyc = 2;
  always#(cyc/2)clk = !clk;
  
  wire finish;
  
  reg signed [7:0] x [0:N-1];
  reg signed [15:0] out_arr [0:P-1];
  
  reg [0:N*8-1] x_temp;
  wire [0:P*16-1] out;
  Linear #(.IN(N), .OUT(P)) matmul(clk, rst_n, trigger, x_temp, finish, out);
  
  //port mapping
  always @(*) begin
    for(integer idx=0; idx<N; idx=idx+1) begin
      x_temp[idx*8+:8] = x[idx];
    end
    for(integer idx=0; idx<P; idx=idx+1) begin
      out_arr[idx] = out[idx*16+:16];
    end
  end
  
  initial begin
    for(integer idx=0; idx<N/2; idx=idx+1)
      x[idx] = idx;
    for(integer idx=0; idx<N/2; idx=idx+1)
      x[idx+N/2] = idx;
    clk = 1'b0; rst_n = 1'b0; trigger=1'b0; #2
    rst_n = 1'b1; #2
    trigger = 1'b1; #2 trigger=1'b0; #100;
    #2 $finish;
  end
endmodule