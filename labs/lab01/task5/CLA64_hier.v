// cla64_hier.v
// BONUS -- the O(log n) adder.
//
// Task 4(b) (cla64_blocked) chains 16 four-bit CLA blocks by rippling each
// block's carry-out into the next block's carry-in: 16 blocks in series, so
// the block-carry path is still O(n) in the number of blocks.
//
// Here we apply the generate/propagate trick a second (and third) time, to
// the blocks THEMSELVES -- exactly the scheme from Tutorial 3, Q4(d):
//
//   Level 1 : 16 x cla4  -- each block also exports gg_k / gp_k, the
//             block-level generate / propagate (see cla4.v). Its sum bits
//             are produced from its own carry-in, which we now hand it
//             directly instead of rippling.
//
//   Level 2 : 4 x lcu4   -- one lookahead unit per GROUP of 4 blocks.
//             From the 4 (gg,gp) pairs of its group and the group's
//             carry-in it computes the carry-in of blocks 1..3 of the
//             group directly, and exports a group-level (GG,GP) summary.
//
//   Level 3 : 1 x lcu4   -- from the 4 group summaries and cin it computes
//             each group's carry-in directly. Its own (GG,GP) is the
//             generate/propagate of the whole 64-bit adder, from which the
//             final cout is one AND + one OR.
//
// Carry path is now ~3 lookahead levels deep instead of 16 -- O(log n).
// Every gate carries an explicit delay, as everywhere from Task 2 on.

// ---------------------------------------------------------------------------
// lcu4 -- a 4-input lookahead carry unit. Structurally identical to the
// carry logic inside cla4, just one level up: the inputs are (generate,
// propagate) pairs rather than raw bits, and instead of a sum it exports a
// group-level (gg,gp) so the same unit can be stacked recursively.
//
//   c1 = g0 + p0.cin
//   c2 = g1 + p1.g0 + p1.p0.cin
//   c3 = g2 + p2.g1 + p2.p1.g0 + p2.p1.p0.cin
//   gg = g3 + p3.g2 + p3.p2.g1 + p3.p2.p1.g0
//   gp = p3.p2.p1.p0
// ---------------------------------------------------------------------------
module lcu4(
  input  [3:0] g,
  input  [3:0] p,
  input        cin,
  output       c1,
  output       c2,
  output       c3,
  output       gg,
  output       gp
);

  wire a1;
  and #(2) (a1, p[0], cin);
  or  #(2) (c1, g[0], a1);

  wire b1, b2;
  and #(2) (b1, p[1], g[0]);
  and #(2) (b2, p[1], p[0], cin);
  or  #(2) (c2, g[1], b1, b2);

  wire d1, d2, d3;
  and #(2) (d1, p[2], g[1]);
  and #(2) (d2, p[2], p[1], g[0]);
  and #(2) (d3, p[2], p[1], p[0], cin);
  or  #(2) (c3, g[2], d1, d2, d3);

  wire e1, e2, e3;
  and #(2) (e1, p[3], g[2]);
  and #(2) (e2, p[3], p[2], g[1]);
  and #(2) (e3, p[3], p[2], p[1], g[0]);
  or  #(2) (gg, g[3], e1, e2, e3);

  and #(2) (gp, p[3], p[2], p[1], p[0]);

endmodule


module cla64_hier(
  input  [63:0] a,
  input  [63:0] b,
  input         cin,
  output [63:0] sum,
  output        cout
);

  // Block-level generate / propagate, one bit per 4-bit block.
  wire [15:0] bg, bp;
  // Carry-in of each of the 16 blocks (bcin[0] == cin).
  wire [15:0] bcin;

  // Group-level (4 blocks per group) generate / propagate and carry-in.
  wire [3:0]  gg, gp;
  wire [3:0]  gcin;              // gcin[0] == cin

  // ---- Level 3: one lookahead unit over the 4 groups ----
  wire ggg, ggp;                 // generate / propagate of the whole adder
  lcu4 L3 (
    .g   (gg),
    .p   (gp),
    .cin (cin),
    .c1  (gcin[1]),
    .c2  (gcin[2]),
    .c3  (gcin[3]),
    .gg  (ggg),
    .gp  (ggp)
  );
  buf #(1) (gcin[0], cin);

  // Final carry-out: cout = ggg + ggp.cin
  wire ct;
  and #(2) (ct, ggp, cin);
  or  #(2) (cout, ggg, ct);

  // ---- Level 2: one lookahead unit per group of 4 blocks ----
  genvar j;
  generate
    for (j = 0; j < 4; j = j + 1) begin : grp
      lcu4 L2 (
        .g   (bg[4*j+3 : 4*j]),
        .p   (bp[4*j+3 : 4*j]),
        .cin (gcin[j]),
        .c1  (bcin[4*j+1]),
        .c2  (bcin[4*j+2]),
        .c3  (bcin[4*j+3]),
        .gg  (gg[j]),
        .gp  (gp[j])
      );
      // First block of each group takes the group carry-in directly.
      buf #(1) (bcin[4*j], gcin[j]);
    end
  endgenerate

  // ---- Level 1: the 16 four-bit CLA blocks ----
  genvar k;
  generate
    for (k = 0; k < 16; k = k + 1) begin : blk
      cla4 B (
        .a    (a[4*k+3 : 4*k]),
        .b    (b[4*k+3 : 4*k]),
        .cin  (bcin[k]),
        .sum  (sum[4*k+3 : 4*k]),
        .cout (),
        .gg   (bg[k]),
        .gp   (bp[k])
      );
    end
  endgenerate

endmodule
