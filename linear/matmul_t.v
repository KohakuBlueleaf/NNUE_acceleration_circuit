module matmul_t;
  parameter N = 2;
  parameter P = 3;
  
  reg signed [7:0] x [0:N-1];
  reg signed [7:0] w [0:N-1][0:P-1];
  reg signed [15:0] out_arr [0:P-1];
  
  reg [0:N*8-1] x_temp;
  reg [0:(N*P)*8-1] w_temp;
  wire [0:P*16-1] out;
  MatMul #(.N(N), .P(P)) matmul(x_temp, w_temp, out);
  
  //port mapping
  always @(*) begin
    for(integer idx=0; idx<N; idx=idx+1)
      x_temp[idx*8+:8] = x[idx];
    for(integer idx=0; idx<N; idx=idx+1)
      for(integer idy=0; idy<P; idy=idy+1)
        w_temp[(idx*P+idy)*8+:8] = w[idx][idy];
    for(integer idx=0; idx<P; idx=idx+1) begin
      out_arr[idx] = out[idx*16+:16];
    end
  end
  
  initial begin
    for(integer idx=0; idx<N; idx=idx+1)
      x[idx] = $random;
    for(integer idx=0; idx<N; idx=idx+1)
      for(integer idy=0; idy<P; idy=idy+1)
        w[idx][idy] = $random;
    #2 $finish;
  end
endmodule