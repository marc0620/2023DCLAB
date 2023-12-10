module keyboard_decoder_tb;

  // Inputs
  reg i_clk_100k;
  reg i_rst_n;
  reg PS2_CLK;
  reg PS2_DAT;

  // Outputs
  wire [31:0] o_key;

  // Instantiate the module
  keyboard_decoder uut (
    .i_clk_100k(i_clk_100k),
    .PS2_CLK(PS2_CLK),
    .i_rst_n(i_rst_n),
    .PS2_DAT(PS2_DAT),
    .o_key(o_key)
  );

  // Clock generation
  initial begin
    i_clk_100k = 0;
    forever #5 i_clk_100k = ~i_clk_100k;
  end

  // Reset generation
  initial begin
    i_rst_n = 0;
    #10 i_rst_n = 1;
  end

  // Test scenario
  initial begin
    // Assuming PS/2 protocol, you might want to create a sequence of clock and data changes
    // for your simulation. For simplicity, you can manually toggle PS2_CLK and PS2_DAT here.

    // Example sequence: Start bit, data bits (LSB first), parity bit, stop bit
    PS2_CLK = 1;
    PS2_DAT = 1;
    #10 PS2_CLK = 0;
    #10 PS2_CLK = 1;
    #10 PS2_DAT = 0; // Data bit 0
    #10 PS2_DAT = 1; // Data bit 1
    #10 PS2_DAT = 0; // Data bit 2
    #10 PS2_DAT = 1; // Data bit 3
    #10 PS2_DAT = 0; // Data bit 4
    #10 PS2_DAT = 1; // Data bit 5
    #10 PS2_DAT = 0; // Data bit 6
    #10 PS2_DAT = 1; // Data bit 7
    #10 PS2_DAT = 1; // Parity bit
    #10 PS2_DAT = 1; // Stop bit

    // Add more test scenarios as needed

    #100 $stop; // Stop the simulation after some time
  end

endmodule