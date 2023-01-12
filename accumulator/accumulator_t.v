module accumulator_t;
  reg clk, rst_n, trigger, add;
  reg [6:0] row;
  
  parameter cyc = 2;
  always#(cyc/2)clk = !clk;
  
  parameter features = 128;
  
  wire finish;
  wire [0:features*8-1] out;
  Accumulator #(.OUTPUT_FEATURES(features), .ROW_MAX(32)) acc(clk, rst_n, row, add, trigger, finish, out);
  
  reg signed [15:0] out_arr [0:features-1];
  always @(*) begin
    for(integer idx=0; idx<features; idx=idx+1) begin
      out_arr[idx] = out[idx*8+:8];
    end
  end
  
  initial begin
    clk = 1'b0; rst_n = 1'b0; add = 1'b1; row = 7'd0; trigger=1'b0; #2
    rst_n = 1'b1;
    for(integer idx=0; idx<121; idx=idx+1) begin
        row = idx; trigger = 1'b1; #2 trigger=1'b0; #6;
    end
    #2 $finish;
  end
endmodule