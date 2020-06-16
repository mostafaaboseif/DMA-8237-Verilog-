module IO( 
input wire clk,
input wire IOW,
input wire IOR,
input wire DACK0,
input wire [1:0]AEN,
input READY_MEM,
inout [7:0] data,
inout [15:0] address,
output reg READY = 0,
input IOWP,input IORP);
reg [7:0] data_out; 
reg [15:0] addr ;
reg [15:0] addressOS;
reg [7:0] iomem [0:15];
reg flag = 0;
integer i = 0;
assign data = (AEN == 3) ? data_out : 8'bz;
assign address = (AEN == 3) ? addr : 16'bz;
integer clkCount = 0;
integer j = 0;
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
                if(IOWP===1) iomem[address] <= data;
		else if(IORP===1)data_out<= iomem[address];
		else if(IOR)
		begin
			if(flag == 0)
			begin
				flag <= 1;
				addr = i;
				data_out = iomem[addr];
				READY = 1;
			end
			else if(flag && READY_MEM)
			begin
				i = i + 1;
				if(i > 15)
					i = 0;
				flag <= 0;
				READY = 0;
			end
		end
		if(IOW)
		begin
			if(flag == 0)
			begin
				flag <= 1;
				READY <= 1;
				addr <= i;
                           
			end
			else if(flag == 1)
			begin
				i = i + 1;
				if(i > 15)
					i = 0;
              			READY <= 0;
				iomem[addr] <= data;
				$display("[IO]          clk: %0d, addr:%0d, value:%b",clkCount,addr,data);
				flag <= 0;
			end
		end
end


initial
begin

iomem[0]=0;
iomem[1]=1;
iomem[2]=2;
iomem[3]=3;
iomem[4]=4;
iomem[5]=5;
iomem[6]=6;
iomem[7]=7;
iomem[8]=8;
iomem[9]=9;
iomem[10]=10;
iomem[11]=11;
iomem[12]=12;
iomem[13]=13;
iomem[14]=14;
iomem[15]=15;
	$write("[IO Init]     ");
        for(j = 0; j < 16; j = j + 1)begin
            $write("%b, ",iomem[j]);
        end
        $write("\n");
end

endmodule

