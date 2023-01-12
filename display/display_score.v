`timescale 1ns/1ps


module ClockDiv7Seg #(
    parameter N = 10,
    parameter M = 2 ** 9 // M < 2 ** N
)(
    input clk,
    output reg out
);
    reg [N-1:0] counter=0; //this init value is for simulation
    always @(posedge clk) begin
        out <= (counter == M) ? 1'b1 : 1'b0;
        counter <= (counter && counter < M) ? counter + 1 : 1;
    end
endmodule


module DisplayScore (
    input clk, rst,
    input signed [15:0] value,
    output reg [7:0] an,
    output reg [6:0] pin // no dp
);
    wire cd;
    ClockDiv7Seg #(.N(18), .M(2 ** 17)) gen_cd (.clk(clk), .out(cd));

    reg [3:0] used_num;
    reg [6:0] next_pin;
    wire [15:0] abs_value;
    assign abs_value = (value<0) ? -value : value;

    always @(posedge clk)
        if (rst) begin
            an <= 8'b1111_1110;
            pin <= 7'b111_111_1;
        end
        else begin
            an <= cd ? {an[6:0], an[7]} : an;
            pin <= cd ? next_pin : pin;
        end

    always @(*) 
        case ({an[6:0], an[7]}) 
            8'b1111_1110: used_num = (abs_value % 10);
            8'b1111_1101: used_num = (abs_value % 100 - abs_value % 10) / 10;
            8'b1111_1011: used_num = (abs_value % 1000 - abs_value % 100) / 100;
            8'b1111_0111: used_num = (abs_value % 10000 - abs_value % 1000) / 1000;
            8'b1110_1111: used_num = (abs_value % 100000 - abs_value % 10000) / 10000;
            8'b1101_1111: used_num = (abs_value % 1000000 - abs_value % 100000) / 100000;
            8'b1011_1111: used_num = (value[15] == 1) ? 4'd10 : 4'd11; // - or (empty)
            default: used_num = 4'd11; // (empty)
        endcase

    always @(*)
        case (used_num)
            4'h0: next_pin = 7'b000_000_1;
            4'h1: next_pin = 7'b100_111_1;
            4'h2: next_pin = 7'b001_001_0;
            4'h3: next_pin = 7'b000_011_0;
            4'h4: next_pin = 7'b100_110_0;
            4'h5: next_pin = 7'b010_010_0;
            4'h6: next_pin = 7'b010_000_0;
            4'h7: next_pin = 7'b000_111_1;
            4'h8: next_pin = 7'b000_000_0;
            4'h9: next_pin = 7'b000_010_0;
            4'ha: next_pin = 7'b111_111_0;
            default: next_pin = 7'b111_111_1;
        endcase 
endmodule