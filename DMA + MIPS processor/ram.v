module RAM(
input clk,
input MEMW,
input MEMR,
input READY_IO, MEM_TO_MEM,
input [1:0] AEN,
input[15:0] address,
inout [7:0] data,
output reg READY = 0
,input MEMWP,input MEMRP);

reg [7:0] data_out;
reg [7:0] mem [0:15];
reg [1:0] flag=0;
reg [15:0] adr;
integer clkCount = 0;
integer i = 0;
reg [15:0]addressOS;
assign data = (MEMRP==1) ? data_out : 8'bz;
// assign address = (AEN == 2) ? adr : 8'bz;
assign data = (AEN == 2) ? data_out : 8'bz;
assign address = (AEN == 2) ? adr : 16'bz;

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
	$write("[Ram Init]    ");
        for(i = 0; i < 16; i = i + 1)begin
            $write("%b, ",mem[i]);
        end
        $write("\n");
end
always @( negedge clk)
	begin
	if(MEMWP===1) begin
		 mem[address] <= data;
		$display("[RAM]         clk: %0d, addr:%0d, value:%b",clkCount,address,data);
	end
	else if(MEMRP===1) begin 
		data_out <= mem[addressOS];
		$display("rammmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm value %0d clk: %0d",mem[addressOS],clkCount );
	end
	addressOS<=address;
	end
always @ (posedge clk)
begin
clkCount = clkCount + 1;
if (MEMW) begin 
	if(flag == 0)
	begin
		$display("flag = 0 ==================================================================================== addr : %0d",adr);
		READY = 1;
		adr <= address;

		flag <= 1;
	end
	else if(flag && (READY_IO || MEM_TO_MEM))
	begin
		READY <= 0;
		mem[adr] <= data;
		$display("[RAM]         clk: %0d, addr:%0d, value:%b",clkCount,adr,data);
		flag <= 0;
	end
end
else if (MEMR) 
begin
	if(flag==0)
	begin
		flag <= 1;
		adr = address;
		data_out = mem[adr];
		READY = 1;
	end
	else if(flag && (READY_IO || MEM_TO_MEM))
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
