module tb;

  reg [3:0] t_a;
  reg [3:0] t_b;
  reg       t_op;

  wire [3:0] t_result;

  reg [3:0] expected;
  integer errors;
  integer total;
  integer i;

  // Device Under Test
  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  initial begin
    errors = 0;
    total = 0;

    // Test both operations with fixed operands
    t_a = 7;
    t_b = 3;

    // ADD
    t_op = 0;
    #1;

    expected = t_a + t_b;

    if (t_result !== expected) begin
      $display("FAIL: A=%d B=%d OP=ADD | got=%d expected=%d",
               t_a, t_b, t_result, expected);
      errors = errors + 1;
    end
    else begin
      $display("PASS: A=%d B=%d OP=ADD | result=%d",
               t_a, t_b, t_result);
    end
    total = total + 1;

    // SUB
    t_op = 1;
    #1;

    expected = t_a - t_b;

    if (t_result !== expected) begin
      $display("FAIL: A=%d B=%d OP=SUB | got=%d expected=%d",
               t_a, t_b, t_result, expected);
      errors = errors + 1;
    end
    else begin
      $display("PASS: A=%d B=%d OP=SUB | result=%d",
               t_a, t_b, t_result);
    end
    total = total + 1;


    // Test multiple changing operands
    for (i = 0; i < 16; i = i + 1) begin
      t_a = i;
      t_b = 15 - i;

      // ADD
      t_op = 0;
      #1;

      expected = t_a + t_b;

      if (t_result !== expected) begin
        $display("FAIL: A=%d B=%d OP=ADD | got=%d expected=%d",
                 t_a, t_b, t_result, expected);
        errors = errors + 1;
      end
      else begin
        $display("PASS: A=%d B=%d OP=ADD | result=%d",
                 t_a, t_b, t_result);
      end
      total = total + 1;

      // SUB
      t_op = 1;
      #1;

      expected = t_a - t_b;

      if (t_result !== expected) begin
        $display("FAIL: A=%d B=%d OP=SUB | got=%d expected=%d",
                 t_a, t_b, t_result, expected);
        errors = errors + 1;
      end
      else begin
        $display("PASS: A=%d B=%d OP=SUB | result=%d",
                 t_a, t_b, t_result);
      end
      total = total + 1;
    end

    $display("--------------------------------");
    $display("SUMMARY: %0d/%0d passed, %0d failed",
             total - errors, total, errors);
    $display("--------------------------------");

    $finish;
  end

endmodule