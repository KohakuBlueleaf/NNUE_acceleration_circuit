//For basys3, we remove the 7seg display part since basys3 has only 4 digit and we need 7 digit

module TopBasys3(
    input clk, rst, up, down, left, right, enter,
    output [3:0] vgaRed, vgaBlue, vgaGreen,
    output hsync, vsync
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