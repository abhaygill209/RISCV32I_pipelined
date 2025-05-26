module Subtractor (
    input  wire signed [31:0] A,      // Minuend
    input  wire signed [31:0] B,      // Subtrahend
    output wire signed [31:0] Diff,   // Difference (A - B)
    output wire               Overflow // Overflow flag
);

    assign Diff = A - B;

    // Overflow detection for signed subtraction
    assign Overflow = ((A[31] != B[31]) && (Diff[31] != A[31]));

endmodule
