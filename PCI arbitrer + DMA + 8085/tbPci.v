module aaaatb();
	wire [7:0] addressDMA;
	wire [15:0] address;
	wire  [7:0] data;
	wire  [15:0] bus;
	reg clk = 0;
        wire reset , HLDA ;
	wire DREQ ;
	reg MEM_OR_IO = 1; // 0: MEM is source 1: IO is source in IO/MEM Op
	wire MEM_TO_MEM;   // 1 if mem to mem op
	wire MEMR, MEMW, CS, HREQ, ADSTB, READY, READY_IO, IOR, IOW, demandEnd;
	wire DACK;
	wire [1:0]AEN;
	wire IOWP,MEMWP,IORP,MEMRP;
	wire DMA_OUT,DMA_IN;
	wire reqP,reqD,reqR,gntP,gntD,gntR;
	wire[7:0] a,d;
	assign CS = 1;
  	assign address[15:8] = (AEN==1)?data:8'bz;

						// AEN=1 : address and data are given from DMA
	                                         // AEN=2 : address from DMA and data from RAM
						   // AEN=3 : data is given from IO device
	DMA dma(bus,clk,reset,HLDA,READY,DREQ,MEMR,
					MEMW,DACK,HREQ,AEN,DMA_IN,IOR ,IOW,gntD,reqD);

	virtual_8085 pci_8085( clk,bus,reset,IOR,IOW,HLDA,DREQ,HREQ,DMA_IN,AEN,gntP,reqP);
	RAM ram(clk,MEMW,MEMR,AEN,bus,READY,gntR,reqR);
	ARBITRER arb (clk,reqP,reqD,reqR,gntP,gntD,gntR,AEN);
	
	
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
12DREQ[0] <= 1;
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


