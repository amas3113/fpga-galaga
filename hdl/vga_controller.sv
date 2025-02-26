module vga_controller (
  input         clk_i,        // 50 MHz clock
  input         reset_i,      // reset signal
  output logic  hs_o,         // Horizontal sync pulse (active low)
  output logic  vs_o,         // Vertical sync pulse (active high)
  output logic  pixel_clk_o,  // 25 Mhz pixel clock output
  output logic  blank_o,      // Blanking interval indication (active low)
  output logic  sync_o,       // Composite sync signal (active low, unused but
                              // required by video DAC)
  output [9:0]  drawx_o,      // Horizontal coordinate
  output [9:0]  drawy_o       // Vertical coordinate
);

  // active video -> front porch -> sync -> back porch
  // h active       = 640 (0-639)
  // h front porch  = 16  (640-655)
  // h sync         = 96  (656-751)
  // h back porch   = 48  (752-799)
  // v active       = 480 (0-479)
  // v front porch  = 11  (480-490)
  // v sync         = 2   (491-492)
  // v back porch   = 32  (493-524)

  // 800 horizontal pixels, 525 vertical pixels
  parameter int unsigned PIXELS_H = 799;
  parameter int unsigned PIXELS_V = 524;

  parameter int unsigned H_ACTIVE       = 640;
  parameter int unsigned H_FRONT_PORCH  = 16;
  parameter int unsigned H_SYNC         = 96;
  parameter int unsigned H_BACK_PORCH   = 48;

  parameter int unsigned V_ACTIVE       = 480;
  parameter int unsigned V_FRONT_PORCH  = 11;
  parameter int unsigned V_SYNC         = 2;
  parameter int unsigned V_BACK_PORCH   = 32;

  // horizontal and vertical line counters
  logic [9:0] hc, vc;
  logic clkdiv;

  // signal indicates if ok to display color for a pixel
  logic display;

  assign sync_o = 0;

  always_ff @(posedge clk_i or posedge reset_i) begin : clock_division
    clkdiv <= reset_i ? 0 : ~clkdiv;
  end

  always_ff @(posedge clkdiv or posedge reset_i) begin : counter_procedure
    if (reset_i) begin
      hc <= 0;
      vc <= 0;
    end else if (hc == PIXELS_H) begin
      hc <= 0;
      vc <= (vc == PIXELS_V) ? 0 : vc + 1;
    end else begin
      hc <= hc + 1;
    end
  end

  assign drawx_o = hc;
  assign drawy_o = vc;

  always_ff @(posedge clkdiv or posedge reset_i) begin : hsync_procedure
    if (reset_i) begin
      hs_o <= 0;
    end else begin
      if (hc + 1 >= H_ACTIVE + H_FRONT_PORCH &&
          hc + 1 <  H_ACTIVE + H_FRONT_PORCH + H_SYNC)
      begin
        hs_o <= 0;
      end else begin
        hs_o <= 1;
      end
    end
  end

  always_ff @(posedge clkdiv or posedge reset_i) begin : vsync_procedure
    if (reset_i) begin
      vs_o <= 0;
    end else begin
      if (vc + 1 == 9'b111101010 ||
          vc + 1 == 9'b111101011)
      begin
        vs_o <= 0;
      end else begin
        vs_o <= 1;
      end
    end
  end

  always_comb begin : display_on_procedure
    if (hc >= H_ACTIVE || vc >= V_ACTIVE) begin
      display = 0;
    end else begin
      display = 1;
    end
  end

endmodule
