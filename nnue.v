module ScaledClippedRelu#(
  parameter LEN=16
)(
  input [0:LEN*16-1] x,
  output reg [0:LEN*8-1] out
);
  integer idx;
  always @(*) begin
    for(idx=0; idx<LEN; idx = idx+1) begin
      if(x[idx*16]==1'd1) //check x<0
        out[idx*8+:8] = 8'd0;
      else if(x[idx*16+:10]>127)
        out[idx*8+:8] = 8'd127;
      else
        out[idx*8+:8] = x[idx*16+2+:8];
    end
  end
endmodule


module NNUE(
  input clk, rst_n, trigger, player,
  
  // info for add/minus what row
  input [6:0] row, //0~120 refer to [0:11][0:11] gomoku board
  input add,
  
  output finish,
  output [15:0] out
);
  //Layer1 - accumulator
  wire fin1;
  wire [0:128*8-1] out1_1, out1_2;
  wire [0:256*8-1] out1 = player ? {out1_2, out1_1} : {out1_1, out1_2};
  Accumulator #(.OUTPUT_FEATURES(128)) 
    acc(clk, rst_n, row, add, player, trigger, fin1, out1_1, out1_2);
  
  
  //Layer2 - 256 -> 16
  wire fin2;
  wire [7:0] now_seg2;
  wire [0:16*16*8+7] w2;
  wire [0:16*16+7] b2;
  wire [0:16*16-1] out2;
  wire [0:16*8-1] out2_clipped;
  
  blk_mem_gen_l2_w weight_bram_l2(.clka(clk), .wea(0), .addra(now_seg2), .dina(0), .douta(w2)); 
  blk_mem_gen_l2_b bias_bram_l2(.clka(clk), .wea(0), .addra(0), .dina(0), .douta(b2)); 
  Linear #(.IN(256), .OUT(16)) layer2(clk, rst_n, fin1, out1, now_seg2, w2, b2, fin2, out2);
  ScaledClippedRelu #(.LEN(16)) ClipRelu2(out2, out2_clipped);
  
  
  //Layer3 - 16 -> 16
  wire fin3;
  wire [7:0] now_seg3;
  wire [0:16*16*8+7] w3;
  wire [0:16*16+7] b3;
  wire [0:16*16-1] out3;
  wire [0:16*8-1] out3_clipped;
  
  blk_mem_gen_l3_w weight_bram_l3(.clka(clk), .wea(0), .addra(now_seg3), .dina(0), .douta(w3)); 
  blk_mem_gen_l3_b bias_bram_l3(.clka(clk), .wea(0), .addra(0), .dina(0), .douta(b3)); 
  Linear #(.IN(16), .OUT(16)) layer3(clk, rst_n, fin2, out2_clipped, now_seg3, w3, b3, fin3, out3);
  ScaledClippedRelu #(.LEN(16)) ClipRelu3(out3, out3_clipped);
  
  
  //Layer4 - 16 -> 1
  wire [7:0] now_seg4;
  wire [0:16*8+7] w4;
  wire [0:16+7] b4;
  
  blk_mem_gen_l4_w weight_bram_l4(.clka(clk), .wea(0), .addra(now_seg4), .dina(0), .douta(w4)); 
  blk_mem_gen_l4_b bias_bram_l4(.clka(clk), .wea(0), .addra(0), .dina(0), .douta(b4)); 
  Linear #(.IN(16), .OUT(1)) layer4(clk, rst_n, fin3, out3_clipped, now_seg4, w4, b4, finish, out);
endmodule