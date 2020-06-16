module mips(output reg demand ,output reg MEM_OR_IO,input [1:0]AEN ,input clk,inout[7:0]data,inout [15:0]address,output reg DMA_IN,output reg [3:0]DREQ, input [3:0] DACK,output reg reset,output reg IOW,output reg IOR,output reg MEMW,output reg MEMR,output reg HLDA,input HRQ);

    reg [7:0]d;
    reg [15:0]a;
    reg [31:0] PC = 0;    
    wire [31:0] PCwire = 0;
    wire [31:0] ins;
    wire [5:0] OpCode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] func;
    wire [15:0] imValue;
    wire [31:0] jump_label;
    wire MemToRegControl;
    wire [4:0] writeRegAdress;
    wire [4:0] mux1Out;
    wire [31:0] reg1Data;
    wire [31:0] mux2Out;
    wire [31:0] reg2Data;
    wire [31:0] immediateValue32;
    wire [31:0] in_alu;
    wire zero;
    wire [31:0] alu_output;
    wire [31:0] data_memory_data;
    wire [31:0] regFile_writeData;
    wire regDstC;
    wire Jump;
    wire JumpR;
    wire Jal;
    wire Branch;
    wire BranchNot;
    wire memReadC;
    wire memToRegC;
    wire sysCallC;
    wire [3:0] aluOpC;
    wire memWriteC;
    wire aluSrcC;
    wire regWriteC;
    wire [3:0] aluControlOutput;
    wire pcBranchSel;
    wire [31:0] branchRelativeValue;
    wire [31:0] pcNewValue;
    wire [31:0] pcBranchOut;
    integer clk_Count = 0;
	reg storeRF,storeDM;
	wire memWriteCx;
	wire regWriteCx;
	wire [31:0] alu_outputx;
        wire [31:0] regFile_writeDatax;
	wire [4:0] writeRegAdressx;
	wire [31:0] reg2Datax;

    ALU alu(reg1Data, in_alu, aluControlOutput, alu_output, shamt, zero);
    ALUControl alu_control(aluOpC, func, aluControlOutput);
    Control controlUnit(OpCode, func, regDstC, Branch, BranchNot, memReadC, memToRegC, aluOpC, memWriteC, aluSrcC, regWriteC, Jump, JumpR, Jal, sysCallC);
    RegFile regFile(reg1Data,reg2Data,regWriteCx,rs,rt,writeRegAdressx,regFile_writeDatax,clk,PC);
    DataMem data_memory(data_memory_data,alu_outputx,reg2Datax,memReadC,memWriteCx,PC,clk);
    InstMem insMemory(ins,PC[14:0]);
    Mux_5 regDist4_1(mux1Out,regDstC,rt,rd);
    Mux_5 regDist4_2(writeRegAdress,Jal,mux1Out, 5'b11111);
    Mux_32 memToReg(mux2Out, memToRegC, alu_output, data_memory_data);
    Mux_32 dataORjal(regFile_writeData,Jal,mux2Out,PC+4);
    Mux_32 aluSrc(in_alu,aluSrcC,reg2Data,immediateValue32);
    sysCall sys_call(sysCallC,reg1Data,reg2Data,clk,PC);
    SignExtend immediateValue(immediateValue32,imValue);
    assign address = (AEN==0)? a:8'bz;  // AEN=0 : address and data are given from processor
    assign data =  (AEN==0)?d:8'bz;

    assign regWriteCx=(storeRF)?1:regWriteC;
    assign memWriteCx=(storeDM)?1:memWriteC;
    assign alu_outputx=(storeDM)?imValue:alu_output;
    assign regFile_writeDatax=(storeRF)?data:regFile_writeData;
    assign reg2Datax=(storeDM)?data:reg2Data;
    assign writeRegAdressx=(storeRF)?imValue[4:0]:writeRegAdress;
    assign OpCode = ins[31:26];
    assign rs = ins[25:21];
    assign rt = ins[20:16];
    assign rd = ins[15:11];
    assign shamt = ins[10:6];
    assign func = ins[5:0];
    assign imValue = {rd,shamt,func};
    assign pcBranchSel = zero & Branch;
    assign pcNewValue = PC + 4;
    assign jump_label = {PC[31:28],rs,rt,rd,shamt,func} << 2; 
    assign branchRelativeValue = PC + 4  + (immediateValue32 << 2);
 
       initial
 begin
storeRF<=0;
storeDM<=0;
IOW<=0;
IOR<=0;
MEMW<=0;
MEMR<=0; 
end 
always @(negedge clk)
begin
storeRF<=0;
storeDM<=0;
if(HRQ==0) 
begin 
if(OpCode==49) begin
 storeDM<=1;
$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);

 end

if(OpCode==58) begin 
storeRF<=1; 
$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
end 
if(OpCode==39) begin
	d<=reg1Data[7:0];
	$display("[Bus]         clk: %0d, regValue:%0d",clk_Count,reg1Data[7:0]);		//LDBus $regname
	$display("[Bus]         clk: %0d, addr:%0d",clk_Count,a);
	$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
end

end
end

always @(posedge clk) begin
if(OpCode==38) begin
			demand<=1;
$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
 end
	//$display("Hreq : %0d",HRQ);
	$display("AEN Processor : %0d clk: %0d",AEN,clk_Count);
	//$display("ADDR : %0d",address);
	if(HRQ) HLDA<=1;
	if(HRQ==0) begin
		
	        if(OpCode==37) begin
			demand<=0; end
		if(OpCode==60)begin
			MEM_OR_IO<=1;
			//$display("here");
			$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
		end
		if(OpCode==61) begin
			MEM_OR_IO<=0;
			$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
		end
		if(OpCode==59) begin 
			a<=imValue;
			d<=ins[23:16];
			$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
		end	
		if(OpCode==50) begin 
			a<=imValue;
			$display("op 50 imvalue : %0d",imValue);
			$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
		end
        if(OpCode==51) begin
		d<=ins[7:0];				//LDBussi
		$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
	end
    	//if(OpCode==52) begin DREQ <=1; end
	//if(OpCode==53) begin DREQ <=0; end
	if(OpCode==54) begin 
		reset<=1;
		$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
	end if(OpCode==55) begin
		 reset<=0;
		 $display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
	end
	//if(OpCode==56) begin DMA_IN<=1; end 
	//if(OpCode==57) begin DMA_IN<=0; end
	if(OpCode==40) begin
		IOW<=1;
		$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
	end
	if(OpCode==41) begin
		IOR<=1;
		$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
	end
	if(OpCode==42) begin
		MEMW<=1;
		$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
	end if(OpCode==48) begin
		MEMR<=1;
		$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
	end if(OpCode==44) begin
		IOW<=0;
		$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
	end if(OpCode==45) begin
		IOR<=0;
		$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
	end if(OpCode==46) begin
		MEMW<=0;
		$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
	end if(OpCode==47) begin 
		MEMR<=0; 
		$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
	end
	if(OpCode==49) begin 
		storeDM<=1; 
		$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);	
	end
	if(OpCode==58) begin 
		storeRF<=1; 
		//$display("[Reg File 3]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
	end
	
	else HLDA<=0;
end
if(OpCode==52) begin 
	DREQ <= ins[3:0]; 
	$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
end
//if(OpCode==53) begin DREQ <=0; 
//$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
//end
if(OpCode==56) begin DMA_IN<=1; 
$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
end 
if(OpCode==57) begin DMA_IN<=0; 
$display("[Reg File]    clk: %0d, PC:%0d, regNumber:0, regValue:00000000000000000000000000000000",clk_Count,PC);
end

    clk_Count <= clk_Count + 1;
    if(Branch)begin
        $display("[branch]      clk: %0d, PC:%0d",clk_Count, PC);
    end
    if(BranchNot)begin
        $display("[branch]      clk: %0d, PC:%0d",clk_Count, PC);
    end
	if(Jump) begin
		PC <= jump_label;
        $display("[branch]      clk: %0d, PC:%0d",clk_Count, PC);
	end
	else if (Branch & zero) begin
		PC <= branchRelativeValue;
	end
	else if (BranchNot & (!zero)) begin
        PC <= branchRelativeValue;
	end
	else if (Jal) begin
        PC <= jump_label;
	end
	else if (JumpR) begin
		PC <= reg1Data;
        $display("[branch]      clk: %0d, PC:%0d",clk_Count, PC);
	end
	else begin
        	PC <= PC + 4;
    	end
	if(DREQ != 0)
	begin
		if(DACK[0])
			DREQ[0] <= 0;
		if(DACK[1])
			DREQ[1] <= 0;
		if(DACK[2])
			DREQ[2] <= 0;
		if(DACK[3])
			DREQ[3] <= 0;
	end
    end
endmodule

