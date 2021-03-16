module top
 (
   // Internal clock from FPGA
   input wire CLK,
   // From the photoresistor and op amp receiver signal
   input wire i_ReceivedSignal,
   // Shows Number of bits that failed.
   output wire o_BER_1, // PIN_1
   output wire o_BER_2, // PIN_2
   output wire o_BER_3, // PIN_3
   output wire o_BER_4, // PIN_4
   output wire o_BER_5, // PIN_5
   output wire o_BER_6, // PIN_6
   output wire o_BER_7, // PIN_7
   output wire o_BER_8, // PIN_8
   output wire o_BER_9, // PIN_9
   output wire o_BER_10, // PIN_10
   // For debugging and reading whats going on with a digital analizer.
   output wire PIN_12,
   output wire PIN_15,
   output wire PIN_16,
   output wire PIN_17,
   output wire PIN_18,
   output wire PIN_19,
   output wire PIN_20,
   output wire PIN_21,
   output wire PIN_22,
   output wire PIN_23,
   output wire PIN_24,
   // What s sent to the Lazer to be transmitted
   output wire o_PRBS,
  );

  // drive USB pull-up resistor to '0' to disable USB
  assign USBPU = 0;

  // Change this to set the rate of transmission, e.g 1Mhz = 1Mbps.
  parameter BPS = 1; // Hz
  // parameter PHASE = 16;

  /* Slower clock given by the ReduceCLK_0 module. Frequency given by parameter
  BPS */
  wire w_ReduceCLK;
  /* High if i_ReceivedSignal does not equal o_PRBS meaning the receiver has
  failed to identify the correct state of the lazer. */
  wire w_Error;
   /* High if i_ReceivedSignal equals o_PRBS meaning the receiver has
  identify the correct state of the lazer. */
  wire w_Match;

  // reg r_SampleCLK;
  // reg [5:0]r_PhaseCounter = 6'b000000; // min w_ReduceCLK speed is 125kHz means r_PhaseCounter counts to 128 every 125kHz cycle


  reg r_Complete = 0;   // indicates the program has finished counting
  reg [9:0] r_Shift = 10'b0000000001; // Used in LFSR
  // Stores the number of matches between i_ReceivedSignal and o_PRBS.
  reg [12:0] r_MatchCounter = 13'b0000000000000;
  // Stores the number of times i_ReceivedSignal and o_PRBS dont match.
  reg [12:0] r_ErrorCounter = 13'b0000000000000;
  // When the program has finished it stored the number of miss matched bits.
  reg [13:0] r_TotalErrors = 14'b00000000000000;
  // Keeps a tally of all bits sent by counting the errors and the matches.
  reg [13:0] r_AddMatchError = 14'b00000000000000;


  ReduceCLK #(.MODULE_BPS(BPS)) ReduceCLK_0(.i_CLK(CLK), .o_RedusedCLK(w_ReduceCLK));


  // always @ (posedge w_ReduceCLK)
  // begin
  //   r_PhaseCounter <= 0;
  // end
  //
  // always @ (posedge CLK)
  // begin
  //   r_PhaseCounter <= r_PhaseCounter + 1;
  //
  //   if (r_PhaseCounter < PHASE)
  //     r_SampleCLK <= 0;
  //   else if (r_PhaseCounter >= PHASE)
  //     r_SampleCLK <= 1;
  //
  // end

  // ---- SHIFT REGISTER for PRBS ----
  always @(posedge w_ReduceCLK)
  begin
      r_Shift <= r_Shift << 1;
      r_Shift[0] <= r_Shift[6] ^ r_Shift[9];
  end

  always @(negedge w_ReduceCLK)
  begin
    // ----- BER -----
    /* Counts Errors and matches then adds them together to get the total bits
    sent, number of errors and number of matches in three variables. */
    if (w_Match == 1)
      r_MatchCounter = r_MatchCounter + 1;

    else if (w_Error == 1)
      r_ErrorCounter = r_ErrorCounter + 1;

    r_AddMatchError = r_MatchCounter + r_ErrorCounter;
  end

  always @(negedge w_ReduceCLK)
  begin
    // ----- COMPLETETION / ADD TOTAL -----
    /* Because its a 10 bit LFSR, at (2^10)-1 OR 1023 bits the PRBS finishes and
    then starts a second repetition, so at 1023 bits the full PRBS has ran. */
    if ((r_AddMatchError == 1023) && (r_Complete == 0))
    begin
      r_TotalErrors = r_ErrorCounter;
      r_Complete = 1;
    end
  end

  // ----- COMPATATOR -----
  assign w_Match = ~(i_ReceivedSignal ^ o_PRBS);
  assign w_Error = (i_ReceivedSignal ^ o_PRBS);

  assign o_PRBS = r_Shift[9];

  //assign PIN_12 = w_ReduceCLK;
  assign PIN_12 = r_Shift[9];
  // assign PIN_17 = w_Comp;
  // assign PIN_18 = r_SampleCLK;
  // assign PIN_19 = r_shift[1];
  // assign PIN_20 = r_shift[2];
  assign PIN_21 = w_Match;
  assign PIN_22 = w_Error;
  assign PIN_23 = r_Complete;
  assign PIN_24 = i_ReceivedSignal;

  assign {o_BER_10, o_BER_9, o_BER_8, o_BER_7, o_BER_6, o_BER_5, o_BER_4, o_BER_3, o_BER_2, o_BER_1} = r_TotalErrors;

endmodule // top

/* Takes the internal clock from the FPGA that runs at 16MHz and slows it down
by counting the internal clock to (internal clock/desired frequency) and then
fliping its state repeatedly, creating a new clock. */
module ReduceCLK #(parameter MODULE_BPS = 16000000)
    (
    input wire i_CLK,
    output reg o_RedusedCLK
    );

    reg [23:0]  r_ReduceCLK = 24'b000000000000000000000000;
    reg [23:0]  r_ClkLimit = 16000000/MODULE_BPS;

    always @(posedge i_CLK)
    begin

      if (r_ReduceCLK < r_ClkLimit)
        r_ReduceCLK <= r_ReduceCLK + 1;
      else if (r_ReduceCLK >= r_ClkLimit)
        r_ReduceCLK <= 24'b000000000000000000000000;

      if (r_ReduceCLK < (r_ClkLimit/2))
        o_RedusedCLK <= 1;
      else if(r_ReduceCLK >= (r_ClkLimit/2))
        o_RedusedCLK <= 0;

    end

endmodule // ReduceCLK
