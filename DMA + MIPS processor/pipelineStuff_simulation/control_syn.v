//CONTROL UNIT
module Control(RegDest, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite, OpCode, func, finish, syscall
				,branch, branchNot, IF_Flush, jump, jumpR, jal);
	
	input wire [5:0] OpCode;
	input wire [5:0] func;
	output reg RegDest;
	output reg MemRead;
	output reg syscall;
	output reg finish;
	output reg MemToReg;
	output reg MemWrite;
	output reg ALUSrc;
	output reg RegWrite;
	output reg branch;
	output reg branchNot;
	output reg IF_Flush;
	output reg jump;
	output reg jumpR;
	output reg jal;
	output reg [3:0]ALUOp;
	
	initial begin
		RegDest <=0;
		MemRead <=0;
		MemToReg <=0;
		MemWrite <=0;
	    ALUSrc <=0;
		RegWrite <=0;
		ALUOp <= 0;
		finish <= 0;
		syscall <= 0;
		branch <= 0;
		branchNot <= 0;
		IF_Flush <= 0;
		jump <= 0;
		jal <= 0;
		jumpR <= 0;
	end
	
	always @(OpCode or func)
	begin
		if(OpCode == 0)       // OpCode of R type
		begin
			MemRead <= 0;
			MemWrite <= 0;
			ALUSrc <= 0;
			RegWrite <= 1;
			MemToReg <= 0;
			RegDest <= 1;
			ALUOp <= 4'b0000;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			IF_Flush <= (func == 8);
			jump <= 0;
			jal <= 0;
			jumpR <= (func == 8);
		end
		else if(OpCode == 35) // OpCode of the LW
		begin
			MemRead <= 1;
			MemWrite <= 0;
			ALUSrc <= 1;
			RegWrite <=1;
			MemToReg <= 1;
			RegDest <= 0;
			ALUOp <= 4'b0010;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			IF_Flush <= 0;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		else if(OpCode == 43) // OpCode of the SW
		begin
			MemRead <= 0;
			MemWrite <= 1;
			ALUSrc <= 1;
			RegWrite <= 0;
			RegDest <= 1'bx;
			MemToReg <= 1'bx;
			ALUOp <= 4'b0010;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			IF_Flush <= 0;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		else if(OpCode == 4) // OpCode of the beq
		begin
			MemRead <=0;
			MemWrite <=0;
			ALUSrc <=0;
			RegWrite <=0;
			RegDest <= 1'bx;
			MemToReg <= 1'bx;
			ALUOp <= 4'b0110;
			finish <= 0;
			syscall <= 0;
			branch <= 1;
			branchNot <= 0;
			IF_Flush <= 1;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		else if (OpCode == 2) // opcode of the jump 
		begin
			MemRead <= 0;
			MemWrite <= 0;
			RegWrite <= 0;
			ALUSrc <=1'bx;
			RegDest <= 1'bx;	
			MemToReg <= 1'bx;
			ALUOp <= 4'bxxxx;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			IF_Flush <= 1;
			jump <= 1;
			jal <= 0;
			jumpR <= 0;
		end
		else if (OpCode == 3) // opcode of the jal
		begin
			MemRead <= 0;
			MemWrite <=0;
			RegWrite <= 1;
			ALUSrc <= 1'bx;
			RegDest <= 1'b1;	
			MemToReg <= 0;
			ALUOp <= 4'bxxxx;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			IF_Flush <= 0;
			jump <= 0;
			jal <= 1;
			jumpR <= 0;
		end
		else if (OpCode == 8) // addi
		begin
			MemRead <=0;
			MemWrite <=0;
			RegWrite <=1;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 4'b0010;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			IF_Flush <= 0;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		
		else if (OpCode == 12) // andi
		begin
			MemRead <= 0;
			MemWrite <= 0 ;
			RegWrite  <= 1;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 4'b0000;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			IF_Flush <= 0;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		else if (OpCode == 13) // ori
		begin
			MemRead <=0 ;
			MemWrite <=0 ;
			RegWrite <=1;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 4'b0001;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			IF_Flush <= 0;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		else if (OpCode == 14) // xori
		begin
			MemRead <= 0;
			MemWrite <= 0;
			RegWrite <= 1;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 13;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			IF_Flush <= 0;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		else if (OpCode == 10) // slti
		begin
			IF_Flush <= 0;
			MemRead <= 0;
			MemWrite <= 0;
			RegWrite <= 1;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 7;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		else if (OpCode == 32) // lb
		begin
			IF_Flush <= 0;
			MemRead <=1;
			MemWrite <=0;
			RegWrite <=1;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 4'b0110;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		else if (OpCode == 15) // lui
		begin
			IF_Flush <= 0;
			MemRead <=0;
			MemWrite <=0;
			RegWrite <=1;
			ALUSrc <= 1;
			RegDest <= 0;
			MemToReg <= 0;
			ALUOp <= 14;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		else if (OpCode == 5) // bne
		begin
			MemRead <=0;
			MemWrite <=0;
			RegWrite <=0;
			ALUSrc <= 1'b0;
			RegDest <= 1'bx;
			MemToReg <= 1'bx;
			ALUOp <= 6;
			finish <= 0;
			syscall <= 0;
			branch <= 0;
			branchNot <= 1;
			IF_Flush <= 1;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		else if (OpCode == 63)
		begin
			MemRead <=0;
			MemWrite <=0;
			RegWrite <=0;
			ALUSrc <= 1'b0;
			RegDest <= 1'b0;
			MemToReg <= 1'b0;
			ALUOp <= 0;
			finish <= 1;
			syscall <= 0;
			branch <= 0;
			branchNot <= 0;
			IF_Flush <= 0;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		else if (OpCode == 62) // syscall
		begin
			RegDest <=0;
			MemRead <=0;
			MemToReg <=0;
			MemWrite <=0;
			ALUSrc <=0;
			RegWrite <=0;
			ALUOp <= 0;
			finish <= 0;
			syscall <= 1;
			branch <= 0;
			branchNot <= 0;
			IF_Flush <= 0;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
		else
		begin
			RegDest <=0;
			MemRead <=0;
			MemToReg <=0;
			MemWrite <=0;
			ALUSrc <=0;
			RegWrite <=0;
			ALUOp <= 0;
			finish <= 0;
			syscall <= 0;
			IF_Flush <= 0;
			jump <= 0;
			jal <= 0;
			jumpR <= 0;
		end
	end
endmodule
