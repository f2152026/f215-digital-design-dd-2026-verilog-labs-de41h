module and_df (
  input  a,
  input  b,
  output y
);

  assign #1 y = a & b;

endmodule