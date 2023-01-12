module MatMul#(
  parameter N=16,
  parameter P=16
)(
  input [0:N*8-1] x,
  input [0:N*P*8-1] w,
  
  output reg [0:P-1][15:0] out
);
  integer idx, idy;
  
  reg signed [7:0] x_temp [0:N-1];
  reg signed [7:0] w_temp [0:N-1][0:P-1];
  reg signed [15:0] o_temp [0:P-1];
  
  //port mapping
  always @(*) begin
    for(idx=0; idx<N; idx=idx+1) begin
      x_temp[idx] = x[idx*8+:8];
      for(idy=0; idy<P; idy=idy+1) begin
        w_temp[idx][idy] = w[(idx*P+idy)*8+:8];
      end
    end
    for(idy=0; idy<P; idy=idy+1) begin
      out[idy] = o_temp[idy];
    end
  end
  
  always @(*) begin
    for(idy=0; idy<P; idy=idy+1) begin
      o_temp[idy] = x_temp[0] * w_temp[0][idy];
      for(idx=1; idx<N; idx=idx+1) begin
        o_temp[idy] = o_temp[idy] + x_temp[idx] * w_temp[idx][idy];
      end
    end
  end
endmodule