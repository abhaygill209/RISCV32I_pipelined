
// alu_decoder.v - logic for ALU decoder

module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [2:0] ALUControl,
    output reg       sral //sra or srl 
);




////new ALU/////

always @(*) begin
    case (ALUOp)
        2'b00: begin
            ALUControl = 3'b000; // addition
            sral = 1'b0;
        end             
        2'b01: begin 
            case (funct3)
                3'b111: ALUControl = 3'b100;
                3'b110: ALUControl = 3'b100;
                default: begin
                    ALUControl = 3'b000; // subtraction
                    sral = 1'b1;
                end
            endcase
        end
        default:
            case (funct3) // R-type or I-type ALU
                3'b000: begin
                    // True for R-type subtract
                    ALUControl = 3'b000;
                    if   (funct7b5 & opb5) sral = 1'b1; //sub
                    else sral = 1'b0; // add, addi
                end
                3'b001:  ALUControl = 3'b001; // sll, slli
                3'b010:  ALUControl = 3'b101; // slt, slti
                3'b011:  ALUControl = 3'b100; // sltu, sltui
                3'b100:  ALUControl = 3'b110; // xor
                3'b101:  begin 
                    ALUControl = 3'b111;
                    if   (funct7b5) sral = 1'b0; //sra
                    else sral = 1'b1;  //srl
                end 
                3'b110:  ALUControl = 3'b011; // or, ori
                3'b111:  ALUControl = 3'b010; // and, andi
                default: ALUControl = 3'bxxx; // ???
            endcase
    endcase
end

endmodule

/*
    0 -> addition for lw, sw, sral -> 0
    0 -> subtraction for none for now sral -> 1
    1 -> rs1 << rs2
    3 -> or operation
    4 -> set less than unsigned 
    5 -> set less than 
    6 -> xor 
    7 -> sra and sal
        -> 1 -> srl
        -> 0 -> sra

    we can also add a negitive sign representing the things involving negitive numbers
    
    A give a new wire form ALU to the Control logic for SRA and SRL instructions 
*/

