// pipeline registers -> memory | writeback 

module pl_reg_mw (
    input             clk, en, clr,
    input      [31:0] PCPlus4M, WriteDataM, ALUResultM, InstrM, PCM, ReadDataM, lAuiPCM, 
    input      RegWriteM,
    input      [1:0] ResultSrcM,
    output reg [31:0] PCPlus4W, WriteDataW, ALUResultW, InstrW, PCW, ReadDataW, lAuiPCW,
    output reg RegWriteW,
    output reg [1:0] ResultSrcW
);

initial begin
    PCPlus4W=32'd0;
	 WriteDataW=32'd0;
	 ALUResultW=32'd0;
	 InstrW=32'd0;
	 PCW=32'd0;
	 ReadDataW=32'd0;
     lAuiPCW=32'd0;
     RegWriteW=0;
     ResultSrcW=2'd0;
end

always @(posedge clk) begin
    if (clr) begin
        PCPlus4W=32'd0;
	    WriteDataW=32'd0;
	    ALUResultW=32'd0;
	    InstrW=32'd0;
	    PCW=32'd0;
	    ReadDataW=32'd0;
        lAuiPCW=32'd0;
        RegWriteW=0;
        ResultSrcW=2'd0;
    end else if (!en) begin
        PCPlus4W    <= PCPlus4M;
        WriteDataW  <= WriteDataM;
        ALUResultW  <= ALUResultM;
        InstrW      <= InstrM;
        PCW         <= PCM;
        ReadDataW   <= ReadDataM; 
        lAuiPCW     <= lAuiPCM;
        RegWriteW   <= RegWriteM;
        ResultSrcW  <= ResultSrcM;
    end
end

endmodule