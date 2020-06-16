module Hazard_detection(memHold, pcHold, IFFlush, memReadEX, rt_EX, rd_EX, rs_ID, rt_ID, opCode, clk);
output reg memHold = 0, pcHold = 0, IFFlush = 0;
input  memReadEX, clk;
input  [0:5] opCode;
input  [0:4] rt_EX, rd_EX, rs_ID, rt_ID;
reg flag = 0;

always @(posedge clk)
begin
	pcHold  <= 0;
	IFFlush <= 0;
	if(flag)
	begin
		pcHold <= 1;
		IFFlush <= 1;
		flag <= 0;
	end
	else if(opCode == 4)
	begin
		if(rd_EX == rs_ID || rd_EX == rt_ID)
		begin
			pcHold <= 1;
			IFFlush <= 1;
		end
		else if(rt_EX == rs_ID || rt_EX == rt_ID)
		begin
			pcHold <= 1;
			IFFlush <= 1;
			flag <= 1;
		end
	end
	else if(opCode == 0 || opCode == 43)
	begin
		if(rt_EX == rs_ID || rt_EX == rt_ID)
		begin
			if(memReadEX == 1)
			begin
				pcHold <= 1;
				IFFlush <= 1;
			end
		end
	end
	else 
	begin
		if(rt_EX == rs_ID)
		begin
			if(memReadEX == 1)
			begin
				pcHold <= 1;
				IFFlush <= 1;
			end
		end
	end

end

endmodule
