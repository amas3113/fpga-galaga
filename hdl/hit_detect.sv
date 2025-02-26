module hit_detect #(
  parameter int BulletCount = 2,
  parameter int EnemyCount = 40
) (
  input                           clk_i,
  input                           reset_i,
  input [9:0]                     bullet_xpos_i [BulletCount],
  input [9:0]                     bullet_ypos_i [BulletCount],
  input   [EnemyCount-1:0][9:0]  enemy_xpos_i, enemy_ypos_i,
  output                          bhit_o [BulletCount],
  output  [EnemyCount-1:0]       ehit_o
);

  logic [EnemyCount-1:0] curr_ehit, ehit_reg;
  // ehit_reg is the enemy sprite's 'alive' status
  initial ehit_reg = 0;

  always_comb begin
    bhit_o = '{0, 0};
    curr_ehit = 0;

    // if bullet has passed top of screen (underflow)
    for (int i = 0; i < BulletCount; i++) begin
      if (bullet_ypos_i[i] > 480)
        bhit_o[i] = 1;
    end

    // detect if bullet sprite intersects enemy sprite
    for (int i = 0; i < EnemyCount; i++) begin
      for (int j = 0; j < BulletCount; j++) begin
        if (~ehit_reg[i] &&
            enemy_xpos_i[i] < bullet_xpos_i[j] + 7 &&
            enemy_xpos_i[i] + 16 > bullet_xpos_i[j] + 5 &&
            enemy_ypos_i[i] < bullet_ypos_i[j] + 11 &&
            enemy_ypos_i[i] + 16 > bullet_ypos_i[j] + 3)
        begin
          curr_ehit[i] = 1;
          bhit_o[j] = 1;
        end
      end
    end
  end

  // update enemy 'alive' status register
  always_ff @(posedge clk_i or posedge reset_i) begin
    if (reset_i) begin
      ehit_reg <= 0;
    end else begin
      for (int i = 0; i < EnemyCount; i++) begin
        ehit_reg[i] <= (ehit_reg[i] || curr_ehit[i]);
      end
    end
  end

  assign ehit_o = ehit_reg;

endmodule
