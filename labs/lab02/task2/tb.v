module tb;

  // Inputs and outputs
  reg  [2:0] t_sel;
  wire [7:0] t_dout;

  // Instantiate DUT with parameter override
  lut #(.WIDTH(8), .DEPTH(8)) DUT (
    .sel  (t_sel),
    .dout (t_dout)
  );

  // Waveform dump configuration (DO NOT CHANGE)
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  initial begin
    // Test every valid address
    for (integer i = 0; i < 8; i = i + 1) begin
      t_sel = i;
      #10;

      if (t_dout !== i * i)
        $display("ERROR: sel=%0d, expected=%0d, got=%0d",
                 i, i * i, t_dout);
      else
        $display("PASS: sel=%0d, dout=%0d", i, t_dout);
    end

    $finish;
  end

  initial
    $monitor($time, " SEL=%b | DOUT=%d", t_sel, t_dout);

endmodule