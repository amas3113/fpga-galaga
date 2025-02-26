/*
 * bullet control module
 * Sets bullet sprite position based on whether the bullet is displayed
 * (traveling upwards) or not (attached to player controlled ship)
 */
module bullet #(parameter int BulletCount = 2) (
  input                             reset_i,
  input                             frame_clk_i,
  input                             bullet_display_i [BulletCount],
  input  [9:0]                      ship_x_i, ship_y_i,
  output [9:0]                      x_pos_o [BulletCount],
  output [9:0]                      y_pos_o [BulletCount]
);

  logic [9:0] x_pos [BulletCount];
  logic [9:0] y_pos [BulletCount];
  logic [9:0] y_vel [BulletCount];

  always_ff @(posedge reset_i or posedge frame_clk_i) begin
    if (reset_i) begin
      for (int i = 0; i < BulletCount; i++) begin
        x_pos[i] <= ship_x_i;
        y_pos[i] <= ship_y_i - 16;
      end
    end else begin
      for (int i = 0; i < BulletCount; i++) begin
        if (bullet_display_i[i]) begin
          y_pos[i] <= y_pos[i] - 5;
        end else begin
          x_pos[i] <= ship_x_i;
          y_pos[i] <= ship_y_i - 16;
        end
      end
    end
  end

  always_comb begin
    x_pos_o = x_pos;
    y_pos_o = y_pos;
  end

endmodule
