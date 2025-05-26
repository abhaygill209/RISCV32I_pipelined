
// alu.v - ALU module

module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,       // operands
    input       [2:0] alu_ctrl,         // ALU control
    input       sral,                   // control
    output reg  [WIDTH-1:0] alu_out,    // ALU output
    output      zero                   // zero flag
);

always @(a, b, alu_ctrl, sral) begin
    case (alu_ctrl)
        3'b000: begin
             if (sral) alu_out <= a - b;   //sub 
             else      alu_out <= a + b; //add //addis
        end 
        3'b001: alu_out <= a << b;  //sll
        3'b010: alu_out <= a & b;   //and 
        3'b011: alu_out <= a | b;   //or
        3'b100: alu_out <= a < b ? 1 : 0; //sltu
        3'b110: alu_out <= a ^ b;   //xor 
        3'b111: begin
          if (sral) alu_out <= a >> b; //srl
          else alu_out <= $signed($signed(a) >>> b);//sra
        end 
        3'b101:  begin                 // slt
                     if (a[31] != b[31]) alu_out <= a[31] ? 1 : 0;
                     else alu_out <= a < b ? 1 : 0;
                 end
        default: alu_out <= 32'd0;
    endcase
end

assign zero = (alu_out == 0) ? 1'b1 : 1'b0;

endmodule

/*
    0 -> addition for lw, sw, 
    1 -> subtraction for none for now 
    2 -> sll
    3 -> or operation
    4 -> set less than unsigned 
    5 -> set less than 
    6 -> xor 
    7 -> sra and sal
        -> 1 -> srl
        -> 0 -> sra
    
    A give a new wire form ALU to the Control logic for SRA and SRL instructions 
*/