
//This module ignore the bias, should add on the output
module Accumulator#(
  parameter INPUT_FEATURES = 121,
  parameter OUTPUT_FEATURES = 128
)(
  input clk,
  input rst_n,
  
  // info for add/minus what row
  input [6:0] row,
  input add, player,
  
  input trigger,
  
  //output data
  output reg finish,
  output reg [0:OUTPUT_FEATURES-1][7:0] out0,
  output reg [0:OUTPUT_FEATURES-1][7:0] out1
);
  reg [3:0] state;
  reg [6:0] row_buf;//row 0 is bias
  
  wire [7:0] check_addr;
  wire [0:OUTPUT_FEATURES*16-1] w_read_temp;
  reg signed [15:0] weight [0:OUTPUT_FEATURES-1];
  
  reg signed [7:0] o_temp0 [0:OUTPUT_FEATURES-1];
  reg signed [7:0] o_temp1 [0:OUTPUT_FEATURES-1];
  
  blk_mem_gen_accumulator_w weight_bram(
    .clka(clk),
    .wea(0),
    .addra(row_buf),
    .dina(0),
    .douta({check_addr, w_read_temp})
  ); 
  
  integer idx;
  //port mapping
  always @(*) begin
    for(idx=0; idx<OUTPUT_FEATURES; idx=idx+1) begin
      weight[idx] = w_read_temp[idx*16+:16];
    end
    
    //calc the clipped relu
    for(idx=0; idx<OUTPUT_FEATURES; idx=idx+1) begin
      if(o_temp0[idx] < 0)
        out0[idx] = 8'd0;
      else if(o_temp0[idx] > 127)
        out0[idx] = 8'd127;
      else
        out0[idx] = o_temp0[idx];
    end
    for(idx=0; idx<OUTPUT_FEATURES; idx=idx+1) begin
      if(o_temp1[idx] < 0)
        out1[idx] = 8'd0;
      else if(o_temp1[idx] > 127)
        out1[idx] = 8'd127;
      else
        out1[idx] = o_temp1[idx];
    end
  end
  
  always @(posedge clk) begin
    if(rst_n==1'b0) begin
      state <= 4'b0;
      finish <= 0;
      for(idx=0; idx<OUTPUT_FEATURES; idx=idx+1) begin
        o_temp0[idx] = 0;
        o_temp1[idx] = 0;
      end
      row_buf <= 0;
    end else begin
      case(state)
        4'd0: begin //get bias at first
          if(check_addr == row_buf+1) begin //wait for bram
            state <= 4'd1;
            for(idx=0; idx<OUTPUT_FEATURES; idx=idx+1) begin
              o_temp0[idx] <= weight[idx];
            end
            for(idx=0; idx<OUTPUT_FEATURES; idx=idx+1) begin
              o_temp1[idx] <= weight[idx];
            end
          end else begin
            state <= state;
          end
        end
        
        4'd1: begin //idle
          if(trigger==1'd1) begin
            state <= 4'd2;
            row_buf <= row+1; // row0 is bias
          end else begin
            state <= state;
          end
        end
        
        4'd2: begin //accumulate
          if(check_addr == row_buf+1) begin //wait for bram
            state <= 4'd3;
            finish <= 1'b1;
            
            //add or minus the weight to the output
            if(add)begin
              for(idx=0; idx<OUTPUT_FEATURES; idx=idx+1) begin
                if(player)
                  o_temp0[idx] <= o_temp0[idx] + weight[idx];
                else
                  o_temp1[idx] <= o_temp1[idx] + weight[idx];
              end
            end else begin
              for(idx=0; idx<OUTPUT_FEATURES; idx=idx+1) begin
                if(player)
                  o_temp0[idx] <= o_temp0[idx] - weight[idx];
                else
                  o_temp1[idx] <= o_temp1[idx] - weight[idx];
              end
            end
          end else begin
            state <= state;
          end
        end
        
        4'd3: begin //accumulate done
          state <= 4'd1;
          finish <= 1'b0;
        end
        
        default: begin
          state <= state;
        end
      endcase
    end
  end
endmodule