/*
* Bullet finite state machine module
* Used to determine when to display a bullet (user presses button) and when to
* hide + rearm bullet for user to fire again (bullet hits enemy or exits
* screen)
*/
module bullet_fsm (
  input           reset_i,
  input           clk_i,
  input   [12:0]  rdata3_i,
  input           bhit_i [2],
  output          bdisplay_o [2]
);

  typedef enum {
    StShowNone, StShowB1, StShowB1Released, StShowB2, StShowBoth
  } bullet_state_e;

  logic pressed;
  bullet_state_e state_d, state_q;

  always_ff @(posedge clk_i or posedge reset_i) begin
    state_q <= reset_i ? StShowNone : state_d;
  end

  always_comb begin : next_state_logic
    pressed = (rdata3_i < 13'h0200) ? 1 : 0;
    state_d = state_q;

    unique case (state_q)
      StShowNone: begin
        if (pressed)
          state_d = StShowB1;
      end

      StShowB1: begin
        if (~pressed)
          state_d = StShowB1Released;
        else if (bhit_i[0])
          state_d = StShowNone;
      end

      StShowB1Released: begin
        if (pressed)
          state_d = StShowBoth;
        else if (bhit_i[0])
          state_d = StShowNone;
      end

      StShowB2: begin
        if (pressed)
          state_d = StShowBoth;
        else if (bhit_i[1])
          state_d = StShowNone;
      end

      StShowBoth: begin
        if (bhit_i[0])
          state_d = StShowB2;
        else if (bhit_i[1])
          state_d = StShowB1;
      end

      default: ;
    endcase
  end

  always_comb begin : output_logic
    unique case (state_q)
      StShowNone:       bdisplay_o = '{0, 0};
      StShowB1:         bdisplay_o = '{1, 0};
      StShowB1Released: bdisplay_o = '{1, 0};
      StShowB2:         bdisplay_o = '{0, 1};
      StShowBoth:       bdisplay_o = '{1, 1};
    endcase
  end
endmodule
