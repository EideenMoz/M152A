// minutes_counter.v
// Implements the minutes counter for the stopwatch.
// It consists of two cascaded counters: a decade counter (for the ones digit)
// and a modulo-6 counter (for the tens digit). When the ones digit wraps (9 -> 0),
// it increments the tens digit. When minutes reach 59, they wrap to 00.

module minutes_counter(
    input  wire clk,         // Clock input (can be minute_enable pulse in normal mode or 2Hz in adjust mode)
    input  wire reset,       // Asynchronous reset (active high)
    input  wire pause,       // Pause signal: when high, the counter holds its value
    output wire [3:0] min_ones, // Minutes ones digit (0-9)
    output wire [3:0] min_tens  // Minutes tens digit (0-5)
);

  // Enable signal: counting occurs only when pause is low.
  wire en = ~pause;

  // Internal wire for carry-out from the ones digit.
  wire ones_carry;

  // Instantiate the ones digit counter (modulo-10)
  decade_counter ones_counter (
    .clk(clk),
    .reset(reset),
    .en(en),
    .count(min_ones),
    .carry(ones_carry)
  );

  // Instantiate the tens digit counter (modulo-6)
  // It increments only when ones_counter wraps from 9 to 0.
  mod6_counter tens_counter (
    .clk(clk),
    .reset(reset),
    .en(ones_carry),
    .count(min_tens),
    .carry()  // Unused carry output
  );

endmodule
