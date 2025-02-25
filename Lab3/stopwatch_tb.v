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
  
  // Instantiate the stopwatch module
  stopwatch uut (
    .clk_100MHz(clk_100MHz),
    .btn_reset(btn_reset),
    .btn_pause(btn_pause),
    .sw_adj(sw_adj),
    .sw_sel(sw_sel),
    .seg(seg),
    .an(an)
  );

  // ----------------------------------------------------------------
  // 1) Generate 100 MHz clock
  //    Period = 10 ns --> toggle every 5 ns
  // ----------------------------------------------------------------
  initial begin
    clk_100MHz = 0;
    forever #5 clk_100MHz = ~clk_100MHz;
  end
  
  // ----------------------------------------------------------------
  // 2) Dumpfile and dumpvars for GTKWave
  //    After running iverilog, do:  vvp a.out
  //    Then open with:            gtkwave stopwatch_tb.vcd
  // ----------------------------------------------------------------
  initial begin
    $dumpfile("stopwatch_tb.vcd");
    $dumpvars(0, stopwatch_tb);
  end
  
  // ----------------------------------------------------------------
  // 3) Test Stimulus
  //    We do short delays, because real-time seconds would be huge.
  // ----------------------------------------------------------------
  initial begin
    // Initialize inputs
    btn_reset = 0;
    btn_pause = 0;
    sw_adj = 0;
    sw_sel = 0;
    
    // Give some time for the system to come out of reset
    #100;  // 100 ns
    
    // --- Apply a reset pulse ---
    $display("[%t ns] Applying reset...", $time);
    btn_reset = 1;     
    #100;             // hold reset for 100 ns
    btn_reset = 0;
    $display("[%t ns] Released reset.", $time);
    
    // Wait a bit in normal mode
    $display("[%t ns] Let the stopwatch run for a short while in normal mode.", $time);
    #200_000;  // 200 microseconds in simulation; adjust as you like
    
    // --- Pause the stopwatch ---
    $display("[%t ns] Pausing stopwatch...", $time);
    btn_pause = 1;
    #100;
    btn_pause = 0;
    
    // Stay paused for some time
    #50_000; // 50 microseconds
    
    // --- Resume the stopwatch ---
    $display("[%t ns] Resuming stopwatch...", $time);
    btn_pause = 1;
    #100;
    btn_pause = 0;
    
    // Wait a bit again in normal mode
    #150_000;
    
    // --- Enter Adjust Mode (adjust seconds) ---
    $display("[%t ns] Enter adjust mode for seconds...", $time);
    sw_adj = 1;  
    sw_sel = 1;  
    // Let adjustment run for a little while
    #150_000;
    
    // --- Adjust minutes ---
    $display("[%t ns] Switching to adjust minutes...", $time);
    sw_sel = 0;
    #150_000;
    
    // --- Exit adjust mode ---
    $display("[%t ns] Exiting adjust mode...", $time);
    sw_adj = 0;
    
    // Wait a bit in normal mode
    #200_000;
    
    $display("[%t ns] Simulation complete.", $time);
    $stop;
  end

  initial begin
  // In your testbench, after instantiating the stopwatch module:
  $monitor("Time=%t ns | sec_tens=%0d sec_ones=%0d | min_tens=%0d min_ones=%0d",
           $time,
           uut.sec_counter_inst.sec_tens,
           uut.sec_counter_inst.sec_ones,
           uut.min_counter_inst.min_tens,
           uut.min_counter_inst.min_ones
          );
  end

  
endmodule
