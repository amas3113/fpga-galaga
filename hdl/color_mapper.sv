module color_mapper #(
  parameter int BULLET_COUNT = 2,
  parameter int ENEMY_COUNT = 40
) (
  input [9:0]                     ship_xpos_i, ship_ypos_i,
  input [9:0]                     draw_xpos_i, draw_ypos_i,
  input [12:0]                    score_i,

  input                           bullet_display_i [BULLET_COUNT],
  input [9:0]                     bullet_xpos_i [BULLET_COUNT],
  input [9:0]                     bullet_ypos_i [BULLET_COUNT],

  input [ENEMY_COUNT - 1:0]       enemy_hit_i,
  input [ENEMY_COUNT - 1:0][9:0]  enemy_xpos_i, enemy_ypos_i,
  input [15:0]                    enemy1_addr_i,

  output logic [7:0]              red_o, green_o, blue_o
);

  // Ship
  localparam logic [9:0] ShipWidth = 16;
  localparam logic [9:0] ShipHeight = 16;

  logic ship_on;
  logic [9:0]   ship_rom_addr;
  logic [63:0]  ship_rom_data;

  sprite_rom ship_sprite (
    .addr_i (ship_rom_addr),
    .data_o (ship_rom_data)
  );

  // Enemy
  localparam logic [9:0] EnemyWidth = 16;
  localparam logic [9:0] EnemyHeight = 16;

  logic [ENEMY_COUNT - 1:0] enemy_on;
  logic [9:0]   enemy_rom_addr;
  logic [63:0]  enemy_rom_data;

  sprite_rom enemy_sprite (
    .addr_i (enemy_rom_addr),
    .data_o (enemy_rom_data)
  );

  // Bullet
  localparam logic [9:0] BulletWidth = 16;
  localparam logic [9:0] BulletHeight = 16;

  logic [BULLET_COUNT - 1:0] bullet_on;
  logic [9:0]   bullet_rom_addr;
  logic [63:0]  bullet_rom_data;

  sprite_rom bullet_sprite (
    .addr_i (bullet_rom_addr),
    .data_o (bullet_rom_data)
  );

  // Border
  logic border1_on;
  logic [10:0] border1_xpos = 131; //133 - 2
  logic [10:0] border1_ypos = 0;
  logic [10:0] border1_w = 2;
  logic [10:0] border1_h = 480;

  logic border2_on;
  logic [10:0] border2_xpos = 506; ///506
  logic [10:0] border2_ypos = 0;
  logic [10:0] border2_w = 2;
  logic [10:0] border2_h = 480;

  // Font
  localparam logic [9:0] FontWidth = 8;
  localparam logic [9:0] FontHeight = 16;

  logic [9:0]       font_on;
  logic [9:0][9:0]  font_xpos, font_ypos;
  logic [9:0][7:0]  font_rom_addr;
  logic [9:0][7:0]  font_rom_data;

  font_rom fonts [9:0] (
    .addr_i (font_rom_addr),
    .data_o (font_rom_data)
  );

  always_comb begin
    for (int i = 0; i < 10; i++) begin
      font_ypos[i] = 400;
      font_xpos[i] = 520 + (8 * i);
    end
  end

  // RGB Color Look-Up Table
  logic [23:0] color_LUT[12];
  assign color_LUT[0]   = 24'h000000;
  assign color_LUT[1]   = 24'hDEDEDE;
  assign color_LUT[2]   = 24'hEC3223;
  assign color_LUT[3]   = 24'hCE5223;
  assign color_LUT[4]   = 24'hFFFD54;
  assign color_LUT[5]   = 24'h74FBDF;
  assign color_LUT[6]   = 24'h419596;
  assign color_LUT[7]   = 24'h276AD6;
  assign color_LUT[8]   = 24'hB8B9DB;
  assign color_LUT[9]   = 24'h001DD5;
  assign color_LUT[10]  = 24'h8929D6;
  assign color_LUT[11]  = 24'hEA3CD7;

  function automatic int point_inside(int x1, int x2, int y1, int y2, int xi,
                                      int yi);
    if (xi < x1 || xi >= x2)
      return 0;
    if (yi < y1 || yi >= y2)
      return 0;
    return 1;
  endfunction

  always_comb begin : ship_on_procedure
    border1_on      = 1'b0;
    border2_on      = 1'b0;
    bullet_on       = 2'b0;
    ship_on         = 1'b0;
    ship_rom_addr   = 10'b0;
    bullet_rom_addr = 10'b0;
    enemy_on        = 0;
    enemy_rom_addr  = 10'b0;
    font_on         = 0;
    font_rom_addr   = 0;

    // Left Border
    if (point_inside(border1_xpos,
                     border1_xpos + border1_w,
                     border1_ypos,
                     border1_ypos + border1_h,
                     draw_xpos_i,
                     draw_ypos_i))
    begin
      border1_on = 1'b1;
    end

    // Right Border
    if (point_inside(border2_xpos,
                     border2_xpos + border2_w,
                     border2_ypos,
                     border2_ypos + border2_h,
                     draw_xpos_i,
                     draw_ypos_i))
    begin
      border2_on = 1'b1;
    end

    // Ship
    if (point_inside(ship_xpos_i,
                     ship_xpos_i + ShipWidth,
                     ship_ypos_i,
                     ship_ypos_i + ShipHeight,
                     draw_xpos_i,
                     draw_ypos_i))
    begin
      ship_on       = 1'b1;
      ship_rom_addr = (draw_ypos_i - ship_ypos_i + 16*'h00 + 16*'h0D);
    end

    `define VGA_OFFSET draw_ypos_i - font_ypos[i]
    `define NUM_OFFSET 6 * 16
    `define DIG_OFFSET (( (score_i / 10**(9-i)) - 10 * (score_i / 10**(10-i))) * 16)

    // Font
    for (int i = 0; i < 10; i++) begin
      if (point_inside(font_xpos[i],
                       font_xpos[i] + FontWidth,
                       font_ypos[i],
                       font_ypos[i] + FontHeight,
                       draw_xpos_i,
                       draw_ypos_i))
      begin
        font_on[i] = 1'b1;

        if (i < 6)
          font_rom_addr[i] = `VGA_OFFSET + i * 16;
        else
          font_rom_addr[i] = `VGA_OFFSET + `NUM_OFFSET + `DIG_OFFSET;
      end
    end

    `undef VGA_OFFSET
    `undef NUM_OFFSET
    `undef DIG_OFFSET

    // Bullets
    for (int i = 0; i < BULLET_COUNT; i++) begin
      if (bullet_display_i[i] &&
          point_inside(bullet_xpos_i[i],
                       bullet_xpos_i[i] + BulletWidth,
                       bullet_ypos_i[i],
                       bullet_ypos_i[i] + BulletHeight,
                       draw_xpos_i,
                       draw_ypos_i))
      begin
        bullet_on[i]    = 1'b1;
        bullet_rom_addr = draw_ypos_i - bullet_ypos_i[i] + 16*'h2F + 16*'h0D;
      end
    end

    // Enemies
    for (int i = 0; i < ENEMY_COUNT; i++) begin
      if (~enemy_hit_i[i] &&
          point_inside(enemy_xpos_i[i],
                       enemy_xpos_i[i] + EnemyWidth,
                       enemy_ypos_i[i],
                       enemy_ypos_i[i] + EnemyHeight,
                       draw_xpos_i,
                       draw_ypos_i))
      begin
        enemy_on[i]     = 1'b1;
        enemy_rom_addr  = draw_ypos_i - enemy_ypos_i[i] + 16 * enemy1_addr_i + 16*'h0D;
      end
    end
  end

  always_comb begin : rgb_display
    red_o   = 8'h00;
    green_o = 8'h00;
    blue_o  = 8'h00;

    // Border
    if (border1_on || border2_on) begin
      red_o   = 8'hFF;
      green_o = 8'hFF;
      blue_o  = 8'hFF;
    end

    // Ship
    if (ship_on &&
        ship_rom_data[63 - 4*(draw_xpos_i - ship_xpos_i)-:4] != 4'h0)
    begin
      red_o   = color_LUT[ship_rom_data[63 - 4*(draw_xpos_i - ship_xpos_i)-:4]][23:16];
      green_o = color_LUT[ship_rom_data[63 - 4*(draw_xpos_i - ship_xpos_i)-:4]][15: 8];
      blue_o  = color_LUT[ship_rom_data[63 - 4*(draw_xpos_i - ship_xpos_i)-:4]][7 : 0];
    end

    // Font
    for (int i = 0; i < 10; i++) begin
      if (font_on[i] &&
          font_rom_data[i][8 - draw_xpos_i - font_xpos[i]])
      begin
        red_o   = 8'hFF;
        green_o = 8'hFF;
        blue_o  = 8'hFF;
      end
    end

    // Enemy
    for (int i = 0; i < ENEMY_COUNT; i++) begin
      if (enemy_on[i] &&
          enemy_rom_data[63 - 4*(draw_xpos_i - enemy_xpos_i[i])-:4] != 4'h0)
      begin
        red_o   = color_LUT[enemy_rom_data[(63 - 4*(draw_xpos_i - enemy_xpos_i[i]))-:4]][23:16];
        green_o = color_LUT[enemy_rom_data[(63 - 4*(draw_xpos_i - enemy_xpos_i[i]))-:4]][15: 8];
        blue_o  = color_LUT[enemy_rom_data[(63 - 4*(draw_xpos_i - enemy_xpos_i[i]))-:4]][7 : 0];
      end
    end

    // Bullet
    for (int i = 0; i < BULLET_COUNT; i++) begin
      if (bullet_on[i] &&
          bullet_rom_data[63 - 4*(draw_xpos_i - bullet_xpos_i[i])-:4] != 4'h0)
      begin
        red_o   = color_LUT[bullet_rom_data[(63 - 4*(draw_xpos_i - bullet_xpos_i[i]))-:4]][23:16];
        green_o = color_LUT[bullet_rom_data[(63 - 4*(draw_xpos_i - bullet_xpos_i[i]))-:4]][15: 8];
        blue_o  = color_LUT[bullet_rom_data[(63 - 4*(draw_xpos_i - bullet_xpos_i[i]))-:4]][7 : 0];
      end
    end
  end

endmodule
