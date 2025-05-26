
// pl_riscv_cpu.v - Top Module to test riscv_cpu

module pl_riscv_cpu (
    input         clk, reset,
    input         Ext_MemWrite,
    input  [31:0] Ext_WriteData, Ext_DataAdr,
    output        MemWrite,
    output [31:0] WriteData, DataAdr, ReadData,
    output [31:0] PCW, Result, ALUResultW, WriteDataW,
    output [31:0] PCPlus4W, PCTargetM, PCNext, PCJalr, PCPlus4, InstrM, PCM, WriteDataM,
    output [31:0] PCD, ImmExtD, PCTargetE, SrcAD, WriteDataE, PCPlus4D,
    output [31:0] WriteDataD, ImmExtE, SrcB , ALUResultE, InstrE, PCE, AuiPCE,
    output [31:0] lAuiPCE, ReadDataW, lAuiPCW, PCPlus4E, SrcAE, PCPlus4M, ALUResultM, lAuiPCM,
    output JalrE, ALUSrcE, sralE, ZeroE, TakeBranchE, RegWriteE, RegWriteM, RegWriteW, JumpE, BranchE, rowE, rowM, BorrowE,
    output [1:0] ResultSrcE, ResultSrcM, ResultSrcW,
    output [2:0] ALUControlE
);

wire [31:0] Instr, PC;
wire [31:0] DataAdr_rv32, WriteData_rv32;
wire [ 2:0] Store, funct3;
wire        MemWrite_rv32;

// instantiate processor and memories
riscv_cpu rvcpu    (clk, reset, PC, Instr,
                    MemWrite_rv32, DataAdr_rv32,
                    WriteData_rv32, ReadData, Result,
                    funct3, PCW, ALUResultW, WriteDataW,
                    PCPlus4W, PCTargetM, PCNext, PCJalr, PCPlus4, InstrM, PCM, WriteDataM,
                    PCD, ImmExtD, PCTargetE, SrcAD, WriteDataE, PCPlus4D,
                    WriteDataD, ImmExtE, SrcB , ALUResultE, InstrE, PCE, AuiPCE,
                    lAuiPCE, ReadDataW, lAuiPCW, PCPlus4E, SrcAE, PCPlus4M, ALUResultM, lAuiPCM,
                    JalrE, ALUSrcE, sralE, ZeroE, TakeBranchE, RegWriteE, RegWriteM, RegWriteW, JumpE, BranchE, rowE, rowM, BorrowE,
                    ResultSrcE, ResultSrcM, ResultSrcW, ALUControlE
                    );
instr_mem instrmem (PC, Instr);
data_mem  datamem  (clk, MemWrite, Store, DataAdr, WriteData, ReadData); 


assign Store = (Ext_MemWrite && reset) ? 3'b010 : funct3;
assign MemWrite  = (Ext_MemWrite && reset) ? 1'b1 : MemWrite_rv32;
assign WriteData = (Ext_MemWrite && reset) ? Ext_WriteData : WriteData_rv32;
assign DataAdr   = reset ? Ext_DataAdr : DataAdr_rv32;

endmodule
