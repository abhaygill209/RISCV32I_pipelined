// pipeline registers -> decode | execute

module pl_reg_de (
    input             clk, en, clr,
    input      [31:0] PCPlus4D, InstrD, PCD, 
    input      [31:0] SrcAD, WriteDataD, SignImmD,
    input      ALUSrcD, sralD, RegWriteD,
    input      [2:0] ALUControlD,
    input      [1:0] ResultSrcD,
    input      BranchD, JumpD, JalrD, rowD, MemWriteD,
    output reg [31:0] PCPlus4E, InstrE, PCE, 
    output reg [31:0] SrcAE, WriteDataE, SignImmE,
    output reg ALUSrcE, sralE, RegWriteE, 
    output reg [2:0] ALUControlE,
    output reg [1:0] ResultSrcE,
    output reg BranchE, JumpE, JalrE, rowE, MemwriteE
); 

initial begin
     PCPlus4E=32'd0;
	 InstrE=32'd0;
	 PCE=32'd0;
	 SrcAE=32'd0; 
	 WriteDataE=32'd0;
	 SignImmE=32'd0;
     ALUSrcE=0; sralE=0; RegWriteE=0; ALUControlE=3'd0; ResultSrcE=2'd0;
     BranchE=0; JumpE=0; JalrE=0; rowE=0; MemwriteE=0;
end

always @(posedge clk) begin
    if (clr) begin
     PCPlus4E=32'd0;
	 InstrE=32'd0;
	 PCE=32'd0;
	 SrcAE=32'd0; 
	 WriteDataE=32'd0;
	 SignImmE=32'd0;
     ALUSrcE=0; sralE=0; RegWriteE=0; ALUControlE=3'd0; ResultSrcE=2'd0;
     BranchE=0; JumpE=0; JalrE=0; rowE=0; MemwriteE=0;
    end 
    else if (!en) begin
        InstrE <= InstrD;
        PCPlus4E <= PCPlus4D;
        PCE      <= PCD;
        SrcAE    <= SrcAD; 
        WriteDataE    <= WriteDataD; 
        SignImmE <= SignImmD;
        ALUSrcE  <= ALUSrcD;
        sralE       <= sralD;
        RegWriteE   <= RegWriteD;
        ALUControlE <= ALUControlD;
        ResultSrcE  <= ResultSrcD;
        BranchE     <= BranchD;
        JumpE       <= JumpD;
        JalrE       <= JalrD;
        rowE        <= rowD;
        MemwriteE   <= MemWriteD;
    end
end

endmodule