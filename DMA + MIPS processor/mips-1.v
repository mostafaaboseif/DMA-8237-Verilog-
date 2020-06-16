module sysCall(sysCallC, reg1Data, reg2Data, clk, PC);
    input wire sysCallC;
    input wire [31:0] reg1Data;
    input wire [31:0] reg2Data;
    input wire clk;
    input wire [31:0] PC;           
    integer clk_Count = 0; 
    always @(posedge clk) begin
        if(sysCallC == 1)begin
            if(reg1Data == 1)begin
                $display("[syscall]     clk: %0d, PC:%0d, output:%0d",clk_Count,PC,reg2Data);
            end
        end
    end
    always @(posedge clk)begin
        clk_Count <= clk_Count + 1;
    end
endmodule




module SignExtend(result,in);
    input [15:0] in;
    output [31:0] result;
    assign result = {{16{in[15]}}, in};
endmodule
module RegFile(reg1Data,reg2Data,regW,r1A,r2A,wrA,wrD,clk,PC);
    output [31:0] reg1Data;    //register 1 Data
    output [31:0] reg2Data;    //register 2 Data
    input wire [31:0] wrD;          //write data
    input wire regW;                //register write
    input wire [4:0] r1A;           //register 1 address
    input wire [4:0] r2A;           //register 2 address
    input wire [4:0] wrA;           //write register address
    input wire clk;
    input wire [31:0] PC;           //For debuging issues 
    reg [31:0] Registers [0:31];
    integer clk_Count = 0; 
    integer i;
        
    initial begin
        for (i=0;i<=31;i=i+1) Registers[i] = i; //initialize registers--just so they aren?t cares
	Registers[31] = 8191;
	$write("[Reg Init]    ");
	for (i=0;i<=31;i=i+1)begin
		$write("%b, ",Registers[i]);
	end
	$write("\n");
    end 

       assign reg1Data = Registers[r1A];
       assign reg2Data = Registers[r2A];
    
    
    always @(posedge clk)begin
        if(regW == 1) begin
            if(wrA != 0)begin
                Registers[wrA] = wrD;
                $display("[Reg File]    clk: %0d, PC:%0d, regNumber:%0d, regValue:%0d",clk_Count,PC,wrA,wrD);
            end
            else begin
                Registers[wrA] = 0;
                $display("[Reg File]    clk: %0d, PC:%0d, regNumber:%0d, regValue:%b",clk_Count,PC,wrA,32'b0);
            end
        end
    end

    always @(posedge clk)begin
        clk_Count <= clk_Count + 1;
        if (clk_Count > 9999) begin
            $finish();
        end
    end
endmodule


module InstMem(insData,pc);
    input wire [14:0] pc;
    output wire [31:0] insData;
    reg [7:0] memory [0:1023];
integer fileInstruction;
    assign insData = {memory[pc],memory[pc+1],memory[pc+2],memory[pc+3]};
    initial begin
        fileInstruction = $fopen("instructionMem.txt","r");
	$readmemb("../biteCode/verilogRunFile.txt",memory,0,1023);
    end 
endmodule
module DataMem(data,address,wData,read,write,PC,clk);
    output wire [31:0] data;
    input wire [31:0] wData;
    input wire [31:0] address;
    input wire read;
    input wire write;
    input wire [31:0] PC;
    input wire clk;
    reg [7:0] memory [0:1023];
    integer clk_Count = 0;
integer fileData ;
    initial 
begin 
fileData = $fopen("dataMem.txt","r");
$readmemb("dataMem.txt",memory,0,1023);
end 
    assign data = (read) ? {memory[address+3],memory[address+2],memory[address+1],memory[address]} : 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    always @(posedge clk) begin
        if (write === 1) begin
            memory[address] <= wData[7:0];
            memory[address + 1] <= wData[15:8];
            memory[address + 2] <= wData[23:16];
            memory[address + 3] <= wData[31:24];
            $display("[Data Memory] clk: %0d, PC:%0d, memAdress:%0d, value:%b",clk_Count,PC,address,wData);
        end
    end
    always @(posedge clk)begin
        clk_Count <= clk_Count + 1;
    end
endmodule

module Control(OpCode, func, RegDest, Branch, BranchNot, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite, Jump, JumpR, Jal, syscall);
	
	input  [5:0] OpCode, func;
	output reg RegDest, Branch, BranchNot, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite, Jump, JumpR, Jal, syscall;
	output reg [3:0]ALUOp;
	
	initial begin
		RegDest <=0;
		Branch 	<=0;
		MemRead <=0;
		MemToReg <=0;
		MemWrite <=0;
	    ALUSrc <=0;
		RegWrite <=0;
		Jump <= 0;
		ALUOp <= 0;
		BranchNot <= 0;
		JumpR <= 0;
		syscall <= 0; 
	end
	
	always @(OpCode or func)
	begin
		if(OpCode == 0)       // OpCode of R type
		begin
			Branch <= 0;
			MemRead <= 0;
			MemWrite <= 0;
			ALUSrc <= 0;
			RegWrite <= 1;
			Jump<= 0 ;
			
			MemToReg <= 0;
			RegDest <= 1;
			ALUOp <= 4'b0000;
			BranchNot <= 0;
			JumpR <= (func == 8);
			Jal <= 0;
			syscall <= 0;
		end
		else if(OpCode == 35) // OpCode of the LW
		begin
			Branch <= 0;
			MemRead <= 1;
			MemWrite <= 0;
			ALUSrc <= 1;
			RegWrite <=1;
			Jump <=0;
			
			MemToReg <= 1;
			RegDest <= 0;
			ALUOp <= 4'b0010;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
		else if(OpCode == 43) // OpCode of the SW
		begin
			Branch <= 0;
			MemRead <= 0;
			MemWrite <= 1;
			ALUSrc <= 1;
			RegWrite <= 0;
			Jump <= 0;
			 // RegDest and MemToReg are dont cares
			RegDest <= 1'bx;
			MemToReg <= 1'bx;
			ALUOp <= 4'b0010;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
		else if(OpCode == 4) // OpCode of the beq
		begin
			Branch <= 1;
			MemRead <=0;
			MemWrite <=0;
			ALUSrc <=0;
			RegWrite <=0;
			Jump <=0;
			 // RegDest and MemToReg are dont cares
			RegDest <= 1'bx;
			MemToReg <= 1'bx;
			ALUOp <= 4'b0110;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
		else if (OpCode == 2) // opcode of the jump 
		begin
			MemRead <= 0;
			MemWrite <= 0;
			RegWrite <= 0;
			Jump <= 1;
			
			
			ALUSrc <=1'bx;
			Branch <= 1'bx;
			RegDest <= 1'bx;	
			MemToReg <= 1'bx;
			ALUOp <= 4'bxxxx;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
		else if (OpCode == 3) // opcode of the jal
		begin
			MemRead <= 0;
			MemWrite <=0;
			RegWrite <= 1;
			Jump <= 0;
			Branch <= 1'b0;
			ALUSrc <= 1'bx;
			RegDest <= 1'b1;	
			MemToReg <= 0;
			ALUOp <= 4'bxxxx;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 1;
			syscall <= 0;
		end
		else if (OpCode == 8) // addi
		begin
			MemRead <=0;
			MemWrite <=0;
			RegWrite <=1;
			Jump <= 0;
			Branch <= 0;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 4'b0010;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
		
		else if (OpCode == 12) // andi
		begin
			MemRead <= 0;
			MemWrite <= 0 ;
			RegWrite  <= 1;
			Jump <= 0;
			Branch <= 0;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 4'b0000;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
		else if (OpCode == 13) // ori
		begin
			MemRead <=0 ;
			MemWrite <=0 ;
			RegWrite <=1;
			Jump <= 0;
			Branch <= 0;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 4'b0001;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
		else if (OpCode == 14) // xori
		begin
			MemRead <= 0;
			MemWrite <= 0;
			RegWrite <= 1;
			Jump <= 0;
			Branch <= 0;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 13;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
		else if (OpCode == 10) // slti
		begin
			MemRead <= 0;
			MemWrite <= 0;
			RegWrite <= 1;
			Jump <= 0;
			Branch <= 0;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 7;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
		else if (OpCode == 32) // lb
		begin
			MemRead <=1;
			MemWrite <=0;
			RegWrite <=1;
			Jump <= 0;
			Branch <= 0;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 4'b0110;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
		else if (OpCode == 15) // lui
		begin
			MemRead <=0;
			MemWrite <=0;
			RegWrite <=1;
			Jump <= 0;
			Branch <= 0;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 14;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
		else if (OpCode == 5) // bne
		begin
			MemRead <=0;
			MemWrite <=0;
			RegWrite <=0;
			Jump <= 0;
			Branch <= 0;
			ALUSrc <= 1'b0;
			RegDest <= 1'bx;
			MemToReg <= 1'bx;
			ALUOp <= 6;
			BranchNot <= 1;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
		else if (OpCode == 63)
		begin
			$display("Finished");
			$finish();
		end
		else if (OpCode == 62) // syscall
		begin
			RegDest <=0;
			Branch 	<=0;
			MemRead <=0;
			MemToReg <=0;
			MemWrite <=0;
			ALUSrc <=0;
			RegWrite <=0;
			Jump <= 0;
			ALUOp <= 0;
			BranchNot <= 0;
			JumpR <= 0;
			syscall <= 1;
		end
		else
		begin
			RegDest <=0;
			Branch <=0;
			MemRead <=0;
			MemToReg <=0;
			MemWrite <=0;
			ALUSrc <=0;
			RegWrite <=0;
			Jump <= 0;
			ALUOp <= 0;
			BranchNot <= 0;
			JumpR <= 0;
			Jal <= 0;
			syscall <= 0;
		end
	end
endmodule

module ALUControl(ALUOp, Func, Sel);
	input [5:0] Func;
	input [3:0] ALUOp;
	output reg [3:0]  Sel;
	always@(ALUOp or Func)
        begin
		if( ALUOp == 0)
		begin
			if(Func == 32) 		// add
				Sel = 2;
			else if (Func == 34) 	// sub
				Sel = 6;
			else if (Func == 36) 	// and
				Sel = 0;
			else if (Func == 37) 	// 0r
				Sel = 1;
			else if (Func == 42) 	// slt
				Sel = 7;
			else if (Func == 39) 	// nor
				Sel = 12;
			else if (Func == 38) 	// xor
				Sel = 13;
			else if (Func == 0) 	// sll
				Sel = 14;
			else if (Func == 2) 	// srl
				Sel = 15;
			else if (Func == 3) 	// sra
				Sel = 11;
			else
				Sel = 0;
		end

		else // lw sw lui
			Sel = ALUOp;
	end
endmodule

module ALU(A, B, ALUCtrl, ALUOut, shamt, Zero);
	input wire [3:0] ALUCtrl;
	input wire [4:0] shamt;
	input wire [31:0] A;
	input wire [31:0] B;
	output reg [31:0] ALUOut;
	output Zero;
	
	initial begin
		ALUOut = 0;
	end
	
	assign Zero = (ALUOut == 0) ? 1 : 0;
	always @(ALUCtrl, A, B)
	begin
		case(ALUCtrl)
			0: 	ALUOut <= A & B;
			1: 	ALUOut <= A | B;
			2: 	ALUOut <= A + B;
			6: 	ALUOut <= A - B;
			7: 	ALUOut <= A < B ? 1 : 0;
			12: 	ALUOut <= ~(A | B);
			13: 	ALUOut <= ~(A ^ B);
			14: 	ALUOut <= (B << shamt);
			15: 	ALUOut <= (B >> shamt);
			11: 	ALUOut <= (B >>> shamt);  // sra
			17:	ALUOut <= (B << 16); 	 // lui
			default: ALUOut <= 0; 
		endcase
	end
endmodule
module adder_32(sum,cout,num1,num2,cin);
    output wire [31:0] sum;
    output wire cout;
    input wire [31:0] num1;
    input wire [31:0] num2;
    input wire cin;
    wire [32:0] c;
    assign c[0] = cin;
    assign cout = c[32];
    adder add [31:0] (sum[31:0],c[32:1],num1[31:0],num2[31:0],c[31:0]);
endmodule


module adder(sum,cout,num1,num2,cin);
    output wire sum, cout;
    input wire num1, num2, cin;
    wire w1,w2,w3;
    xor(w1,num1,num2);
    xor(sum,w1,cin);
    and(w2,w1,cin);
    and(w3,num1,num2);
    or(cout,w2,w3);
endmodule
module Mux_32(out,sel,in1,in2);
    output wire [0:31] out;
    input wire sel;
    input wire [0:31] in1;
    input wire [0:31] in2;
    assign out = (sel == 0) ? in1 : in2;
endmodule


module Mux_5(out,sel,in1,in2);
    output wire [0:4] out;
    input wire sel;
    input wire [0:4] in1;
    input wire [0:4] in2;
    assign out = (sel == 0) ? in1 : in2;
endmodule

module Mux_11(out,sel,in1,in2);
    output wire [0:10] out;
    input wire sel;
    input wire [0:10] in1;
    input wire [0:10] in2;
    assign out = (sel == 0) ? in1 : in2;
endmodule

module Mux_1(out,sel,in1,in2);
    output wire out;
    input wire sel;
    input wire in1;
    input wire in2;
    assign out = (sel == 0) ? in1 : in2;
endmodule
