// clock_divider.v
// This module divides the 100 MHz master clock into four different clocks:
// - clk_2Hz: for adjusting the stopwatch at 2 Hz (half period = 0.25 sec)
// - clk_1Hz: for normal counting (half period = 0.5 sec)
// - clk_fast: a fast clock for display multiplexing and debouncing (e.g., 200 Hz)
// - clk_blink: for blinking in adjust mode (e.g., 1 Hz blinking)

module clock_divider(
    input  wire clk_100MHz, // 100 MHz master clock
    input  wire reset,      // Synchronous or asynchronous reset
    output reg clk_2Hz,     // 2 Hz clock output
    output reg clk_1Hz,     // 1 Hz clock output
    output reg clk_fast,    // Fast clock (e.g., 200 Hz)
    output reg clk_blink    // Blink clock (e.g., 1 Hz)
);

    // =====================================================
    // Define division parameters (number of master clock cycles for half period)
    // =====================================================
    // For a 2 Hz clock:
    //   Full period = 0.5 sec, so half period = 0.25 sec.
    //   Number of cycles = 100e6 * 0.25 = 25,000,000.
    localparam DIV_2HZ   = 25000000;
    
    // For a 1 Hz clock:
    //   Full period = 1 sec, so half period = 0.5 sec.
    //   Number of cycles = 100e6 * 0.5 = 50,000,000.
    localparam DIV_1HZ   = 50000000;
    
    // For the fast clock:
    //   Example: choose 200 Hz (full period = 1/200 = 0.005 sec, half period = 0.0025 sec).
    //   Number of cycles = 100e6 * 0.0025 = 250,000.
    localparam DIV_FAST  = 250000;
    
    // For the blink clock:
    //   Example: choose 1.6 Hz blinking (half period = 0.3125 sec = 31,250,000 cycles).
    localparam DIV_BLINK = 31250000;

    // =====================================================
    // Declare counters for each divider. (26 bits are sufficient here.)
    // =====================================================
    reg [25:0] counter_2Hz;
    reg [25:0] counter_1Hz;
    reg [25:0] counter_fast;
    reg [25:0] counter_blink;

    // -----------------------------------------------------
    // Divider for 2 Hz clock
    // -----------------------------------------------------
    always @(posedge clk_100MHz or posedge reset) begin
      if (reset) begin
        counter_2Hz <= 26'd0;
        clk_2Hz <= 1'b0;
      end else begin
        if (counter_2Hz >= DIV_2HZ - 1) begin
          counter_2Hz <= 26'd0;
          clk_2Hz <= ~clk_2Hz; // Toggle the 2 Hz clock output.
        end else begin
          counter_2Hz <= counter_2Hz + 1;
        end
      end
    end
    // -----------------------------------------------------
    // Divider for 1 Hz clock
    // -----------------------------------------------------
    always @(posedge clk_100MHz or posedge reset) begin
      if (reset) begin
        counter_1Hz <= 26'd0;
        clk_1Hz <= 1'b0;
      end else begin
        if (counter_1Hz >= DIV_1HZ - 1) begin
          counter_1Hz <= 26'd0;
          clk_1Hz <= ~clk_1Hz;
        end else begin
          counter_1Hz <= counter_1Hz + 1;
        end
      end
    end

    // -----------------------------------------------------
    // Divider for the fast clock (for display multiplexing and debouncing)
    // -----------------------------------------------------
    always @(posedge clk_100MHz or posedge reset) begin
      if (reset) begin
        counter_fast <= 26'd0;
        clk_fast <= 1'b0;
      end else begin
        if (counter_fast >= DIV_FAST - 1) begin
          counter_fast <= 26'd0;
          clk_fast <= ~clk_fast;
        end else begin
          counter_fast <= counter_fast + 1;
        end
      end
    end

    // -----------------------------------------------------
    // Divider for the blink clock (for blinking the selected digit in adjust mode)
    // -----------------------------------------------------
    always @(posedge clk_100MHz or posedge reset) begin
      if (reset) begin
        counter_blink <= 26'd0;
        clk_blink <= 1'b0;
      end else begin
        if (counter_blink >= DIV_BLINK - 1) begin
          counter_blink <= 26'd0;
          clk_blink <= ~clk_blink;
        end else begin
          counter_blink <= counter_blink + 1;
        end
      end
    end

endmodule
