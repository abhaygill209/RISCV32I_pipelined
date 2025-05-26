// pipeline registers -> execute | memory

module pl_reg_em (
    input             clk, en, clr,
    input      [31:0] PCPlus4E, ALUResultE, InstrE, PCE, WriteDataE, lAuiPCE,
    input   RegWriteE,
    input [1:0] ResultSrcE,
    input rowE, MemwriteE,
    output reg [31:0] PCPlus4M, ALUResultM, InstrM, PCM, WriteDataM, lAuiPCM,   
    output reg RegWriteM,
    output reg [1:0] ResultSrcM,
    output reg rowM, MemwriteM
);

initial begin
    PCPlus4M=32'd0;
	 ALUResultM=32'd0;
	 InstrM=32'd0;
	 PCM=32'd0; 
	 WriteDataM=32'd0;
     lAuiPCM=32'd0;
     RegWriteM=0;
     ResultSrcM=2'd0;
     rowM=0; MemwriteM=0;
end

always @(posedge clk) begin
    if (clr) begin
     PCPlus4M=32'd0;
	 ALUResultM=32'd0;
	 InstrM=32'd0;
	 PCM=32'd0;
	 WriteDataM=32'd0;
     lAuiPCM=32'd0;
     RegWriteM=0;
     ResultSrcM=2'd0;
     rowM=0; MemwriteM=0;
    end else if (!en) begin
        PCPlus4M    <= PCPlus4E;
        ALUResultM  <= ALUResultE;
        InstrM      <= InstrE;
        PCM         <= PCE;
        WriteDataM  <= WriteDataE;
        lAuiPCM     <= lAuiPCE;
        RegWriteM   <= RegWriteE;
        ResultSrcM  <= ResultSrcE;
        rowM        <= rowE;
        MemwriteM   <= MemwriteE;
    end
end

endmodule