// stopwatch_tb.v
// Testbench for the stopwatch top-level module.

`timescale 1ns/1ps

module stopwatch_tb;
  // Inputs to the stopwatch
  reg clk_100MHz;
  reg btn_reset;
  reg btn_pause;
  reg sw_adj;
  reg sw_sel;
  
  // Outputs from the stopwatch
  wire [6:0] seg;
  wire [3:0] an;
  
  // Instantiate the stopwatch module (assumed to be in the same project)
  stopwatch uut (
    .clk_100MHz(clk_100MHz),
    .btn_reset(btn_reset),
    .btn_pause(btn_pause),
    .sw_adj(sw_adj),
    .sw_sel(sw_sel),
    .seg(seg),
    .an(an)
  );
  
  // Generate 100 MHz clock: period = 10 ns (toggle every 5 ns)
  initial begin
    clk_100MHz = 0;
    forever #5 clk_100MHz = ~clk_100MHz;
  end
  
  // Stimulus for buttons and switches
  initial begin
    // Initialize inputs:
    btn_reset = 0;
    btn_pause = 0;
    sw_adj = 0;
    sw_sel = 0;
    
    // ----------------------------
    // Apply a reset pulse
    // ----------------------------
    #20;               // wait 20 ns at start
    btn_reset = 1;     // assert reset
    #20;               // hold reset for 20 ns
    btn_reset = 0;     // release reset
    
    // ----------------------------
    // Let the stopwatch run in normal mode for 5 seconds.
    // Note: 1 second = 1e9 ns, so 5 seconds = 5e9 ns.
    // ----------------------------
    #5000000000;
    
    // ----------------------------
    // Pause the stopwatch
    // ----------------------------
    btn_pause = 1;     // simulate a pause button press
    #100;              // pulse width (100 ns)
    btn_pause = 0;
    // Wait for 1 second while paused
    #1000000000;
    
    // ----------------------------
    // Resume the stopwatch
    // ----------------------------
    btn_pause = 1;     // simulate a resume button press
    #100;
    btn_pause = 0;
    
    // ----------------------------
    // Switch to adjust mode:
    // First, adjust seconds by setting ADJ high and SEL high.
    // ----------------------------
    sw_adj = 1;  // enter adjust mode
    sw_sel = 1;  // select seconds for adjustment
    // Let adjustment run for 3 seconds
    #3000000000;
    
    // Now, adjust minutes by setting SEL low.
    sw_sel = 0;  // select minutes for adjustment
    #3000000000;
    
    // Exit adjust mode
    sw_adj = 0;
    
    // Let the stopwatch run in normal mode again for 1 second
    #1000000000;
    
    // End simulation
    $stop;
  end

endmodule
