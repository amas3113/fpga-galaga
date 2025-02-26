module seg7_driver (
  input       [3:0] dig_i,
  output reg  [6:0] seg_o
);

always @(dig_i) begin
    unique case (dig_i)
    4'h0: seg_o = 7'b1000000;
    4'h1: seg_o = 7'b1111001;   // +---0---+
    4'h2: seg_o = 7'b0100100;   // |       |
    4'h3: seg_o = 7'b0110000;   // 5       1
    4'h4: seg_o = 7'b0011001;   // |       |
    4'h5: seg_o = 7'b0010010;   // +---6---+
    4'h6: seg_o = 7'b0000010;   // |       |
    4'h7: seg_o = 7'b1111000;   // 4       2
    4'h8: seg_o = 7'b0000000;   // |       |
    4'h9: seg_o = 7'b0011000;   // +---3---+
    4'ha: seg_o = 7'b0001000;
    4'hb: seg_o = 7'b0000011;
    4'hc: seg_o = 7'b1000110;
    4'hd: seg_o = 7'b0100001;
    4'he: seg_o = 7'b0000110;
    4'hf: seg_o = 7'b0001110;
    endcase
end

endmodule
