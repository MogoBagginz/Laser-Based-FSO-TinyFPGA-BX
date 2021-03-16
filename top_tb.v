// top_tb.v

`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module top_tb;

    reg i_CLK;
    reg i_ReceivedSignal;
    wire o_PRBS;

    // duration for each bit = 20 * timescale = 20 * 1 ns  = 20ns
    localparam period = 20;

    top UUT (.CLK(i_CLK), .i_ReceivedSignal(i_ReceivedSignal), .o_PRBS(o_PRBS));

always
begin
    i_CLK = 1'b1;
    #1
    i_CLK = 1'b0;
    #1
    $stop;
end

always @(posedge i_CLK)
begin
  i_ReceivedSignal <= 1'b0;
  #(period * 50);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b1;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b1;
  #(period * 100);
  i_ReceivedSignal <= 1'b1;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b1;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  i_ReceivedSignal <= 1'b1;
  #(period * 100);
  i_ReceivedSignal <= 1'b0;
  #(period * 100);
  $stop;
end

// Sets up things for apio specificly
initial begin
  $dumpfile("top_tb.vcd");
  $dumpvars(0, top_tb);
  #(period * 4096) $display("End of simulation");
  $finish;
end

endmodule
