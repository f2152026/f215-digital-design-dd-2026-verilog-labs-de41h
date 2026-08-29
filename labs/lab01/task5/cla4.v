// cla4.v
// (Carried forward from Task 3 / Task 4 -- the same gate-level, delay-annotated
// 4-bit carry-lookahead adder.)
//
// For the bonus task it also exposes two extra outputs -- the BLOCK-level
// generate / propagate summaries of its own bit-level g/p signals:
//
//   gg = "this block generates a carry regardless of its carry-in"
//      = g3 + p3.g2 + p3.p2.g1 + p3.p2.p1.g0
//   gp = "a carry-in sails straight through this block"
//      = p3.p2.p1.p0
//
// The second-level lookahead unit in cla64_hier.v consumes gg/gp from all
// 16 blocks. The block's own cout is still produced (from its real cin) so
// cla4 remains usable standalone, exactly as in Task 3/4.
//
// Every gate carries an explicit delay (#(2)), the default from Task 2 on.

module cla4(
  input  [3:0] a,
  input  [3:0] b,
  input        cin,
  output [3:0] sum,
  output       cout,
  output       gg,     // block generate  (function of this block's g/p only)
  output       gp      // block propagate (function of this block's p only)
);

  wire p0, p1, p2, p3;
  wire g0, g1, g2, g3;
  wire c1, c2, c3;

  // ---- Step 1: bit-level generate / propagate ----
  xor #(2) (p0, a[0], b[0]);
  xor #(2) (p1, a[1], b[1]);
  xor #(2) (p2, a[2], b[2]);
  xor #(2) (p3, a[3], b[3]);

  and #(2) (g0, a[0], b[0]);
  and #(2) (g1, a[1], b[1]);
  and #(2) (g2, a[2], b[2]);
  and #(2) (g3, a[3], b[3]);

  wire t1, t2;
  wire t3, t4, t5;
  wire t6, t7, t8, t9;
  wire t10;

  // ---- Step 2: direct (non-recursive) carry equations ----
  and #(2) (t1, p0, cin);
  or  #(2) (c1, g0, t1);

  and #(2) (t2, p1, g0);
  and #(2) (t3, p1, p0, cin);
  or  #(2) (c2, g1, t2, t3);

  and #(2) (t4, p2, g1);
  and #(2) (t5, p2, p1, g0);
  and #(2) (t6, p2, p1, p0, cin);
  or  #(2) (c3, g2, t4, t5, t6);

  and #(2) (t7,  p3, g2);
  and #(2) (t8,  p3, p2, g1);
  and #(2) (t9,  p3, p2, p1, g0);
  and #(2) (t10, p3, p2, p1, p0, cin);
  or  #(2) (cout, g3, t7, t8, t9, t10);

  // ---- Step 3: sum bits (c0 = cin) ----
  xor #(2) (sum[0], p0, cin);
  xor #(2) (sum[1], p1, c1);
  xor #(2) (sum[2], p2, c2);
  xor #(2) (sum[3], p3, c3);

  // ---- Block-level generate / propagate (independent of cin) ----
  wire h1, h2, h3;
  and #(2) (h1, p3, g2);
  and #(2) (h2, p3, p2, g1);
  and #(2) (h3, p3, p2, p1, g0);
  or  #(2) (gg, g3, h1, h2, h3);

  and #(2) (gp, p3, p2, p1, p0);

endmodule
