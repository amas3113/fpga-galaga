/*
 * ADC counter module
 * DE-10 Lite Shield driver - cycles channel_o through 1-5, incrementing every
 * 10 clock cycles. This achieves cycling over multiple user inputs in serial
 * order (serial interface)
 */
module adc_ctr (
  input               reset_i,
  input               clk_i,
  output reg [4:0]    channel_o
);

  logic [4:0] count, channel_next;

  always_comb begin
    channel_next = (channel_o % 5) + 1;
  end

  always_ff @(posedge reset_i or posedge clk_i) begin
    if (reset_i) begin
      count       <= 0;
      channel_o   <= 1;
    end else begin
      count <= count + 1;
      if (count == 10) begin
        count     <= 0;
        channel_o <= channel_next;
      end
    end
  end
endmodule
