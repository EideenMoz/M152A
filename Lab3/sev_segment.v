 // sevseg_mux.v
// Multiplexes four 4-bit digits to drive a four-digit seven-segment display.
// Also implements blinking for the selected digit when in adjust mode.
module sevseg_mux(
    input  wire clk,          // Fast clock for multiplexing (≈200 Hz)
    input  wire clk_blink,    // Blink clock (≈1 Hz)
    input  wire adjust,       // Adjust mode flag (ADJ)
    input  wire sel,          // Select: 0 = minutes, 1 = seconds (which part to blink)
    input  wire [15:0] digits, // 4 digits: [min_tens, min_ones, sec_tens, sec_ones]
    output reg [6:0] seg,     // 7-segment output (active low)
    output reg [3:0] an       // Anode signals (active low)
);

  // A 2-bit counter to cycle through the 4 digits.
  reg [1:0] digit_sel = 0;
  always @(posedge clk) begin
      digit_sel <= digit_sel + 1;
  end
  
  // Select the current 4-bit digit to display.
  reg [3:0] digit;
  always @(*) begin
      case (digit_sel)
          2'd0: digit = digits[15:12];  // Minutes tens
          2'd1: digit = digits[11:8];   // Minutes ones
          2'd2: digit = digits[7:4];    // Seconds tens
          2'd3: digit = digits[3:0];    // Seconds ones
          default: digit = 4'd0;
      endcase
  end
  
  // Determine whether to blank (turn off) the digit.
  // In adjust mode, the selected portion blinks:
  // - If sel is 0 (minutes adjustment), blank digits 0 and 1.
  // - If sel is 1 (seconds adjustment), blank digits 2 and 3.
  reg blink;
  always @(*) begin
      if (adjust) begin
          if ((sel && (digit_sel == 2 || digit_sel == 3)) ||
              (~sel && (digit_sel == 0 || digit_sel == 1)))
              blink = ~clk_blink;  // Use blink clock to toggle display
          else
              blink = 1'b1;
      end else begin
          blink = 1'b1;
      end
  end
  
  // Seven-segment decoder: Convert 4-bit digit to 7-seg pattern.
  // (Assuming a common anode display where 0 turns on a segment.)
  reg [6:0] seg_temp;
  always @(*) begin
      case (digit)
          4'd0: seg_temp = 7'b1000000;
          4'd1: seg_temp = 7'b1111001;
          4'd2: seg_temp = 7'b0100100;
          4'd3: seg_temp = 7'b0110000;
          4'd4: seg_temp = 7'b0011001;
          4'd5: seg_temp = 7'b0010010;
          4'd6: seg_temp = 7'b0000010;
          4'd7: seg_temp = 7'b1111000;
          4'd8: seg_temp = 7'b0000000;
          4'd9: seg_temp = 7'b0010000;
          default: seg_temp = 7'b1111111; // Blank
      endcase
  end
  
  // Drive the segments: if blink is low, blank the display.
  always @(*) begin
      if (blink)
          seg = seg_temp;
      else
          seg = 7'b1111111;
  end
  
  // Anode control: Only the selected digit is active at a time (active low).
  always @(*) begin
      case (digit_sel)
          2'd0: an = 4'b0111;
          2'd1: an = 4'b1011;
          2'd2: an = 4'b1101;
          2'd3: an = 4'b1110;
          default: an = 4'b1111;
      endcase
  end
  
endmodule
