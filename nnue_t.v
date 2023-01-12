module nnue_t;
  reg clk, rst_n, trigger, add, player;
  reg [6:0] row;
  
  parameter cyc = 2;
  always#(cyc/2)clk = !clk;
  
  wire finish;
  wire signed [15:0] out;
  NNUE nnue(clk, rst_n, trigger, player, row, add, finish, out);
  
  initial begin
    clk = 1'b0; rst_n = 1'b0; player=1'd1; add = 1'b1; row = 7'd0; trigger=1'b0; #2
    rst_n = 1'b1; #10
    row = 7'd0; trigger = 1'b1; #2 trigger=1'b0; #150;
    #2 $finish;
  end
endmodule