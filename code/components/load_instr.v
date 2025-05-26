module load_instr (
    input [31:0] ReadData,
    input [1:0] load,
    output reg [31:0] ReadDatap
);

always @(*) begin
    case(load)
        2'b00: ReadDatap <= {{24{ReadData[7]}}, ReadData[7:0]}; 
        2'b01: ReadDatap <= {{16{ReadData[15]}}, ReadData[15:0]}; 
        2'b10: ReadDatap <= ReadData;
        default: ReadDatap <= ReadData; 
    endcase
end
    
endmodule