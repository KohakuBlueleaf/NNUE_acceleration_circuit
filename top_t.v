module top_t;
    reg clk, rst, up, down, left, right, enter;
    wire hsync, vsync;
    wire [3:0] vr, vb, vg;
    wire [15:0] LED;
    wire [7:0] an;
    wire [6:0] seg7;
    Top top(clk, rst, up, down, left, right, enter, vr, vb, vg, hsync, vsync, LED, an, seg7);
    
    parameter cyc = 2;
    always#(cyc/2)clk = !clk;
    
    initial begin
        up=0;down=0;left=0;right=0;
        clk = 1'b0; rst = 1'b0; enter = 1'b0; #10;
        rst = 1'd1; #100 rst = 1'b0;
        #50; enter = 1'b1; #100 enter=1'b0; #300;
        #2 $finish;
    end
endmodule