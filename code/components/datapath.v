
// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrcD,
    input         ALUSrcD, RegWriteD,
    input [1:0]   ImmSrc,
    input [2:0]   ALUControlD,
    input         BranchD, JumpD, JalrD, sralD,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadDataM,
    output [31:0] ResultW,
    output [31:0] PCW, ALUResultW, WriteDataW,
    output [31:0] InstrD, InstrW,
    output [2:0] funct3M,

    //for debuging purpose 
    output [31:0] PCPlus4W, PCNext, PCJalr, PCPlus4, InstrM, PCM, WriteDataM,
    output [31:0] PCD, ImmExtD, PCTargetE, SrcAD, WriteDataE, PCPlus4D,
    output [31:0] WriteDataD, ImmExtE, SrcB , ALUResultE, InstrE, PCE, AuiPCE,
    output [31:0] lAuiPCE, ReadDataW, lAuiPCW, PCPlus4E, SrcAE, PCPlus4M, ALUResultM, lAuiPCM,
    output JalrE, ALUSrcE, sralE, ZeroE, TakeBranchE, RegWriteE, RegWriteM, RegWriteW, JumpE, BranchE,
    output [1:0] ResultSrcE, ResultSrcM, ResultSrcW,
    output [2:0] ALUControlE,
    input MemWriteD,
    output MemwriteM
);

// wire [31:0] PCPlus4W, PCTargetM, PCNext, PCJalr, PCPlus4, InstrM, PCM, WriteDataM;
// wire [31:0] PCD, ImmExtD, PCTargetE, SrcAD, WriteDataE, PCPlus4D;
// wire [31:0] WriteDataD, ImmExtE, SrcB , ALUResultE, InstrE, PCE, AuiPCE;
// wire [31:0] lAuiPCE, ReadDataW, lAuiPCW, PCPlus4E, SrcAE, PCPlus4M, ALUResultM, lAuiPCM;
// wire JalrE, ALUSrcE, sralE, ZeroE, TakeBranchE, RegWriteE, RegWriteM, RegWriteW, JumpE, BranchE, rowE, rowM, BorrowE;
// wire [1:0] ResultSrcE, ResultSrcM, ResultSrcW;
// wire [2:0] ALUControlE;
wire MemwriteE;

wire PCSrc;
assign PCSrc = ((BranchE && TakeBranchE) || JumpE || JalrE) ? 1'b1 : 1'b0;

// next PC logic
mux2 #(32)     pcmux(PCPlus4, PCTargetE, PCSrc, PCNext);
mux2 #(32)     jalrmux (PCNext, ALUResultE, JalrE, PCJalr);

// stallF - should be wired from hazard unit
wire StallF;
assign StallF = 0; // remove it after adding hazard unit.

reset_ff #(32) pcreg(clk, reset, StallF, PCJalr, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);

// Pipeline Register 1 -> Fetch | Decode

wire FlushD, StallD;
// FlushD - should be wired from hazard unit
pl_reg_fd plfd (clk, StallD, FlushD, 
                Instr, PC, PCPlus4, 
                InstrD, PCD, PCPlus4D);

wire [31:0] src_a, src_b;
adder          pcaddbranch(PCE, ImmExtE, PCTargetE);
reg_file       rf (clk, RegWriteW, InstrD[19:15], InstrD[24:20], InstrW[11:7], ResultW, src_a, src_b);
imm_extend     ext (InstrD[31:7], ImmSrc, ImmExtD);
wire [1:0] regAD, regBD; 
mux4 #(32)     rega(.d0(src_a), .d1(ResultW), .sel(regAD), .y(SrcAD));
mux4 #(32)     regb(.d0(src_b), .d1(ResultW), .sel(regBD), .y(WriteDataD));

// Pipeline Register 2 -> Decode | Execute
wire FlushE, StallE;
pl_reg_de plde(clk, StallE, FlushE, 
             PCPlus4D, InstrD, PCD, SrcAD, WriteDataD, ImmExtD, ALUSrcD, sralD, RegWriteD, ALUControlD,  
             ResultSrcD, BranchD, JumpD, JalrD, MemWriteD,
             PCPlus4E, InstrE, PCE, SrcAE, WriteDataE, ImmExtE, ALUSrcE, sralE, RegWriteE, ALUControlE,  
             ResultSrcE, BranchE, JumpE, JalrE, MemwriteE); 

// ALU logic
mux2 #(32)     srcbmux(WriteDataE, ImmExtE, ALUSrcE, SrcB);

wire [31:0] SRCA, SRCB, pcforward;
wire [1:0] srcA_con, srcB_con;
wire pc_fwd_sel;
//from hazard control unit 
mux4 #(32)     sra(SrcAE, ALUResultM, ResultW, pcforward, srcA_con, SRCA);
mux4 #(32)     srb(SrcB , ALUResultM, ResultW, pcforward, srcB_con, SRCB);
mux2 #(32)     pcfrwd(.d0(PCPlus4M), .d1(lAuiPCM), .sel(pc_fwd_sel), .y(pcforward));

alu            alu (SRCA, SRCB, ALUControlE, sralE, ALUResultE, ZeroE);
adder #(32)    auipcadder ({InstrE[31:12], 12'b0}, PCE, AuiPCE);
mux2 #(32)     lauipcmux (AuiPCE, {InstrE[31:12], 12'b0}, InstrE[5], lAuiPCE);
branching_unit bu (InstrE[14:12], ZeroE, ALUResultE[0], ALUResultE[31], TakeBranchE);

// Pipeline Register 3 -> Execute | Memory
wire FlushM, StallM;
pl_reg_em plem(clk, StallM, FlushM, 
               PCPlus4E, ALUResultE, InstrE, PCE, WriteDataE, lAuiPCE, RegWriteE,
               ResultSrcE, MemwriteE,
               PCPlus4M, ALUResultM, InstrM, PCM, WriteDataM, lAuiPCM, RegWriteM,
               ResultSrcM, MemwriteM);


// Pipeline Register 4 -> Memory | Writeback (Register file) 
wire FlushW, StallW;
pl_reg_mw plmw(clk, StallW, FlushW, 
               PCPlus4M, WriteDataM, ALUResultM, InstrM, PCM, ReadDataM, lAuiPCM, RegWriteM,
               ResultSrcM,
               PCPlus4W, WriteDataW, ALUResultW, InstrW, PCW, ReadDataW, lAuiPCW, RegWriteW,
               ResultSrcW);

// Result Source
mux4 #(32)     resultmux(ALUResultW, ReadDataW, PCPlus4W, lAuiPCW, ResultSrcW, ResultW);

// hazard units

//Structural Hazard. 
    //if memory is being accessed for read and write simultaneously then ? 

hazard_control hc(.InstrD(InstrD), .InstrE(InstrE), .InstrM(InstrM), .InstrW(InstrW),
                  .RegWriteM(RegWriteM), .RegWriteW(RegWriteW), .PCSrc(PCSrc),
                  .srcAE(srcA_con), .srcBE(srcB_con) , .regAD(regAD), .regBD(regBD),
                  .pc_fwd_sel(pc_fwd_sel), .FlushD(FlushD), .FlushE(FlushE), .FlushM(FlushM), .FlushW(FlushW),
                  .StallF(StallF), .StallD(StallD), .StallE(StallE), .StallM(StallM), .StallW(StallW));

//////////////////////////////////////////////

// Reading from memory 
assign Mem_WrAddr = ALUResultM;
assign Mem_WrData = WriteDataM;
assign funct3M    = InstrM[14:12];

// eventually this statements will be removed while adding pipeline registers
// assign PCW = PC;
// assign ALUResultW = ALUResult;
// assign WriteDataW = WriteData;

endmodule



///////////////////KEY POINTS///////////////////////////
/*
    1. breanching or jump instructions are completed in executive stage only. 
    2. 


*/
