`timescale 1ps/1ps

module Board(
  //control
  input clk, rst,
  input write,
  
  //input data
  input [7:0] addr,
  
  //output data
  output reg win,
  output reg [0:10][0:10]output_board,
  output reg [0:120]win_board
);
  reg [0:10]board[0:10];
  reg [0:120] win_board0, win_board1, win_board2, win_board3; // Four temp boards for recording win status
	wire [3:0] x, y;
	assign x = addr / 11;
	assign y = addr % 11;
    integer idx, idy;
  
  always @(*) begin
    for(idx=0; idx<11;idx=idx+1) begin
      output_board[idx] = board[idx];
    end
    win = 1'b0;
    win_board0 = 121'b0;
    win_board1 = 121'b0;
    win_board2 = 121'b0;
    win_board3 = 121'b0;
    for(idx=0; idx<11;idx=idx+1) begin
      for(idy=0; idy<7; idy=idy+1) begin
        win                      = win                      | (board[idx][idy]&board[idx][idy+1]&board[idx][idy+2]&board[idx][idy+3]&board[idx][idy+4]);
        win_board0[idx*11+idy]   = win_board0[idx*11+idy]   | (board[idx][idy]&board[idx][idy+1]&board[idx][idy+2]&board[idx][idy+3]&board[idx][idy+4]);
        win_board0[idx*11+idy+1] = win_board0[idx*11+idy+1] | (board[idx][idy]&board[idx][idy+1]&board[idx][idy+2]&board[idx][idy+3]&board[idx][idy+4]);
        win_board0[idx*11+idy+2] = win_board0[idx*11+idy+2] | (board[idx][idy]&board[idx][idy+1]&board[idx][idy+2]&board[idx][idy+3]&board[idx][idy+4]);
        win_board0[idx*11+idy+3] = win_board0[idx*11+idy+3] | (board[idx][idy]&board[idx][idy+1]&board[idx][idy+2]&board[idx][idy+3]&board[idx][idy+4]);
        win_board0[idx*11+idy+4] = win_board0[idx*11+idy+4] | (board[idx][idy]&board[idx][idy+1]&board[idx][idy+2]&board[idx][idy+3]&board[idx][idy+4]);
      end
    end
    for(idx=0; idx<7;idx=idx+1) begin
      for(idy=0; idy<11; idy=idy+1) begin
        win                       = win                       | (board[idx][idy]&board[idx+1][idy]&board[idx+2][idy]&board[idx+3][idy]&board[idx+4][idy]);
        win_board1[idx*11+idy]    = win_board1[idx*11+idy]    | (board[idx][idy]&board[idx+1][idy]&board[idx+2][idy]&board[idx+3][idy]&board[idx+4][idy]);
        win_board1[idx*11+idy+11] = win_board1[idx*11+idy+11] | (board[idx][idy]&board[idx+1][idy]&board[idx+2][idy]&board[idx+3][idy]&board[idx+4][idy]);
        win_board1[idx*11+idy+22] = win_board1[idx*11+idy+22] | (board[idx][idy]&board[idx+1][idy]&board[idx+2][idy]&board[idx+3][idy]&board[idx+4][idy]);
        win_board1[idx*11+idy+33] = win_board1[idx*11+idy+33] | (board[idx][idy]&board[idx+1][idy]&board[idx+2][idy]&board[idx+3][idy]&board[idx+4][idy]);
        win_board1[idx*11+idy+44] = win_board1[idx*11+idy+44] | (board[idx][idy]&board[idx+1][idy]&board[idx+2][idy]&board[idx+3][idy]&board[idx+4][idy]);
      end
    end
    for(idx=0; idx<7;idx=idx+1) begin
      for(idy=0; idy<7; idy=idy+1) begin
        win                       = win                       | (board[idx][idy]&board[idx+1][idy+1]&board[idx+2][idy+2]&board[idx+3][idy+3]&board[idx+4][idy+4]);
        win_board2[idx*11+idy]    = win_board2[idx*11+idy]    | (board[idx][idy]&board[idx+1][idy+1]&board[idx+2][idy+2]&board[idx+3][idy+3]&board[idx+4][idy+4]);
        win_board2[idx*11+idy+12] = win_board2[idx*11+idy+12] | (board[idx][idy]&board[idx+1][idy+1]&board[idx+2][idy+2]&board[idx+3][idy+3]&board[idx+4][idy+4]);
        win_board2[idx*11+idy+24] = win_board2[idx*11+idy+24] | (board[idx][idy]&board[idx+1][idy+1]&board[idx+2][idy+2]&board[idx+3][idy+3]&board[idx+4][idy+4]);
        win_board2[idx*11+idy+36] = win_board2[idx*11+idy+36] | (board[idx][idy]&board[idx+1][idy+1]&board[idx+2][idy+2]&board[idx+3][idy+3]&board[idx+4][idy+4]);
        win_board2[idx*11+idy+48] = win_board2[idx*11+idy+48] | (board[idx][idy]&board[idx+1][idy+1]&board[idx+2][idy+2]&board[idx+3][idy+3]&board[idx+4][idy+4]);
      end
    end
    for(idx=0; idx<7;idx=idx+1) begin
      for(idy=4; idy<11; idy=idy+1) begin
        win                       = win                       | (board[idx][idy]&board[idx+1][idy-1]&board[idx+2][idy-2]&board[idx+3][idy-3]&board[idx+4][idy-4]);
        win_board3[idx*11+idy]    = win_board3[idx*11+idy]    | (board[idx][idy]&board[idx+1][idy-1]&board[idx+2][idy-2]&board[idx+3][idy-3]&board[idx+4][idy-4]);
        win_board3[idx*11+idy+10] = win_board3[idx*11+idy+10] | (board[idx][idy]&board[idx+1][idy-1]&board[idx+2][idy-2]&board[idx+3][idy-3]&board[idx+4][idy-4]);
        win_board3[idx*11+idy+20] = win_board3[idx*11+idy+20] | (board[idx][idy]&board[idx+1][idy-1]&board[idx+2][idy-2]&board[idx+3][idy-3]&board[idx+4][idy-4]);
        win_board3[idx*11+idy+30] = win_board3[idx*11+idy+30] | (board[idx][idy]&board[idx+1][idy-1]&board[idx+2][idy-2]&board[idx+3][idy-3]&board[idx+4][idy-4]);
        win_board3[idx*11+idy+40] = win_board3[idx*11+idy+40] | (board[idx][idy]&board[idx+1][idy-1]&board[idx+2][idy-2]&board[idx+3][idy-3]&board[idx+4][idy-4]);
      end
    end
  end
  
  always @(posedge clk) begin
    if(rst==1'b1) begin
      for(idx=0; idx<11;idx=idx+1) begin
        for(idy=0; idy<11; idy=idy+1) begin
          board[idx][idy] <= 1'b0;
        end 
      end
      win_board <= 121'b0;
    end else begin
      win_board <= win_board0 | win_board1 | win_board2 | win_board3;
      if(write) begin
        board[x][y] <= 1;
      end else begin
        board[x][y] <= board[x][y];
      end
    end
  end
endmodule


module State(
  // Control signals
  input clk, rst,
  input write,
  
  //input data
  input [7:0] addr,

  //output data
  output reg player, // decide which player is playing
  output [1:0] game_status, // 0: game processing, 1: player0 win, 2: player1 win, 3: tie
  output [0:241] chessboard,
  output [0:120] win_board,
  output [15:0] state_score
);
  wire win0, win1, draw, writable;
  wire [0:120] board0, board1;
  wire [0:120] win_board_0, win_board_1; // Board for win chess
  
  // Chessboard
  Board player0(clk, rst, writable & ~player, addr, win0, board0, win_board_0);
  Board player1(clk, rst, writable & player, addr, win1, board1, win_board_1);
  
  // Game status assign
  assign draw = (~(board0^board1))==0 & ~win1 & ~win0;
  assign game_status = draw ? 2'b11 : {win1, win0};
  assign writable = ~board0[addr] & ~board1[addr] & write & (game_status == 2'b0);
  
  wire nnue_fin;
  NNUE nnue_score(clk, ~rst, writable, player, addr, 1'd1, nnue_fin, state_score);
  
  // player selector
  wire next_player = writable ? write ^ player : player;
  
  always @(posedge clk) begin
    if(rst==1'b1) begin
      player <= 1'b0; // initial player = 0
    end else begin
      player <= next_player;
    end
  end

  // assign chessboard
  assign chessboard = {board0, board1};
  assign win_board = win_board_0 | win_board_1;
endmodule