// lut.v
// A small parameterized ROM (lookup table): DEPTH words, each WIDTH bits
// wide. dout continuously reflects mem[sel].

module lut #(
  parameter WIDTH = 8,
  parameter DEPTH = 4
) (
  input      [$clog2(DEPTH)-1:0] sel,
  output reg [WIDTH-1:0]         dout
);

  reg [WIDTH-1:0] mem [0:DEPTH-1];

  integer i;

  initial begin
    for (i = 0; i < DEPTH; i = i + 1) begin
      mem[i] = i * i;
    end
  end

  always @(*) begin
    dout = mem[sel];
  end

endmodule