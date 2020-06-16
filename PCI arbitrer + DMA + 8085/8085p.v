module virtual_8085 (clk,bus,reset,ior,iow,hlda,dreq0,hrq,dma_in,AEN,gntP,reqP);

	input clk;
	inout [15:0] bus;
	output reg  reset , ior , iow , hlda , dreq0,dma_in ;
	input  hrq;
	input [1:0] AEN;
	input gntP;
	output reg reqP=0;
	
	reg outflag ;
	reg  [15:0]  busP;	
	reg  [31:0] Imem [0:31];
	reg  [31:0] regfile [0:31];
	reg  [31:0] pc;
	reg  [31:0] current_inst;
	reg  [7 :0] accumulator;
	integer i ;

	initial
	begin
		outflag <= 0;
		pc <= 0 ;
		i <=0;
 		Imem[0]=32'h3000_0000;  //reset
 		Imem[1]=32'h3C00_000D;  
 		Imem[2]=32'h2800_000D;	//***A(car[0])=d
		Imem[3]=32'h2C00_0000;	//OUT address of car[0]
		Imem[4]=32'h2C00_0000;	//OUT data of car[0]
		Imem[5]=32'h2800_0004;  //***A(car[1])=4
		Imem[6]=32'h2C00_0002;  //OUT address of car[1]
		Imem[7]=32'h2C00_0002;  //
		Imem[8]=32'h2800_0005;  //***A(ccr[1])=2
		Imem[9]=32'h2C00_0003;  //address ccr[1]
		Imem[10]=32'h2C00_0003; //data ccr[1]
		Imem[11]=32'h2800_0001; //A(command)=1
		Imem[12]=32'h2C00_0008; //
		Imem[13]=32'h2C00_0008; //
		Imem[14]=32'h3400_0000;  //DREQ
		Imem[15]=32'h3500_0000;  // !DREQ
		Imem[16]=32'hFF00_0001;  // add
		Imem[17]=32'hFF00_0001;  // add
		Imem[18]=32'hFF00_0001;  // add
		Imem[19]=32'hFF00_0001;  // add
		Imem[20]=32'hFF00_0001;  // add
		Imem[21]=32'hFF00_0001;  // add

		Imem[25]=32'hFFFF_FFFF;

		regfile[0]=32'h0000_0001;
		regfile[1]=32'h0000_0002;
		regfile[2]=32'h0000_0003;
		regfile[3]=32'h0000_0004;
		regfile[4]=32'h0000_0005;
		regfile[5]=32'h0000_0006;
		regfile[6]=32'h0000_0000;
		
	end

	assign bus = (AEN==0)? busP : 8'bzz;

	always @ (posedge clk)
	begin
		current_inst <= Imem[pc];
		if(hrq) hlda<=1;
		if(~(&current_inst))
		begin
		   if(reqP&&!gntP) 
			pc <= pc-1 ;			
		   pc <= pc+1 ;
		   if(gntP)reqP<=0;
		   
        	if ( (current_inst[31:24]==8'hFF) && (current_inst[7:0]==8'h01) )
        	begin
         		regfile[6]<=regfile[6]+regfile[i];
			i<=i+1;
		end
		else if ( current_inst[31:24] == 8'h3C )
		begin
			reqP<=1;
		end
		else if ( current_inst[31:24] == 8'h28 )
		begin
			  accumulator <= current_inst[7:0];
		end
		else if ( current_inst[31:24] ==  8'h2C )
		begin
			if(outflag ==0)
			begin
				busP <= current_inst[15:0];
				dma_in <= 1;			
				dreq0 <= 0 ;
				reset <= 0;
				outflag<=1;
			end
				
			if(outflag ==1)
			begin
				busP <= accumulator;		
				iow <= 1 ;
				outflag<=0;
			end
		end
		else if ( current_inst[31:24] == 8'h34)
	        begin
        		dreq0 <= 1;
        	end
		else if ( current_inst[31:24] == 8'h35)
	        begin
        		dreq0 <= 0;
        	end
       		else if (current_inst[31:24]== 8'h30)
        	begin
          		 //DREQ0 = 0, HLDA = 0,EOP=0
			reset <= 1;
        		dreq0<=0;
			hlda<=0;
      		 	iow <= 0;
        	end
				
     	 end
    	end

 endmodule

