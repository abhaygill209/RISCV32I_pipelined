
// riscv_cpu.v - single-cycle RISC-V CPU Processor

module riscv_cpu (
    input         clk, reset,
    output [31:0] PC,
    input  [31:0] Instr,
    output        MemWriteM,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result,
    output [ 2:0] funct3,
    output [31:0] PCW, ALUResultW, WriteDataW,
    output [31:0] PCPlus4W, PCTargetM, PCNext, PCJalr, PCPlus4, InstrM, PCM, WriteDataM,
    output [31:0] PCD, ImmExtD, PCTargetE, SrcAD, WriteDataE, PCPlus4D,
    output [31:0] WriteDataD, ImmExtE, SrcB , ALUResultE, InstrE, PCE, AuiPCE,
    output [31:0] lAuiPCE, ReadDataW, lAuiPCW, PCPlus4E, SrcAE, PCPlus4M, ALUResultM, lAuiPCM,
    output JalrE, ALUSrcE, sralE, ZeroE, TakeBranchE, RegWriteE, RegWriteM, RegWriteW, JumpE, BranchE, rowE, rowM, BorrowE,
    output [1:0] ResultSrcE, ResultSrcM, ResultSrcW,
    output [2:0] ALUControlE
);

wire        ALUSrc, RegWrite, Branch, Jump, Jalr, sral, row, MemWrite;
wire [1:0]  ResultSrc, ImmSrc, load;
wire [2:0]  ALUControl;
wire [31:0] InstrD, InstrW;

controller  c   (InstrD[6:0], InstrD[14:12], InstrD[30],
                ResultSrc, MemWrite, ALUSrc,
                RegWrite, Branch, Jump, Jalr, sral, row, ImmSrc, load, ALUControl);

datapath    dp  (clk, reset, ResultSrc,
                ALUSrc, RegWrite, ImmSrc, load, ALUControl, Branch, Jump, Jalr, sral, row, 
                PC, Instr, Mem_WrAddr, Mem_WrData, ReadData, Result, PCW, ALUResultW, WriteDataW, InstrD, InstrW, funct3,
                PCPlus4W, PCTargetM, PCNext, PCJalr, PCPlus4, InstrM, PCM, WriteDataM,
                PCD, ImmExtD, PCTargetE, SrcAD, WriteDataE, PCPlus4D,
                WriteDataD, ImmExtE, SrcB , ALUResultE, InstrE, PCE, AuiPCE,
                lAuiPCE, ReadDataW, lAuiPCW, PCPlus4E, SrcAE, PCPlus4M, ALUResultM, lAuiPCM,
                JalrE, ALUSrcE, sralE, ZeroE, TakeBranchE, RegWriteE, RegWriteM, RegWriteW, JumpE, BranchE, rowE, rowM, BorrowE,
                ResultSrcE, ResultSrcM, ResultSrcW, ALUControlE, MemWrite, MemWriteM
                );

endmodule
