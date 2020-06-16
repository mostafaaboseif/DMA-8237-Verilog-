`include "dma.v"
`include "io.v"
`include "ram.v"
`include "mips-1.v"
`include "processor.v"

module aatb();
	wire [7:0] addressDMA;
	wire [15:0] address;
	wire  [7:0] data;
	reg clk = 0;
        wire reset , HLDA ;
	wire [3:0]DREQ ;
	wire MEM_OR_IO ; // 0: MEM is source 1: IO is source in IO/MEM Op
	wire MEM_TO_MEM;   // 1 if mem to mem op
	wire MEMR, MEMW, CS, HREQ, ADSTB, READY, READY_IO, IOR, IOW, demandEnd;
	wire [3:0]DACK;
	wire [1:0]AEN;
	wire IOWP,MEMWP,IORP,MEMRP;
	wire DMA_OUT,DMA_IN;
	wire[7:0] a,d;
	assign CS = 1;
   	assign address[15:8] = (AEN==1)?data:8'bz;
	
						// AEN=1 : address and data are given from DMA
	                                         // AEN=2 : address from DMA and data from RAM
						   // AEN=3 : data is given from IO device
	DMA dma(address[7:0], data, clk, reset, CS, HLDA, 
		READY, READY_IO, DREQ, MEM_OR_IO, MEMR,
		MEMW, DACK, HREQ, AEN, ADSTB, DMA_OUT, 
		DMA_IN, demandEnd, IOR, IOW,IOWP,MEMWP,IORP,MEMRP, MEM_TO_MEM);
	RAM ram(clk, MEMW, MEMR, READY_IO, 
		MEM_TO_MEM, AEN,address, data, READY,MEMWP,MEMRP);
	IO io(clk, IOW, IOR, DACK, AEN, 
		READY, data, address, READY_IO,IOWP,IORP);
   	mips processor(demandEnd,MEM_OR_IO, AEN,clk,data,address,DMA_IN,
		DREQ, DACK, reset,IOWP,IORP,MEMWP,MEMRP,HLDA,HREQ);
/*initial
begin 
1reset <= 1;
2a[7:4] <= 4'b0110;
#5
3reset <= 0;
4DMA_IN <= 1;
5DREQ <= 0;
6a <= 0;
d <= 1;
#10
7a <= 0;
d <= 0;
#10
8a <= 1;
d <= 3;
#10
9a <= 1;
d <= 0;
#10
10a <= 8;
d <= 2;
#10
11a <= 11;
d <= 8'b10000000;
#10
12DREQ <= 1;
#10
HLDA <= 1;
#30
13DREQ[0] <= 0;
14DMA_IN <= 0;

end*/
always
begin
#5
clk=~clk;
end
endmodule
