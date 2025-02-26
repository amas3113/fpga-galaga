module score #(
  parameter int EnemyCount = 40
) (
  input                     clk_i,
  input                     reset_i,
  input  [EnemyCount-1:0]   ehit_i,
  output [12:0]             score_o
);

  always_comb begin
    score_o = 0;
    for (int i = 0; i < EnemyCount; i++) begin
      score_o += 100 * ehit_i[i];
    end
  end

endmodule
