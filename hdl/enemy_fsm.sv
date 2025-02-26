/*
 * enemy_fsm loops enemy sprite velocity (left, down, right, up) and sprite
 * ROM addresses (wings extended, contracted).
 */
module enemy_fsm (
  input               reset_i,
  input               clk_i,
  input               pause_i,
  output logic [9:0]  xvel_o, yvel_o,
  output logic [9:0]  addr_o
);

  typedef enum {
    StInit, StUp, StLeft, StDown, StRight
  } enemy_state_e;

  enemy_state_e state_d, state_q;
  logic [4:0] count_d, count_q;

  always_ff @(posedge clk_i) begin
    state_q <= reset_i ? StInit : state_d;
    count_q <= count_d;
  end

  always_comb begin : next_state_logic
    count_d = (count_q + 1) % 11;
    state_d = state_q;

    unique case (state_q)
      StInit:   state_d = StUp;
      StUp:     if (count_q == 10) state_d = StLeft;
      StLeft:   if (count_q == 10) state_d = StDown;
      StDown:   if (count_q == 10) state_d = StRight;
      StRight:  if (count_q == 10) state_d = StUp;
    endcase
  end

  always_comb begin : output_logic
    xvel_o = 0;
    yvel_o = 0;
    addr_o = 0;

    unique case (state_q)
      StInit:   ;

      StUp: begin
        yvel_o = -1;
        addr_o = 10'h1F;
      end

      StLeft: begin
        xvel_o = -1;
        addr_o = 10'h1E;
      end

      StDown: begin
        yvel_o = 1;
        addr_o = 10'h1F;
      end

      StRight: begin
        xvel_o = 1;
        addr_o = 10'h1E;
      end
    endcase
  end
endmodule
