module RAM(
input clk,
input MEMW,
input MEMR,
input [1:0] AEN,
inout[15:0] bus,
output reg READY = 0,
input gntR,
output reg reqR
);

reg [7:0] mem [0:20];
reg [1:0] flag=0;
reg [15:0] adr,busR;

assign bus = (AEN == 2) ? busR : 8'bz;

initial
begin
mem[0]=0;
mem[1]=1;
mem[2]=2;
mem[3]=3;
mem[4]=4;
mem[5]=5;
mem[6]=6;
mem[7]=7;
mem[8]=8;
mem[9]=9;
mem[10]=10;
mem[11]=11;
mem[12]=12;
mem[13]=13;
mem[14]=14;
mem[15]=15;
mem[16]=16;
mem[17]=17;
mem[18]=18;
mem[19]=19;
end

always @ (posedge clk)
begin
if (MEMW)
begin 
	if(flag==0)
	begin
		READY <= 1;
		adr <= bus;		
		flag <= 1;
	end
	else if(flag == 1)
	begin
		READY <= 0;
		mem[adr] <= busR;
		flag <= 0;
	end
end
else if (MEMR) 
begin
	if(flag==0)
	begin
		reqR<=1;
		adr = bus;
		flag<=1;
	end	
	else if(flag==1)
	begin
	if(gntR)
		begin
			reqR <=0 ;
			busR = mem[adr];
			READY = 1;
			flag <= 2;	
		end
	end
	else if(flag==2)
	begin
		flag <= 0;
		READY = 0;
		
	end
	/*else
	begin
		flag <= 0;
		READY <= 0;
	end*/

end
end

endmodule
