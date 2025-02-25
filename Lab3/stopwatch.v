`timescale 1ns/1ps

// stopwatch.v
// Top-level module that connects the clock divider, counters,
// debouncers, and seven-segment display driver to form the stopwatch.

module stopwatch(
    input  wire clk_100MHz,  // 100 MHz master clock from the FPGA
    input  wire btn_reset,   // Raw push button for reset
    input  wire btn_pause,   // Raw push button for pause
    input  wire sw_adj,      // Slider switch: ADJ (adjust mode)
    input  wire sw_sel,      // Slider switch: SEL (0 = minutes, 1 = seconds)
    output wire [6:0] seg,   // Seven-segment display segments (active low)
    output wire [3:0] an     // Seven-segment display anode controls (active low)
);

  // --------------------------------------------------
  // Debounce the push buttons using the master clock (≈100 MHz)
  // SHOULDE USE MASTER CLOCK HERE INSTEAD
  // --------------------------------------------------
  wire reset_debounced, pause_debounced;
  debounce db_reset(
      .clk(clk_fast),
      .btn_in(btn_reset),
      .btn_out(reset_debounced)
  );
  debounce db_pause(
      .clk(clk_fast),
      .btn_in(btn_pause),
      .btn_out(pause_debounced)
  );

  // (The slider switches sw_adj and sw_sel are assumed to be stable.)
  wire adjust_debounced, select_debounced;
  debounce db_asjust(
    .clk(clk_fast),
    .btn_in(sw_adj),
    .btn_out(adjust_debounced)
  );
  debounce db_select(
    .clk(clk_fast),
    .btn_in(sw_sel),
    .btn_out(select_debounced)  // Replace sw_sel with select_debounced below
  );

  // --------------------------------------------------
  // Instantiate the Clock Divider
  // --------------------------------------------------
  wire clk_2Hz, clk_1Hz, clk_fast, clk_blink;
  clock_divider clk_div_inst (
      .clk_100MHz(clk_100MHz),
      .reset(reset_debounced),  // Can also debounce reset if desired
      .clk_2Hz(clk_2Hz),
      .clk_1Hz(clk_1Hz),
      .clk_fast(clk_fast),
      .clk_blink(clk_blink)
  );
  
  // --------------------------------------------------
  // Choose the clock source for the counters based on ADJ and SEL.
  //
  // In normal mode (ADJ low):
  //   - Seconds counter uses clk_1Hz.
  //   - Minutes counter is updated by a pulse (minute_enable) from the seconds counter.
  //
  // In adjust mode (ADJ high):
  //   - If SEL is high, adjust seconds (use clk_2Hz) and freeze minutes.
  //   - If SEL is low, adjust minutes (use clk_2Hz) and freeze seconds.
  // --------------------------------------------------
  wire sec_clk, min_clk, minute_enable;
  
  // For the seconds counter:
  //   - In normal mode: use clk_1Hz.
  //   - In adjust mode for seconds (sw_adj & sw_sel): use clk_2Hz.
  assign sec_clk = (adjust_debounced && select_debounced) ? clk_2Hz : clk_1Hz;
  
  // For the minutes counter:
  //   - In normal mode: update on the seconds counter's minute_enable pulse.
  //   - In adjust mode for minutes (sw_adj & ~sw_sel): use clk_2Hz.
  assign min_clk = (adjust_debounced && ~select_debounced) ? clk_2Hz : minute_enable;
  
  // Generate pause signals:
  // In adjust mode, freeze the unselected counter.
  wire sec_pause, min_pause;
  assign sec_pause = adjust_debounced ? (~select_debounced) : pause_debounced;      // Updated to take in debounced adjust switch
  assign min_pause = adjust_debounced ? ( select_debounced) : pause_debounced;
  
  // --------------------------------------------------
  // Instantiate the Seconds Counter Module
  // --------------------------------------------------
  wire [3:0] sec_ones, sec_tens;
  seconds_counter sec_counter_inst (
      .clk(sec_clk),
      .reset(reset_debounced),
      .pause(sec_pause),
      .sec_ones(sec_ones),
      .sec_tens(sec_tens),
      .minute_enable(minute_enable)  // Pulse to drive minutes counter in normal mode
  );
  
  // --------------------------------------------------
  // Instantiate the Minutes Counter Module
  // --------------------------------------------------
  wire [3:0] min_ones, min_tens;
  minutes_counter min_counter_inst (
      .clk(min_clk),
      .reset(reset_debounced),
      .pause(min_pause),
      .min_ones(min_ones),
      .min_tens(min_tens)
  );
  
  // --------------------------------------------------
  // Combine the 4 digits into a single vector.
  // The ordering is: [min_tens, min_ones, sec_tens, sec_ones]
  // --------------------------------------------------
  wire [15:0] digits;
  assign digits = {min_tens, min_ones, sec_tens, sec_ones};
  
  // --------------------------------------------------
  // Instantiate the Seven-Segment Multiplexer/Driver Module
  // (Make sure the module name here matches the one in sev_segment.v.)
  // --------------------------------------------------
  sev_segment display_inst (
      .clk(clk_fast),
      .clk_blink(clk_blink),
      .adjust(adjust_debounced),  // Adjust mode: if high, blink the selected digits.
      .sel(select_debounced),     // Select: 0 = minutes blink; 1 = seconds blink.
      .digits(digits),
      .seg(seg),
      .an(an)
  );

endmodule
