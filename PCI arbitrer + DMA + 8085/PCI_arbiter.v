module ARBITRER(
	input clk,
	input reqP,reqD,reqR,
	output reg gntP=0,gntD=0,gntR=0,
	output reg [0:1] AEN
	);
	
always @ (posedge clk)
begin
	if(reqP) 	  
	begin 
		gntP<=1;
		gntD<=0;
		gntR<=0;
		AEN<=0; 
	end
	else if(reqD) 
	begin 
		gntP<=0;
		gntD<=1;
		gntR<=0;
		AEN<=1; 
	end
	else if(reqR)
	begin 
		gntP<=0;
		gntD<=0;
		gntR<=1;
		AEN<=2;
 	end


end
endmodule 