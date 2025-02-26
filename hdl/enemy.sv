/*
 * enemy contains registers for each enemy's current position and velocity,
 * updated on every reset_i or frame_clk_i event.
 */
module enemy #(
  parameter int EnemyCount = 40
) (
  input                           reset_i,
  input                           frame_clk_i,
  input   [9:0]                   xvel_i, yvel_i,
  output  [EnemyCount-1:0][9:0]  xpos_o, ypos_o
);

  logic [9:0] xvel, yvel;
  logic [EnemyCount - 1:0][9:0] xpos, ypos;

  localparam logic [9:0] XCenter = 180;
  localparam logic [9:0] YCenter = 60;

  always_ff @ (posedge reset_i or posedge frame_clk_i) begin
    if (reset_i) begin
      for (int i = 0; i < EnemyCount; i++) begin
        xpos[i] <= XCenter + 32 * (i % 10);
        ypos[i] <= YCenter + 32 * (i / 10);
      end
    xvel <= 0;
    yvel <= 0;
    end else begin
      xvel <= xvel_i;
      yvel <= yvel_i;

      for (int i = 0; i < EnemyCount; i++) begin
        xpos[i] <= xpos[i] + xvel;
        ypos[i] <= ypos[i] + yvel;
      end
    end
  end

  assign xpos_o = xpos;
  assign ypos_o = ypos;

endmodule
