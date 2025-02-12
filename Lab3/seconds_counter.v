// seconds_counter.v
// This module implements the seconds counter for the stopwatch.
// It uses a modulo-10 counter for the ones digit and a modulo-6 counter for the tens digit.
// The counter increments on each tick of its input clock (which might be 1 Hz in normal mode or 2 Hz in adjust mode).
// When the seconds reach 59 and then wrap to 00, the tens counter produces a carry (minute_enable)
// which can be used to increment the minutes counter.

module seconds_counter(
    input  wire clk,           // Input tick: either a 1 Hz (normal) or 2 Hz (adjust mode) clock.
    input  wire reset,         // Asynchronous reset (active high)
    input  wire pause,         // Pause input: when high, the counter is frozen.
    output wire [3:0] sec_ones, // Seconds ones digit (0-9)
    output wire [3:0] sec_tens, // Seconds tens digit (0-5)
    output wire minute_enable  // One-cycle pulse: high when seconds roll over from 59 to 00.
);

  // When paused, disable counting.
  wire en = ~pause;

  // Wire to catch the carry from the ones digit.
  wire ones_carry;

  // Instantiate the ones digit counter (modulo-10)
  decade_counter ones_counter (
    .clk   (clk),
    .reset (reset),
    .en    (en),
    .count (sec_ones),
    .carry (ones_carry)
  );

  // Instantiate the tens digit counter (modulo-6)
  // It increments only when the ones digit rolls over (ones_carry).
  mod6_counter tens_counter (
    .clk   (clk),
    .reset (reset),
    .en    (ones_carry),   // Only increment tens when ones digit wraps from 9 to 0.
    .count (sec_tens),
    .carry (minute_enable) // This carry becomes high when the tens counter wraps (i.e. 5 -> 0).
  );

endmodule
