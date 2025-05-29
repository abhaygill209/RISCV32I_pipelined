module hazard_control(
    input [31:0] InstrD, InstrW, InstrM, InstrE, 
    input PCSrc, 
    input RegWriteM, RegWriteW, 
    output reg [1:0] srcAE, srcBE,
    output reg [1:0] regAD, regBD,
    output reg pc_fwd_sel,
    output FlushD, FlushE, FlushM, FlushW,
    output StallD, StallE, StallM, StallW, StallF
);

wire [4:0] rs1E,rs2E, rs1D, rs2D, rdM, rdW;
wire [1:0] opD, opE ;
wire [2:0] op2_0M, op2_0W;
wire       op_6M;
assign rs1D = InstrD[19:15];
assign rs2D = InstrD[24:20];
assign rs1E = InstrE[19:15];
assign rs2E = InstrE[24:20];
assign rdM = InstrM[11: 7];
assign rdW = InstrW[11: 7];
assign opD = InstrD[5:4];
assign opE = InstrE[5:4];
assign op_6M = InstrM[6];

assign op2_0M = InstrM[2:0];
assign op2_0W = InstrW[2:0];

//difining common logics 

// for execution stage 
wire _rs1E_rdM, _rs1E_rdW, _rs2E_rdM, _rs2E_rdW, _rs1E, _rs2E;
assign _rs1E_rdM = (rs1E==rdM)? 1'b1 : 1'b0;
assign _rs1E_rdW = (rs1E==rdW)? 1'b1 : 1'b0;
assign _rs2E_rdM = (rs2E==rdM)? 1'b1 : 1'b0;
assign _rs2E_rdW = (rs2E==rdW)? 1'b1 : 1'b0;

assign _rs1E = (rs1E!=5'd0)? 1'b1 : 1'b0;
assign _rs2E = (rs2E!=5'd0)? 1'b1 : 1'b0;

//for decode stage 
wire _rs1D_rdW,  _rs2D_rdW, _rs1D, _rs2D;
assign _rs1D_rdW = (rs1D==rdW)? 1'b1 : 1'b0;
assign _rs2D_rdW = (rs2D==rdW)? 1'b1 : 1'b0;

assign _rs1D = (rs1D!=5'd0)? 1'b1 : 1'b0;
assign _rs2D = (rs2D!=5'd0)? 1'b1 : 1'b0;

//misc
wire _op_b00D, _op_b00E, _op2_0M, _op2_0W;
assign _op_b00D = (opD!=2'b00)? 1'b1 : 1'b0; //prevent imm==rs2 in some I type Instructions
assign _op_b00E = (opE!=2'b00)? 1'b1 : 1'b0;
assign _op2_0M  = (op2_0M==3'b111)? 1'b1 : 1'b0; //U and J type instr
assign _op2_0W  = (op2_0W==3'b111)? 1'b1 : 1'b0; //U and J type instr

initial begin
    srcAE = 2'b00;
    srcBE = 2'b00;
    regAD = 2'b00;
    regBD = 2'b00;
    pc_fwd_sel = 1'b0;
end

//forwarding logic 
always @(*) begin
        
        // to rs1E
        if      (RegWriteM & _rs1E_rdM & _rs1E) begin
            if (_op2_0M) srcAE = 2'b11;            //data from M-stage
            else         srcAE = 2'b01;
        end 
        else if (RegWriteW & _rs1E_rdW & _rs1E) begin           //data from w-stage
            srcAE = 2'b10;            //others 
        end 
        else srcAE = 2'b00; 
        //to rs1D
        if (RegWriteW & _rs1D_rdW & _rs1D) begin //for W to D stage 
            regAD = 2'b01;
        end 
        else regAD = 2'b00;

        // to rs2E
        if      (RegWriteM & _rs2E_rdM & _rs2E & _op_b00E) begin
            if (_op2_0M) srcBE = 2'b11;            //data from M-stage
            else         srcBE = 2'b01;
        end 
        else if (RegWriteW & _rs2E_rdW & _rs2E & _op_b00E) begin           //data from w-stage
            srcBE = 2'b10;            //others 
        end 
        else srcBE = 2'b00; 
        //to rs1D
        if (RegWriteW & _rs2D_rdW & _rs2D & _op_b00D) begin //for W to D stage 
            regBD = 2'b01;
        end 
        else regBD = 2'b00;

        //for Jump and U type pc forwarding     
        if (RegWriteM) begin
            case(op_6M)
                1'b0: pc_fwd_sel = 1'b1;
                1'b1: pc_fwd_sel = 1'b0;
                default : pc_fwd_sel = 1'b0;
            endcase
        end 
end


// flush and stall control 
assign FlushD = PCSrc;
assign FlushE = PCSrc;
assign FlushM = 1'b0;
assign FlushW = 1'b0;

assign StallD = 1'b0;
assign StallE = 1'b0;
assign StallM = 1'b0;
assign StallW = 1'b0;
assign StallF = 1'b0;
    
endmodule