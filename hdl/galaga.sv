module galaga (
  // Clocks
  input           MAX10_CLK1_50, MAX10_CLK2_50,

  // Key Buttons
  input   [1:0]   KEY,

  // Switches
  input   [9:0]   SW,

  // LEDs
  output  [9:0]   LEDR,

  // 7 Segment Displays
  output  [7:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,

  // VGA Signals
  output          VGA_HS, VGA_VS,
  output  [3:0]   VGA_R, VGA_G, VGA_B,

  // Arduino header
  inout   [15:0]  ARDUINO_IO,
  inout           ARDUINO_RESET_N
);
  localparam int EnemyCount = 40;
  localparam int BulletCount = 2;

  logic reset_n, vssig, blank, sync, VGA_clk;

  logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
  logic [9:0] drawxsig, drawysig;
  logic [9:0] shipxsig, shipysig, shipsize;
  logic [7:0] red, blue, green;

  always_comb begin
    ARDUINO_IO[10] = SPI0_CS_N;
    ARDUINO_IO[11] = SPI0_MOSI;
    ARDUINO_IO[12] = 1'bZ;
    ARDUINO_IO[13] = SPI0_SCLK;
    SPI0_MISO = ARDUINO_IO[12];

    ARDUINO_IO[9] = 1'bZ;
    USB_IRQ = ARDUINO_IO[9];

    // Assignments specific to Circuits At Home UHS_20
    ARDUINO_RESET_N = USB_RST;
    ARDUINO_IO[7] = USB_RST;  // USB reset
    ARDUINO_IO[8] = 1'bZ;     // this is GPX (set to input)
    // GPX is not needed for standard USB host - set to 0 to prevent interrupt
    USB_GPX = 1'b0;
    // Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
    ARDUINO_IO[6] = 1'b1;

    // Assign one button to reset
    reset_n = ~(KEY[0]);

    // Our A/D converter is only 12 bit
    VGA_R = red[7:4];
    VGA_B = blue[7:4];
    VGA_G = green[7:4];
  end

  wire        sys_clk;
  wire        command_valid;
  wire [4:0]  command_channel;
  wire        command_startofpacket;
  wire        command_endofpacket;
  wire        command_ready;
  wire        response_valid/* synthesis keep */;
  wire [4:0]  response_channel;
  wire [11:0] response_data;
  wire        response_startofpacket;
  wire        response_endofpacket;

  //reg  [4:0]  cur_adc_ch/* synthesis noprune */;
  //reg  [11:0] adc_sample_data/* synthesis noprune */;
  reg  [12:0] vol/* synthesis noprune */;

  assign command_startofpacket = 1'b1;  // ignore in altera_adc_control core
  assign command_endofpacket = 1'b1;    // ignore in altera_adc_control core
  assign command_valid = 1'b1;

  soc u1 (
    .clk_clk                              (MAX10_CLK1_50),          // clk.clk
    .reset_reset_n                        (1'b1),                   // reset.reset_n
    .modular_adc_0_command_valid          (command_valid),          // modular_adc_0_command.valid
    .modular_adc_0_command_channel        (command_channel),        // .channel
    .modular_adc_0_command_startofpacket  (command_startofpacket),  // .startofpacket
    .modular_adc_0_command_endofpacket    (command_endofpacket),    // .endofpacket
    .modular_adc_0_command_ready          (command_ready),          // .ready
    .modular_adc_0_response_valid         (response_valid),         // modular_adc_0_response.valid
    .modular_adc_0_response_channel       (response_channel),       // .channel
    .modular_adc_0_response_data          (response_data),          // .data
    .modular_adc_0_response_startofpacket (response_startofpacket), // .startofpacket
    .modular_adc_0_response_endofpacket   (response_endofpacket),   // .endofpacket
    .clock_bridge_sys_out_clk_clk         (sys_clk)                 // clock_bridge_sys_out_clk.clk
  );

  logic [12:0] rdata1, rdata2, rdata3, rdata4, rdata5;

  /*
  r - Ch#: Function
  0 - Ch1: Y-axis
  1 - Ch2: X-axis
  2 - Ch3: B Button
  3 - Ch4: A Button
  4 - Ch5: Joystick Button

  r |- Ch - Func - Actual
  1 |- 1  - Y   | X
  2 |- 2  - X   | B
  3 |- 3  - B   | A
  4 |- 4  - A   | J
  5 |- 5  - J   | Y
  */

  always @(posedge sys_clk) begin
    if (response_valid) begin
      //adc_sample_data <= response_data;
      //cur_adc_ch <= response_channel;

      // adc_sample_data: hold 12-bit adc sample value
      // Vout = Vin (12-bit x2 x 2500 / 4095)

      unique case (command_channel)
        5'h1: rdata1 <= response_data * 2 * 2500 / 4095;
        5'h2: rdata2 <= response_data * 2 * 2500 / 4095;
        5'h3: rdata3 <= response_data * 2 * 2500 / 4095;
        5'h4: rdata4 <= response_data * 2 * 2500 / 4095;
        5'h5: rdata5 <= response_data * 2 * 2500 / 4095;
      endcase
    end
  end

  assign LEDR[9:0] = vol[12:3]; // led is high active

  assign HEX5[7] = 1'b1; // low active (decimal point)
  assign HEX4[7] = 1'b1; // low active
  assign HEX3[7] = 1'b0; // low active
  assign HEX2[7] = 1'b1; // low active
  assign HEX1[7] = 1'b1; // low active
  assign HEX0[7] = 1'b1; // low active

  seg7_driver hex0 (
    .dig_i(rdata3 - (rdata3/10) * 10),
    .seg_o(HEX0)
  );

  seg7_driver hex1 (
    .dig_i(rdata3/10 - (rdata3/100)*10),
    .seg_o(HEX1)
  );

  seg7_driver hex2 (
    .dig_i(rdata3/100 - (rdata3/1000)*10),
    .seg_o(HEX2)
  );

  seg7_driver hex3 (
    .dig_i(rdata3/1000),
    .seg_o(HEX3)
  );

  assign HEX4 = 8'b10111111;

  seg7_driver hex5 (
    .dig_i(SW[3:0]),
    .seg_o(HEX5)
  );

  logic [9:0] enemy_xvel, enemy_yvel;
  logic [15:0] enemy_rom_addr;
  logic pause;

  assign pause = (rdata2 < 13'h0500);

  logic [9:0] bullet_xpos [BulletCount];
  logic [9:0] bullet_ypos [BulletCount];
  logic bullet_display [BulletCount];
  logic bullet_hit [BulletCount];

  logic [EnemyCount - 1:0][9:0]  enemy_xpos, enemy_ypos;
  logic [EnemyCount - 1:0]       enemy_hit;

  adc_ctr adc_ctr (
    .reset_i    (reset_n),
    .clk_i      (sys_clk),
    .channel_o  (command_channel)
  );

  logic [12:0] Score_;

  color_mapper cm (
    .ship_xpos_i      (shipxsig),
    .ship_ypos_i      (shipysig),
    .draw_xpos_i      (drawxsig),
    .draw_ypos_i      (drawysig),
    .score_i          (Score_),
    .bullet_display_i (bullet_display),
    .bullet_xpos_i    (bullet_xpos),
    .bullet_ypos_i    (bullet_ypos),
    .enemy_xpos_i     (enemy_xpos),
    .enemy_ypos_i     (enemy_ypos),
    .enemy_hit_i      (enemy_hit),
    .enemy1_addr_i    (enemy_rom_addr),
    .red_o            (red),
    .green_o          (green),
    .blue_o           (blue)
  );

  pc_ship ship (
    .reset_i      (reset_n),
    .frame_clk_i  (VGA_VS),
    .vol_i        (rdata1),
    .ship_xpos_o  (shipxsig),
    .ship_ypos_o  (shipysig),
    .ship_size_o  (shipsize)
  );

  enemy enemy (
    .reset_i      (reset_n),
    .frame_clk_i  (VGA_VS),
    .xvel_i       (enemy_xvel),
    .yvel_i       (enemy_yvel),
    .xpos_o       (enemy_xpos),
    .ypos_o       (enemy_ypos)
  );

  enemy_fsm enemy_fsm (
    .reset_i  (reset_n),
    .clk_i    (VGA_VS),
    .pause_i  (pause),
    .xvel_o   (enemy_xvel),
    .yvel_o   (enemy_yvel),
    .addr_o   (enemy_rom_addr)
  );

  bullet bullet (
    .reset_i          (reset_n),
    .frame_clk_i      (VGA_VS),
    .bullet_display_i (bullet_display),
    .ship_x_i         (shipxsig),
    .ship_y_i         (shipysig),
    .x_pos_o          (bullet_xpos),
    .y_pos_o          (bullet_ypos)
  );

  logic reset_t;
  assign reset_t = (rdata2 < 13'h0200);

  bullet_fsm bullet_fsm (
    .reset_i    (reset_n || reset_t),
    .clk_i      (VGA_VS),
    .rdata3_i   (rdata3),
    .bhit_i     (bullet_hit),
    .bdisplay_o (bullet_display)
  );

  hit_detect hit_detect (
    .clk_i          (VGA_VS),
    .reset_i        (reset_n),
    .bullet_xpos_i  (bullet_xpos),
    .bullet_ypos_i  (bullet_ypos),
    .enemy_xpos_i   (enemy_xpos),
    .enemy_ypos_i   (enemy_ypos),
    .bhit_o         (bullet_hit),
    .ehit_o         (enemy_hit)
  );

  score score (
    .clk_i    (MAX10_CLK1_50),
    .reset_i  (reset_n),
    .ehit_i   (enemy_hit),
    .score_o  (Score_)
  );

  vga_controller vga_controller (
    .clk_i        (MAX10_CLK1_50),
    .reset_i      (reset_n),
    .hs_o         (VGA_HS),
    .vs_o         (VGA_VS),
    .pixel_clk_o  (VGA_clk),
    .blank_o      (blank),
    .sync_o       (sync),
    .drawx_o      (drawxsig),
    .drawy_o      (drawysig)
  );

endmodule
