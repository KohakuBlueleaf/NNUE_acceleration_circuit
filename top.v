`timescale 1ns/1ps


module DBOP #(
    parameter N = 1000
)(
    input clk, in,
    output reg out
);
    // db
    reg [N-1:0] ff;
    always @(posedge clk) 
        ff <= {ff[N-2:0], in};
    wire dbin = (ff == 2**N - 1);
    // op
    reg last;
    always @(posedge clk)
        {out, last} <= {(~last & dbin), dbin};
endmodule


module DebounceOnePulsePeriod#(
    parameter BUF_LEN = 8,
    parameter MIN_PERIOD = 1024
)(
    input clk, rst, in,
    output reg out
);
    parameter COUNT_BITS = $clog2(MIN_PERIOD);
    reg [BUF_LEN-1:0] buffer;
    reg [COUNT_BITS:0] counter;
    reg prev;
    reg period_trigger;
    
    always @(posedge clk) begin
        if(rst) begin
            buffer <= 0;
            counter <= 0;
            prev <= 0;
            period_trigger <= 0;
        end else begin
            if (buffer == 2**BUF_LEN-1 & prev == 1'b0) begin
                out <= 1;
                prev <= 1;
            end else if (buffer == 0 & period_trigger) begin
                out <= 0;
                prev <= 0;
                period_trigger <= 0;
            end else begin
                out <= 0;
            end
            
            if (prev & counter<=MIN_PERIOD) begin
                counter <= counter + 1;
                period_trigger <= 1;
            end else begin
                counter <= 0;
            end
            
            buffer[0] <= in;
            buffer[BUF_LEN-1:1] <= buffer[BUF_LEN-2:0];
        end
    end
endmodule


module ClockDiv #(
    parameter N = 2
)(
    input clk,
    output clk_d
);
    reg [N-1:0] counter=0; //this init value is for simulation
    always @(posedge clk) begin
        counter <= (counter) ? counter + 1 : 1;
    end
    assign clk_d = counter[N-1];
endmodule


module Input (
    input clk, rst, up, down, left, right,
    output [7:0] addr0, addr1
);
    reg [7:0] addr0, addr1, next_addr;

    // Input configuration
    always @(posedge clk) begin
        if (rst) begin
            addr0 <= 8'd0; 
            addr1 <= 8'd121;
        end else begin
            addr0 <= next_addr;
            addr1 <= addr0 + 8'd121;
        end
    end

    always @(*) begin
        case({up, down, left, right})
            4'b1000: begin
                next_addr = (addr0 > 10) ? addr0 - 11 : addr0;
            end
            4'b0100: begin
                next_addr = (addr0 < 110) ? addr0 + 11 : addr0; 
            end
            4'b0010: begin
                next_addr = (addr0 % 11 > 0) ? addr0 - 1 : addr0; 
            end
            4'b0001: begin
                next_addr = (addr0 % 11 < 10) ? addr0 + 1 : addr0; 
            end
            default: begin
                next_addr = addr0;
            end
        endcase
    end
endmodule


module Top(
    input clk, rst, up, down, left, right, enter,
    output [3:0] vgaRed, vgaBlue, vgaGreen,
    output hsync, vsync,
    output [7:0] an,
    output [6:0] seg7
);
    // Clk divider
    wire clk_25MHZ;
    ClockDiv #(.N(2)) CD0(.clk(clk), .clk_d(clk_25MHZ));

    // debounce onepulse signals
    wire dbop_up, dbop_down, dbop_left, dbop_right, dbop_enter, dbop_rst;
    DBOP #(.N(10)) dbop0 (.clk(clk_25MHZ), .in(rst), .out(dbop_rst));
    DebounceOnePulsePeriod #(.BUF_LEN(16), .MIN_PERIOD(4096)) 
        dbop1 (.clk(clk_25MHZ), .rst(dbop_rst), .in(enter), .out(dbop_enter)),
        dbop2 (.clk(clk_25MHZ), .rst(dbop_rst), .in(up),    .out(dbop_up)),
        dbop3 (.clk(clk_25MHZ), .rst(dbop_rst), .in(down),  .out(dbop_down)),
        dbop4 (.clk(clk_25MHZ), .rst(dbop_rst), .in(left),  .out(dbop_left)),
        dbop5 (.clk(clk_25MHZ), .rst(dbop_rst), .in(right), .out(dbop_right));

    // Process inputs
    wire player;
    wire [7:0] addr0, addr1;
    Input INPUTS (
        .clk(clk_25MHZ),
        .rst(dbop_rst),
        .up(dbop_up),
        .down(dbop_down),
        .left(dbop_left),
        .right(dbop_right),
        .addr0(addr0),
        .addr1(addr1)
    );

    // Chessboard management
    wire [0:241] board; // Concate two 121 chessboard
    wire [0:120] win_board;
    wire [1:0] game_status;
    wire [15:0] state_score;
    State chess_board (
        .clk(clk_25MHZ),
        .rst(dbop_rst),
        .write(dbop_enter),
        .addr(addr0),
        .player(player),
        .game_status(game_status),
        .chessboard(board),
        .win_board(win_board),
        .state_score(state_score)
    );

    DisplayScore display_score(clk, dbop_rst, state_score, an, seg7);

    // Display with vga
    DisplayVGA show (
        .clk(clk_25MHZ),
        .rst(dbop_rst),
        .player(player),
        .board(board),
        .win_board(win_board),
        .game_status(game_status),
        .score(state_score),
        .addr0(addr0),
        .addr1(addr1),
        .vgaRed(vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue(vgaBlue),
        .hsync(hsync),
        .vsync(vsync)
    );
endmodule