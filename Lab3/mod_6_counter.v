// mod6_counter.v
// A modulo-6 counter (counts from 0 to 5). It is useful for the tens digit of seconds (and minutes).

module mod6_counter (
    input  wire clk,       // Clock input
    input  wire reset,     // Asynchronous reset (active high)
    input  wire en,        // Enable signal
    output reg [3:0] count, // 4-bit output (0 to 5)
    output reg carry       // Carry output, high for one cycle when wrapping
);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      count <= 4'd0;
      carry <= 1'b0;
    end else if (en) begin
      if (count == 4'd5) begin
        count <= 4'd0;
        carry <= 1'b1;
      end else begin
        count <= count + 1;
        carry <= 1'b0;
      end
    end else begin
      carry <= 1'b0;
    end
  end

endmodule
