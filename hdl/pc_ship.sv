module pc_ship (
  input         frame_clk_i,
  input         reset_i,
  input [12:0]  vol_i,
  output [9:0]  ship_xpos_o, ship_ypos_o, ship_size_o
);

  localparam logic [9:0] InitX  = 304;
  localparam logic [9:0] InitY  = 400;
  localparam logic [9:0] MinX   = 133;
  localparam logic [9:0] MinY   = 0;
  localparam logic [9:0] MaxX   = 506;
  localparam logic [9:0] MaxY   = 479;
  localparam logic [9:0] StepX  = 2;
  localparam logic [9:0] StepY  = 2;

  // OOB = Out Of Bounds
  `define SHIP_OOB_LEFT   ship_xpos_o + ship_xvel < MinX
  `define SHIP_OOB_RIGHT  ship_xpos_o + ship_xvel + ship_size_o > MaxX
  `define JOYSTICK_PUSH_L vol_i > 13'h0800
  `define JOYSTICK_PUSH_R vol_i < 13'h0500

  logic [9:0] ship_xvel, ship_yvel;

  assign ship_size_o = 10'd16;

  always_ff @(posedge reset_i or posedge frame_clk_i) begin : move_pc_ship
    if (reset_i) begin
      ship_xvel <= 0;
      ship_yvel <= 0;
      ship_xpos_o <= InitX;
      ship_ypos_o <= InitY;
    end else begin
      ship_xvel <= 0;
      ship_yvel <= 0;

      if (`JOYSTICK_PUSH_L) begin
        ship_xvel <= -1 * StepX;
      end else if (`JOYSTICK_PUSH_R) begin
        ship_xvel <= StepX;
      end

      if (`SHIP_OOB_LEFT) begin

      // SHIP_OOB_LEFT
      if (ship_xpos_o + ship_xvel < MinX)
        ship_xpos_o <= MinX;
      // SHIP_OOB_RIGHT
    end else if (ship_xpos_o + ship_xvel + ship_size_o > MaxX) begin
      end else if (`SHIP_OOB_RIGHT) begin
        ship_xpos_o <= MaxX - ship_size_o;
      end else begin
        ship_xpos_o <= (ship_xpos_o + ship_xvel);
      end
    end
  end

  `undef SHIP_OOB_LEFT
  `undef SHIP_OOB_RIGHT
  `undef JOYSTICK_PUSH_L
  `undef JOYSTICK_PUSH_R

endmodule
