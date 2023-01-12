`timescale 1ps/1ps


module Board_t;
  reg clk, rst_n, write, new_d;
  reg [3:0] x, y;
  
  wire [0:10][0:10]board;
  wire win;
  
  Board board_module(clk, rst_n, write, new_d, x, y, win, board);
  
  parameter cyc = 2;
  always#(cyc/2)clk = !clk;
  
  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    new_d = 1'b0;
    x = 1'b0; y = 1'b0;
    #2 rst_n = 1'b1;
    #2 write = 1'b1; x = 4'd0; y = 4'd0; new_d = 1'b1;
    #2 write = 1'b1; x = 4'd0; y = 4'd1; new_d = 1'b1;
    #2 write = 1'b1; x = 4'd0; y = 4'd2; new_d = 1'b1;
    #2 write = 1'b1; x = 4'd0; y = 4'd3; new_d = 1'b1;
    #2 write = 1'b1; x = 4'd0; y = 4'd4; new_d = 1'b1;
    #2 write = 1'b1; x = 4'd0; y = 4'd4; new_d = 1'b0;
    #2 write = 1'b1; x = 4'd1; y = 4'd0; new_d = 1'b1;
    #2 write = 1'b1; x = 4'd2; y = 4'd1; new_d = 1'b1;
    #2 write = 1'b1; x = 4'd3; y = 4'd2; new_d = 1'b1;
    #2 write = 1'b1; x = 4'd4; y = 4'd3; new_d = 1'b1;
    #2 write = 1'b1; x = 4'd5; y = 4'd4; new_d = 1'b1;
    #2 write = 1'b1; x = 4'd6; y = 4'd5; new_d = 1'b1;
    #2 $finish;
  end
  
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, Board_t);
  end
endmodule