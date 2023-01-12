module Linear#(
  parameter IN = 16,
  parameter OUT = 16,
  parameter MAX = 16,
  
  //calc how many segment I have
  parameter real_in = MAX<IN ? MAX : IN,
  parameter in_seg = MAX<IN ? IN/MAX : 1,
  parameter seg_addr_len = $clog2(in_seg)
)(
  input clk, rst_n, trigger,
  input [0:IN-1][7:0] x,
  
  //accessing bram
  output reg [seg_addr_len+1:0] now_seg,
  input [0:real_in*OUT*8+7] weight_bram_in,
  input [0:OUT*16+7] bias_bram_in,
  
  output reg finish,
  output reg [0:OUT-1][15:0] out
);
  reg [3:0] state;
  
  wire [7:0] check_addr;
  wire [7:0] check_bias;
  
  reg [0:real_in*8-1] x_seg_temp;
  wire [0:real_in*OUT*8-1] w_read_temp;
  wire [0:OUT*16-1] bias_read_temp;
  wire [0:OUT*16-1] out_seg_temp;
  
  // unpack bram content
  // first byte is header for checking if the row is correct
  assign {check_addr, w_read_temp} = weight_bram_in;
  assign {check_bias, bias_read_temp} = bias_bram_in;
  
  reg signed [15:0] bias [0:OUT-1];
  reg signed [15:0] o_temp [0:OUT-1];
  
  //port mapping
  integer idx;
  always @(*) begin
    for(idx=0; idx<real_in; idx=idx+1) begin
      x_seg_temp[idx*8+:8] = x[now_seg*real_in+idx];
    end
    for(idx=0; idx<OUT; idx=idx+1) begin
      bias[idx] = bias_read_temp[idx*16+:16];
    end
    for(idx=0; idx<OUT; idx=idx+1) begin
      out[idx] = o_temp[idx];
    end
  end
  
  // matmul module
  MatMul #(.N(real_in), .P(OUT)) matmul (x_seg_temp, w_read_temp, out_seg_temp);
  
  
  always @(posedge clk) begin
    if(rst_n == 1'b0) begin
      state <= 1'b0;
      finish <= 1'b0;
      now_seg <= 0;
      for(idx=0; idx<OUT; idx=idx+1) begin
        o_temp[idx] <= 0;
      end
    end else begin
      case(state)
        4'd0: begin //idle after reset
          if(trigger==1'd1) begin
            state <= 4'd1;
            now_seg <= 0;
          end else begin
            state <= state;
          end
        end
        
        4'd1: begin //get bias
          if(check_bias == 8'h01) begin //wait for bram
            state <= 4'd2;
            for(idx=0; idx<OUT; idx=idx+1) begin
              o_temp[idx] <= bias[idx];
            end
          end else begin
            state <= state;
          end
        end
        
        4'd2: begin //accumulate
          if(check_addr == now_seg+1) begin //wait for bram
            for(idx=0; idx<OUT; idx=idx+1) begin
              o_temp[idx] <= o_temp[idx] + $signed(out_seg_temp[idx*16+:16]);
            end
            
            if(now_seg+1 == in_seg) begin
              state <= 4'd3;
              finish <= 1'b1;
            end else begin
              state <= 4'd2;
              now_seg <= now_seg+1;
            end
          end else begin
            state <= state;
          end
        end
        
        4'd3: begin //accumulate done
          state <= 4'd0;
          finish <= 1'b0;
        end
        default: begin
          state <= state;
        end
      endcase
    end
  end
endmodule