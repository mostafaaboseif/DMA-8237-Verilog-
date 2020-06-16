module DMA(inout [15:0] bus,
	input clk,reset,HLDA,READY,
	input DREQ,
	output reg MEMR = 0,MEMW = 0,DACK = 0,HREQ = 0,
	input [1:0] AEN,
	input DMA_IN,
	output reg  IOR ,IOW,
	input gntD,
	output reg reqD =0
);
parameter SI=4'b0000,S0=4'b0001,
S11=4'b0010,S12=4'b0011,S13=4'b0100,S14=4'b0101,
S21=4'b0110,S22=4'b0111,S23=4'b1000,S24=4'b1001;
reg [7:0] command,status,temporary;
reg[3:0] mask,request;
reg[5:0] mode [0:3];
reg[15:0] car[0:3];
reg[15:0] ccr[0:3];
reg[3:0] currentState, nextState;
reg flag = 0, i = 0, temp = 0;
reg [15:0] busD;
reg [7:0] a,d,data;
reg [15:0] addr;
assign bus = (AEN == 1) ? busD : 8'bz;

always@(DREQ, HLDA,bus,DMA_IN, currentState, READY,gntD)
begin
	casez(currentState)
	SI:
	begin
	if(DREQ)
	begin
		nextState <= S0;
		HREQ <= 1;
	end
	else
	begin
		nextState = SI;
		if(DMA_IN)
		begin
		if(flag==0)
			begin addr<=bus;flag<=1; end
		else if (flag ==1)
			begin
			casez(addr[3:0])
				0:	car[0]<=bus;
				1:	ccr[0]<=bus;
				2:	car[1]<=bus;
				3:	ccr[1]<=bus;
				8:	command <= bus;
				endcase
			flag<=0;
			end
		end
	end
	end
	S0:
	begin
		if(HLDA == 0)
			nextState <= S0;
		else
		begin
			if(command[0])
				nextState <= S11; //memory to memory
//			else if(command[0] == 0)
	//			nextState <= S1;  //IO to memory or memory to IO
		end
	end
	S11:
	begin
		DACK <= 1;
		reqD <= 1;
		if(gntD) begin nextState <= S12;reqD<=0; end
	end
	S12:
	begin
		MEMR <= 1;
		busD <= car[0];
		nextState <= S13;
	end
	S13:
	begin
		if(READY)
		begin
			temporary <= bus;
			nextState <= S14;
		end
		else
		begin
			nextState <= currentState;
		end
	end
	S14:
	begin
		MEMR<=0;
		nextState <= S21;
	end
	S21:
	begin
		reqD <= 1;
		if(gntD) 
		begin 
		nextState <= S22;
		reqD<=0; 
		end
	end
	S22:
	begin
		MEMW <= 1;
		busD <= car[1];
		nextState <= S23;
	end
	S23:
	begin
		if(READY)
		begin
			busD <= temporary;
			nextState <= S24;
		end
		/*else
		begin

			nextState <= S24;
		end*/
	end
	S24:
	begin
		MEMW <= 0;		
		if(ccr[1] == 0)
		begin
			ccr[1] <=1;
			nextState <= SI;
		end
		else
		begin
			nextState <= S11;
			car[0] = car[0] + 1;
			car[1] = car[1] + 1;
		end
		ccr[1] = ccr[1] - 1;
	end
endcase
end
always@(posedge clk)
begin
	if(reset)
	begin
		currentState <= SI;
		command <= 0 ; status <= 0; temporary <= 0; mask <= 0; request <= 0;
		mode[0] <= 0;  car[0] <= 0; ccr[0] <= 0;
		mode[1] <= 0;  car[1] <= 0; ccr[1] <= 0;
		mode[2] <= 0;  car[2] <= 0; ccr[2] <= 0;
		mode[3] <= 0;  car[3] <= 0; ccr[3] <= 0;
	end
	else
		 currentState <= nextState;
end
endmodule




