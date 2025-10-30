`timescale 1ns / 1ps

module testbench();
  logic clk;
  logic reset;
  logic [31:0] WriteData, DataAdr;
  logic MemWrite;

  riscvpipeline dut(
    .clk(clk),
    .reset(reset),
    .WriteDataM(WriteData),
    .DataAdrM(DataAdr),
    .MemWriteM(MemWrite)
  );

  initial begin
    reset <= 1; #22; reset <= 0;
  end

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, testbench);
  end

  always begin
    clk <= 1; #5;
    clk <= 0; #5;
  end

  always @(negedge clk) begin
    if (MemWrite) begin
      if (DataAdr === 100 && WriteData === 25) begin
        $display("Simulation succeeded: Wrote %d to address %d", WriteData, DataAdr);
        $stop;
      end else if (DataAdr !== 96) begin
        $display("Simulation failed: Wrote %d to address %d", WriteData, DataAdr);
        $stop;
      end
    end
  end
endmodule

module riscvpipeline (
  input  logic clk, reset,
  output logic [31:0] WriteDataM, DataAdrM,
  output logic MemWriteM
);
  logic [31:0] PCF, InstrF, ReadDataM;

  riscv rv(
    .clk(clk),
    .reset(reset),
    .PCF(PCF),
    .InstrF(InstrF),
    .MemWriteM(MemWriteM),
    .ALUResultM(DataAdrM),
    .WriteDataM(WriteDataM),
    .ReadDataM(ReadDataM)
  );

  imem imem(
    .a(PCF),
    .rd(InstrF)
  );

  dmem dmem(
    .clk(clk),
    .we(MemWriteM),
    .a(DataAdrM),
    .wd(WriteDataM),
    .rd(ReadDataM)
  );
endmodule

module riscv(
  input  logic clk, reset,
  output logic [31:0] PCF,
  input  logic [31:0] InstrF,
  output logic MemWriteM,
  output logic [31:0] ALUResultM, WriteDataM,
  input  logic [31:0] ReadDataM
);
  logic ALUSrcE, RegWriteM, RegWriteW, ZeroE, PCSrcE;
  logic StallD, StallF, FlushD, FlushE, ResultSrcE0;
  logic [1:0] ResultSrcW;
  logic [1:0] ImmSrcD;
  logic [3:0] ALUControlE;
  logic [31:0] InstrD;
  logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E;
  logic [4:0] RdE, RdM, RdW;
  logic [1:0] ForwardAE, ForwardBE;
  logic validD, validE, validM, validW;

  controller c(
    .clk(clk),
    .reset(reset),
    .op(InstrD[6:0]),
    .funct3(InstrD[14:12]),
    .funct7b5(InstrD[30]),
    .funct7_2b(InstrD[26:25]),
    .ZeroE(ZeroE),
    .FlushE(FlushE),
    .ResultSrcE0(ResultSrcE0),
    .ResultSrcW(ResultSrcW),
    .MemWriteM(MemWriteM),
    .PCSrcE(PCSrcE),
    .ALUSrcE(ALUSrcE),
    .RegWriteM(RegWriteM),
    .RegWriteW(RegWriteW),
    .ImmSrcD(ImmSrcD),
    .ALUControlE(ALUControlE)
  );

  forwarding_unit fu(
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdM(RdM),
    .RdW(RdW),
    .RegWriteM(RegWriteM),
    .RegWriteW(RegWriteW),
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE)
  );

  hazard_unit hu(
    .Rs1D(Rs1D),
    .Rs2D(Rs2D),
    .RdE(RdE),
    .ResultSrcE0(ResultSrcE0),
    .PCSrcE(PCSrcE),
    .StallD(StallD),
    .StallF(StallF),
    .FlushD(FlushD),
    .FlushE(FlushE)
  );

  datapath dp(
    .clk(clk),
    .reset(reset),
    .ResultSrcW(ResultSrcW),
    .PCSrcE(PCSrcE),
    .ALUSrcE(ALUSrcE),
    .RegWriteW(RegWriteW),
    .ImmSrcD(ImmSrcD),
    .ALUControlE(ALUControlE),
    .ZeroE(ZeroE),
    .PCF(PCF),
    .InstrF(InstrF),
    .InstrD(InstrD),
    .ALUResultM(ALUResultM),
    .WriteDataM(WriteDataM),
    .ReadDataM(ReadDataM),
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE),
    .Rs1D(Rs1D),
    .Rs2D(Rs2D),
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdE(RdE),
    .RdM(RdM),
    .RdW(RdW),
    .StallD(StallD),
    .StallF(StallF),
    .FlushD(FlushD),
    .FlushE(FlushE),
    .validD(validD),
    .validE(validE),
    .validM(validM),
    .validW(validW)
  );
endmodule

module imem (
  input  logic [31:0] a,
  output logic [31:0] rd
);
  logic [31:0] RAM[63:0];
  initial $readmemh("riscvtest.hex", RAM);
  assign rd = RAM[a[31:2]];
endmodule

module dmem(
  input  logic clk, we,
  input  logic [31:0] a, wd,
  output logic [31:0] rd
);
  logic [31:0] RAM [63:0];
  assign rd = RAM[a[31:2]];
  always_ff @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;
endmodule

module controller(
  input  logic clk, reset,
  input  logic [6:0] op,
  input  logic [2:0] funct3,
  input  logic funct7b5,
  input  logic [1:0] funct7_2b,
  input  logic ZeroE,
  input  logic FlushE,
  output logic ResultSrcE0,
  output logic [1:0] ResultSrcW,
  output logic MemWriteM,
  output logic PCSrcE, ALUSrcE,
  output logic RegWriteM, RegWriteW,
  output logic [1:0] ImmSrcD,
  output logic [3:0] ALUControlE
);
  logic [1:0] ALUOpD;
  logic [1:0] ResultSrcD, ResultSrcE, ResultSrcM;
  logic [3:0] ALUControlD;
  logic BranchD, BranchE, MemWriteD, MemWriteE, JumpD, JumpE;
  logic ALUSrcD, RegWriteD, RegWriteE;

  maindec md(
    .op(op),
    .ResultSrc(ResultSrcD),
    .MemWrite(MemWriteD),
    .Branch(BranchD),
    .ALUSrc(ALUSrcD),
    .RegWrite(RegWriteD),
    .Jump(JumpD),
    .ImmSrc(ImmSrcD),
    .ALUOp(ALUOpD)
  );

  aludec ad(
    .opb5(op[5]),
    .funct3(funct3),
    .funct7b5(funct7b5),
    .funct7_2b(funct7_2b),
    .ALUOp(ALUOpD),
    .ALUControl(ALUControlD)
  );

  c_ID_IEx c_pipreg0(
    .clk(clk),
    .reset(reset),
    .clear(FlushE),
    .RegWriteD(RegWriteD),
    .MemWriteD(MemWriteD),
    .JumpD(JumpD),
    .BranchD(BranchD),
    .ALUSrcD(ALUSrcD),
    .ResultSrcD(ResultSrcD),
    .ALUControlD(ALUControlD),
    .RegWriteE(RegWriteE),
    .MemWriteE(MemWriteE),
    .JumpE(JumpE),
    .BranchE(BranchE),
    .ALUSrcE(ALUSrcE),
    .ResultSrcE(ResultSrcE),
    .ALUControlE(ALUControlE)
  );

  assign ResultSrcE0 = ResultSrcE[0];

  c_IEx_IM c_pipreg1(
    .clk(clk),
    .reset(reset),
    .RegWriteE(RegWriteE),
    .MemWriteE(MemWriteE),
    .ResultSrcE(ResultSrcE),
    .RegWriteM(RegWriteM),
    .MemWriteM(MemWriteM),
    .ResultSrcM(ResultSrcM)
  );

  c_IM_IW c_pipreg2 (
    .clk(clk),
    .reset(reset),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .RegWriteW(RegWriteW),
    .ResultSrcW(ResultSrcW)
  );

  assign PCSrcE = (BranchE & ZeroE) | JumpE;
endmodule

module maindec(
  input  logic [6:0] op,
  output logic [1:0] ResultSrc,
  output logic MemWrite,
  output logic Branch, ALUSrc,
  output logic RegWrite, Jump,
  output logic [1:0] ImmSrc,
  output logic [1:0] ALUOp
);
  logic [10:0] controls;
  assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;
  always_comb
    case(op)
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
      7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
      7'b0001011: controls = 11'b1_xx_0_0_00_0_11_0; // custom
      default:    controls = 11'bx_xx_x_x_xx_x_xx_x;
    endcase
endmodule

module aludec(
  input  logic opb5,
  input  logic [2:0] funct3,
  input  logic funct7b5,
  input  logic [1:0] funct7_2b,
  input  logic [1:0] ALUOp,
  output logic [3:0] ALUControl
);
  logic RtypeSub;
  assign RtypeSub = funct7b5 & opb5;
  always_comb
    case(ALUOp)
      2'b00: ALUControl = 4'b0000;
      2'b01: ALUControl = 4'b0001;
      2'b10: case(funct3)
               3'b000: ALUControl = RtypeSub ? 4'b0001 : 4'b0000;
               3'b010: ALUControl = 4'b0101;
               3'b110: ALUControl = 4'b0011;
               3'b111: ALUControl = 4'b0010;
               default: ALUControl = 4'bxxxx;
             endcase
      2'b11: case(funct7_2b)
               2'b00: case(funct3)
                        3'b000: ALUControl = 4'b0110;
                        3'b001: ALUControl = 4'b0111;
                        3'b010: ALUControl = 4'b1000;
                        default: ALUControl = 4'bxxxx;
                      endcase
               2'b01: case(funct3)
                        3'b000: ALUControl = 4'b1001;
                        3'b001: ALUControl = 4'b1010;
                        3'b010: ALUControl = 4'b1011;
                        3'b011: ALUControl = 4'b1100;
                        default: ALUControl = 4'bxxxx;
                      endcase
               2'b10: case(funct3)
                        3'b000: ALUControl = 4'b1101;
                        3'b001: ALUControl = 4'b1110;
                        default: ALUControl = 4'bxxxx;
                      endcase
               2'b11: case(funct3)
                        3'b000: ALUControl = 4'b1111;
                        default: ALUControl = 4'bxxxx;
                      endcase
               default: ALUControl = 4'bxxxx;
             endcase
      default: ALUControl = 4'bxxxx;
    endcase
endmodule

module c_ID_IEx (
  input  logic clk, reset, clear,
  input  logic RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD,
  input  logic [1:0] ResultSrcD,
  input  logic [3:0] ALUControlD,
  output logic RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE,
  output logic [1:0] ResultSrcE,
  output logic [3:0] ALUControlE
);
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      RegWriteE <= 0; MemWriteE <= 0; JumpE <= 0; BranchE <= 0; ALUSrcE <= 0; ResultSrcE <= 0; ALUControlE <= 0;
    end else if (clear) begin
      RegWriteE <= 0; MemWriteE <= 0; JumpE <= 0; BranchE <= 0; ALUSrcE <= 0; ResultSrcE <= 0; ALUControlE <= 0;
    end else begin
      RegWriteE <= RegWriteD;
      MemWriteE <= MemWriteD;
      JumpE <= JumpD;
      BranchE <= BranchD;
      ALUSrcE <= ALUSrcD;
      ResultSrcE <= ResultSrcD;
      ALUControlE <= ALUControlD;
    end
  end
endmodule

module c_IEx_IM (
  input  logic clk, reset,
  input  logic RegWriteE, MemWriteE,
  input  logic [1:0] ResultSrcE,
  output logic RegWriteM, MemWriteM,
  output logic [1:0] ResultSrcM
);
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      RegWriteM <= 0; MemWriteM <= 0; ResultSrcM <= 0;
    end else begin
      RegWriteM <= RegWriteE;
      MemWriteM <= MemWriteE;
      ResultSrcM <= ResultSrcE;
    end
  end
endmodule

module c_IM_IW (
  input  logic clk, reset,
  input  logic RegWriteM,
  input  logic [1:0] ResultSrcM,
  output logic RegWriteW,
  output logic [1:0] ResultSrcW
);
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      RegWriteW <= 0; ResultSrcW <= 0;
    end else begin
      RegWriteW <= RegWriteM;
      ResultSrcW <= ResultSrcM;
    end
  end
endmodule

module forwarding_unit(
  input  logic [4:0] Rs1E, Rs2E,
  input  logic [4:0] RdM, RdW,
  input  logic RegWriteM, RegWriteW,
  output logic [1:0] ForwardAE, ForwardBE
);
  always_comb begin
    ForwardAE = 2'b00; ForwardBE = 2'b00;
    if ((Rs1E == RdM) & RegWriteM & (Rs1E != 0))
      ForwardAE = 2'b10;
    else if ((Rs1E == RdW) & RegWriteW & (Rs1E != 0))
      ForwardAE = 2'b01;
    if ((Rs2E == RdM) & RegWriteM & (Rs2E != 0))
      ForwardBE = 2'b10;
    else if ((Rs2E == RdW) & RegWriteW & (Rs2E != 0))
      ForwardBE = 2'b01;
  end
endmodule

module hazard_unit(
  input  logic [4:0] Rs1D, Rs2D,
  input  logic [4:0] RdE,
  input  logic ResultSrcE0,
  input  logic PCSrcE,
  output logic StallD, StallF,
  output logic FlushD, FlushE
);
  logic lwStall;
  assign lwStall = (ResultSrcE0 == 1) & ((RdE == Rs1D) | (RdE == Rs2D));
  assign StallF = lwStall;
  assign StallD = lwStall;
  assign FlushE = lwStall | PCSrcE;
  assign FlushD = PCSrcE;
endmodule

module datapath(
  input  logic clk, reset,
  input  logic [1:0] ResultSrcW,
  input  logic PCSrcE, ALUSrcE,
  input  logic RegWriteW,
  input  logic [1:0] ImmSrcD,
  input  logic [3:0] ALUControlE,
  output logic ZeroE,
  output logic [31:0] PCF,
  input  logic [31:0] InstrF,
  output logic [31:0] InstrD,
  output logic [31:0] ALUResultM, WriteDataM,
  input  logic [31:0] ReadDataM,
  input  logic [1:0] ForwardAE, ForwardBE,
  output logic [4:0] Rs1D, Rs2D, Rs1E, Rs2E,
  output logic [4:0] RdE, RdM, RdW,
  input  logic StallD, StallF, FlushD, FlushE,
  output logic validD, validE, validM, validW
);
  logic [31:0] PCD, PCE, ALUResultE, ALUResultW, ReadDataW;
  logic [31:0] PCNextF, PCPlus4F, PCPlus4D, PCPlus4E, PCPlus4M, PCPlus4W, PCTargetE;
  logic [31:0] WriteDataE;
  logic [31:0] ImmExtD, ImmExtE;
  logic [31:0] SrcAE, SrcBE, RD1D, RD2D, RD1E, RD2E;
  logic [31:0] ResultW;
  logic [4:0] RdD;

  mux2 #(.WIDTH(32)) pcmux(.d0(PCPlus4F), .d1(PCTargetE), .s(PCSrcE), .y(PCNextF));
  flopenr #(.WIDTH(32)) IF(.clk(clk), .reset(reset), .en(~StallF), .d(PCNextF), .q(PCF));
  adder pcadd4(.a(PCF), .b(32'd4), .y(PCPlus4F));

  IF_ID pipreg0(
    .clk(clk), .reset(reset), .clear(FlushD), .enable(~StallD),
    .InstrF(InstrF), .PCF(PCF), .PCPlus4F(PCPlus4F),
    .InstrD(InstrD), .PCD(PCD), .PCPlus4D(PCPlus4D),
    .valid_in(1'b1), .valid_out(validD)
  );

  assign Rs1D = InstrD[19:15];
  assign Rs2D = InstrD[24:20];
  assign RdD  = InstrD[11:7];

  regfile rf(.clk(clk), .we3(RegWriteW), .a1(Rs1D), .a2(Rs2D), .a3(RdW), .wd3(ResultW), .rd1(RD1D), .rd2(RD2D));

  extend ext(.instr(InstrD[31:7]), .immsrc(ImmSrcD), .immext(ImmExtD));

  ID_IEx pipreg1(
    .clk(clk), .reset(reset), .clear(FlushE),
    .RD1D(RD1D), .RD2D(RD2D), .PCD(PCD),
    .Rs1D(Rs1D), .Rs2D(Rs2D), .RdD(RdD),
    .ImmExtD(ImmExtD), .PCPlus4D(PCPlus4D),
    .RD1E(RD1E), .RD2E(RD2E), .PCE(PCE),
    .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
    .ImmExtE(ImmExtE), .PCPlus4E(PCPlus4E),
    .valid_in(validD), .valid_out(validE)
  );

  mux3 #(.WIDTH(32)) forwardMuxA(.d0(RD1E), .d1(ResultW), .d2(ALUResultM), .s(ForwardAE), .y(SrcAE));
  mux3 #(.WIDTH(32)) forwardMuxB(.d0(RD2E), .d1(ResultW), .d2(ALUResultM), .s(ForwardBE), .y(WriteDataE));
  mux2 #(.WIDTH(32)) srcbmux(.d0(WriteDataE), .d1(ImmExtE), .s(ALUSrcE), .y(SrcBE));

  adder pcaddbranch(.a(PCE), .b(ImmExtE), .y(PCTargetE));

  alu alu_unit(.a(SrcAE), .b(SrcBE), .alucontrol(ALUControlE), .result(ALUResultE), .zero(ZeroE));

  IEx_IMem pipreg2(
    .clk(clk), .reset(reset),
    .ALUResultE(ALUResultE), .WriteDataE(WriteDataE), .RdE(RdE), .PCPlus4E(PCPlus4E),
    .ALUResultM(ALUResultM), .WriteDataM(WriteDataM), .RdM(RdM), .PCPlus4M(PCPlus4M),
    .valid_in(validE), .valid_out(validM)
  );

  IMem_IW pipreg3(
    .clk(clk), .reset(reset),
    .ALUResultM(ALUResultM), .ReadDataM(ReadDataM),
    .RdM(RdM), .PCPlus4M(PCPlus4M),
    .ALUResultW(ALUResultW), .ReadDataW(ReadDataW), .RdW(RdW), .PCPlus4W(PCPlus4W),
    .valid_in(validM), .valid_out(validW)
  );

  mux3 #(.WIDTH(32)) resultmux(.d0(ALUResultW), .d1(ReadDataW), .d2(PCPlus4W), .s(ResultSrcW), .y(ResultW));
endmodule

module mux2 #(parameter WIDTH=8)(
  input logic [WIDTH-1:0] d0, d1,
  input logic s,
  output logic [WIDTH-1:0] y
);
  assign y = s ? d1 : d0;
endmodule

module flopenr #(
  parameter WIDTH = 8
) (
  input logic clk, reset, en,
  input logic [WIDTH-1:0] d,
  output logic [WIDTH-1:0] q
);
  always_ff @(posedge clk or posedge reset) begin
    if (reset) q <= 0;
    else if (en) q <= d;
  end
endmodule

module adder(
  input [31:0] a, b,
  output [31:0] y
);
  assign y = a + b;
endmodule

module IF_ID (
  input logic clk, reset, clear, enable,
  input logic [31:0] InstrF, PCF, PCPlus4F,
  output logic [31:0] InstrD, PCD, PCPlus4D,
  input logic valid_in,
  output logic valid_out
);
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      InstrD <= 0; PCD <= 0; PCPlus4D <= 0; valid_out <= 0;
    end else if (enable) begin
      if (clear) begin
        InstrD <= 32'h00000033; PCD <= 0; PCPlus4D <= 0; valid_out <= 0;
      end else begin
        InstrD <= InstrF; PCD <= PCF; PCPlus4D <= PCPlus4F; valid_out <= valid_in;
      end
    end
  end
endmodule

module regfile (
  input logic clk,
  input logic we3,
  input logic [4:0] a1, a2, a3,
  input logic [31:0] wd3,
  output logic [31:0] rd1, rd2
);
  logic [31:0] rf[31:0];
  always_ff @(negedge clk)
    if (we3 & (a3 != 0)) rf[a3] <= wd3;
  assign rd1 = (a1 != 0) ? rf[a1] : 0;
  assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

module extend(
  input logic [31:7] instr,
  input logic [1:0] immsrc,
  output logic [31:0] immext
);
  always_comb
    case(immsrc)
      2'b00: immext = {{20{instr[31]}}, instr[31:20]};
      2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      2'b10: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
      2'b11: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
      default: immext = 32'bx;
    endcase
endmodule

module ID_IEx (
  input logic clk, reset, clear,
  input logic [31:0] RD1D, RD2D, PCD,
  input logic [4:0] Rs1D, Rs2D, RdD,
  input logic [31:0] ImmExtD, PCPlus4D,
  output logic [31:0] RD1E, RD2E, PCE,
  output logic [4:0] Rs1E, Rs2E, RdE,
  output logic [31:0] ImmExtE, PCPlus4E,
  input logic valid_in,
  output logic valid_out
);
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      RD1E <= 0; RD2E <= 0; PCE <= 0; Rs1E <= 0; Rs2E <= 0; RdE <= 0; ImmExtE <= 0; PCPlus4E <= 0; valid_out <= 0;
    end else if (clear) begin
      RD1E <= 0; RD2E <= 0; PCE <= 0; Rs1E <= 0; Rs2E <= 0; RdE <= 0; ImmExtE <= 0; PCPlus4E <= 0; valid_out <= 0;
    end else begin
      RD1E <= RD1D; RD2E <= RD2D; PCE <= PCD; Rs1E <= Rs1D; Rs2E <= Rs2D; RdE <= RdD; ImmExtE <= ImmExtD; PCPlus4E <= PCPlus4D; valid_out <= valid_in;
    end
  end
endmodule

module mux3 #(parameter WIDTH=8)(
  input logic [WIDTH-1:0] d0, d1, d2,
  input logic [1:0] s,
  output logic [WIDTH-1:0] y
);
  assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule

module alu(
  input logic [31:0] a, b,
  input logic [3:0] alucontrol,
  output logic [31:0] result,
  output logic zero
);
  logic [31:0] condinvb, sum;
  logic v;
  assign condinvb = alucontrol[0] ? ~b : b;
  assign sum = a + condinvb + alucontrol[0];
  always_comb begin
    case (alucontrol)
      4'b0000: result = sum;
      4'b0001: result = sum;
      4'b0010: result = a & b;
      4'b0011: result = a | b;
      4'b0100: result = a ^ b;
      4'b0101: result = {31'b0, sum[31]^v};
      4'b0110: result = a & (~b);
      4'b0111: result = a | (~b);
      4'b1000: result = ~(a ^ b);
      4'b1001: result = ($signed(a) < $signed(b)) ? a : b;
      4'b1010: result = ($signed(a) > $signed(b)) ? a : b;
      4'b1011: result = (a < b) ? a : b;
      4'b1100: result = (a > b) ? a : b;
      4'b1101: result = (a << b[4:0]) | (a >> (32 - b[4:0]));
      4'b1110: result = (a >> b[4:0]) | (a << (32 - b[4:0]));
      4'b1111: result = (a[31] == 1'b0) ? a : -a;
      default: result = 32'bx;
    endcase
  end
  assign zero = (result == 32'b0);
  assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & ((~alucontrol[2] & ~alucontrol[1]) | (~alucontrol[1] & alucontrol[0]));
endmodule

module IEx_IMem(
  input logic clk, reset,
  input logic [31:0] ALUResultE, WriteDataE,
  input logic [4:0] RdE,
  input logic [31:0] PCPlus4E,
  output logic [31:0] ALUResultM, WriteDataM,
  output logic [4:0] RdM,
  output logic [31:0] PCPlus4M,
  input logic valid_in,
  output logic valid_out
);
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      ALUResultM <= 0; WriteDataM <= 0; RdM <= 0; PCPlus4M <= 0; valid_out <= 0;
    end else begin
      ALUResultM <= ALUResultE; WriteDataM <= WriteDataE; RdM <= RdE; PCPlus4M <= PCPlus4E; valid_out <= valid_in;
    end
  end
endmodule

module IMem_IW (
  input logic clk, reset,
  input logic [31:0] ALUResultM, ReadDataM,
  input logic [4:0] RdM,
  input logic [31:0] PCPlus4M,
  output logic [31:0] ALUResultW, ReadDataW,
  output logic [4:0] RdW,
  output logic [31:0] PCPlus4W,
  input logic valid_in,
  output logic valid_out
);
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      ALUResultW <= 0; ReadDataW <= 0; RdW <= 0; PCPlus4W <= 0; valid_out <= 0;
    end else begin
      ALUResultW <= ALUResultM; ReadDataW <= ReadDataM; RdW <= RdM; PCPlus4W <= PCPlus4M; valid_out <= valid_in;
    end
  end
endmodule
