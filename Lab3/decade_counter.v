// Decade Counter Module (Modulo-10 Counter)
// This counter increments on each rising edge of 'clk' when 'en' is high.
// When the count reaches 9, it wraps around to 0 and asserts 'carry' for one clock cycle.
// An asynchronous reset (active high) sets the counter to 0.

module decade_counter (
    input wire clk,       // Clock input
    input wire reset,     // Asynchronous reset (active high)
    input wire en,        // Enable signal: counter increments when high
    output reg [3:0] count, // 4-bit counter output (values 0 to 9)
    output reg carry      // Carry output, high for one cycle when count wraps
);

  // Always block sensitive to the rising edge of clk or reset
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Asynchronous reset: clear the counter and carry
      count <= 4'd0;
      carry <= 1'b0;
    end else if (en) begin
      if (count == 4'd9) begin
        // If count reaches 9, wrap back to 0 and generate a carry
        count <= 4'd0;
        carry <= 1'b1;
      end else begin
        // Otherwise, increment the counter and clear carry
        count <= count + 1;
        carry <= 1'b0;
      end
    end else begin
      // When enable is low, hold the count and ensure carry is low
      carry <= 1'b0;
    end
  end

endmodule
