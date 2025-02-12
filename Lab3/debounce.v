// debounce.v
// A simple debouncer using a shift register.
// The button is sampled at the clk rate (≈200 Hz in our design).
module debounce(
    input  wire clk,       // Sampling clock (≈200 Hz)
    input  wire btn_in,    // Raw button input
    output reg  btn_out    // Debounced output
);
    reg [15:0] shift_reg = 16'd0;
    
    always @(posedge clk) begin
        shift_reg <= {shift_reg[14:0], btn_in};
        // When all bits are 1, consider the button pressed.
        if(shift_reg == 16'hFFFF)
            btn_out <= 1;
        else if(shift_reg == 16'h0000)
            btn_out <= 0;
    end
endmodule
