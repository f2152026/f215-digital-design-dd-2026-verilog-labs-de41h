module tb;

  reg  [1:0] t_a;
  reg  [1:0] t_b;

  wire t_gt;
  wire t_lt;
  wire t_eq;

  reg exp_gt;
  reg exp_lt;
  reg exp_eq;

  integer errors;
  integer total;
  integer passed;
  integer i;

  // Device Under Test
  comp2 DUT (
    .A  (t_a),
    .B  (t_b),
    .GT (t_gt),
    .LT (t_lt),
    .EQ (t_eq)
  );

  initial begin
    errors = 0;
    total = 0;

    // Test all 16 combinations of A and B
    for (i = 0; i < 16; i = i + 1) begin

      t_a = i[3:2];
      t_b = i[1:0];

      // Calculate expected result independently
      if (t_a > t_b) begin
        exp_gt = 1;
        exp_lt = 0;
        exp_eq = 0;
      end
      else if (t_a < t_b) begin
        exp_gt = 0;
        exp_lt = 1;
        exp_eq = 0;
      end
      else begin
        exp_gt = 0;
        exp_lt = 0;
        exp_eq = 1;
      end

      #10;

      // Compare actual vs expected
      if ({t_gt, t_lt, t_eq} !== {exp_gt, exp_lt, exp_eq}) begin
        $display(
          "FAIL at time %0t: A=%b B=%b  got GT=%b LT=%b EQ=%b  expected GT=%b LT=%b EQ=%b",
          $time, t_a, t_b,
          t_gt, t_lt, t_eq,
          exp_gt, exp_lt, exp_eq
        );
        errors = errors + 1;
      end

      total = total + 1;
    end

    passed = total - errors;

    $display("--------------------------------");
    $display("SUMMARY: %0d/%0d tests passed, %0d failed",
             passed, total, errors);
    $display("--------------------------------");

    $finish;
  end

endmodule