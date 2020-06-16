module DMA(inout [7:0] address,data,
	input clk,
	input reset,
	input CS,
	input HLDA,
	input READY,
	input READY_IO,
	input [3:0]DREQ, MEM_OR_IO,
	output reg MEMR = 0,
	output reg MEMW = 0,
	output reg [3:0]DACK = 0,
	output reg HREQ = 0,
	output reg [1:0] AEN = 0,
	output reg ADSTB = 0,
	input DMA_OUT,
	input DMA_IN, 
	input demandEnd,
	output reg  IOR ,
	output reg IOW ,
	input IOWP,
	input MEMWP,
	input IORP,
	input MEMRP,
	output MEM_TO_MEM
);
parameter SI=4'b0000,S0=4'b0001,
S11=4'b0010,S12=4'b0011,S13=4'b0100,S14=4'b0101,S21=4'b0110,S22=4'b0111,S23=4'b1000,S24=4'b1001,
S1=4'b1010,S2=4'b1011,S4=4'b1110;
reg [7:0] command,status,temporary;
reg[3:0] mask,request;
reg[5:0] mode [0:3];
reg[15:0] car[0:3];
reg[15:0] ccr[0:3];
reg[3:0] currentState, nextState;
reg flag = 0, temp = 0;
reg [7:0] a , d;
reg source, dest, req;
reg [1:0]Priority[0:3];
assign address = (AEN == 1) ? a : 8'bz;
assign data    = (AEN == 1) ? d : 8'bz;
assign MEM_TO_MEM = command[0];
integer clkCount = 0, i = 0;
always@(posedge clk)
begin
if(IORP)  AEN <= 3;
if(MEMRP) AEN <= 2;
end
//assign EOPin = ((!ccr[0]&&mask[0])|(!ccr[1]&&mask[1])|(!ccr[2]&&mask[2])|(!ccr[3]&&mask[3]))? 1 : 0;
initial
begin
	Priority[0] = 0;
	Priority[1] = 1;
	Priority[2] = 2;
	Priority[3] = 3;
end

always@(DREQ, HLDA, data, address, DMA_OUT, DMA_IN, currentState, READY, READY_IO, IOR, IOW)
begin
	casez(currentState)
	SI:
	begin
		$display("[DMA]         clk: %0d, addr:STATE, value:Idle State",clkCount);
		AEN = 0;
		if(CS)
		begin
			if(DREQ != 0)
			begin
				if(command[4] == 0) // Fixed Priority
				begin
					if(DREQ[0] && !mask[0])
					begin
						source <= 0;
						dest <= 1;
					end
					else if(DREQ[1] && !mask[1])
					begin
						source <= 1;
						dest <= 2;
					end
					else if(DREQ[2] && !mask[2])
					begin
						source <= 2;
						dest <= 3;
					end
					else if(DREQ[3] && !mask[3])
					begin
						source <= 3;
						dest <= 0;
					end
				end
				else			  // Rotating Priority
				begin
					if(DREQ[Priority[0]] && !mask[Priority[0]])
					begin
						source <= Priority[0];
						dest <= Priority[0] + 1;
						req = 0;
					end
					else if(DREQ[Priority[1]] && !mask[Priority[1]])
					begin
						source <= Priority[1];
						dest <= Priority[1] + 1;
						req = 1;
					end
					else if(DREQ[Priority[2]] && !mask[Priority[2]])
					begin
						source <= Priority[2];
						dest <= Priority[2] + 1;
						req = 2;
					end
					else if(DREQ[Priority[3]] && !mask[Priority[3]])
					begin
						source <= Priority[3];
						dest <= Priority[3] + 1;
						req = 3;
					end
					if(dest == 4)
						dest <= 0;
				end
				nextState <= S0;
				HREQ <= 1;
			end 
			else 
			begin
				nextState = SI;
				HREQ <= 0;
				if(DMA_IN)
				begin
					casez(address[3:0])
						0, 1, 2, 3, 4, 5, 6, 7:
						begin
							if(address[3:0] % 2 == 0)
							begin
								if(flag == 0)
								begin
									if(mode[address[3:0] / 2][2])
									begin
										car[address[3:0] / 2][7:0] <= data;
										$display("[DMA]         clk: %0d, type : INIT_REG, addr:LOWER_CAR%0d, value:%b",clkCount,address[3:0] / 2,data);
										flag = 1;
									end
								end
								else
								begin
									car[address[3:0] / 2][15:8] <= data;
									$display("[DMA]         clk: %0d, type : INIT_REG, addr:UPPER_CAR%0d, value:%b",clkCount,address[3:0] / 2,data);
									flag = 0;
								end
							end
							else
							begin
								if(flag == 0)
								begin
									ccr[address[3:0] / 2][7:0] <= data;
									$display("[DMA]         clk: %0d, type : INIT_REG, addr:LOWER_CCR%0d, value:%b",clkCount,address[3:0] / 2,data);
									flag = 1;
								end
								else
								begin
									ccr[address[3:0] / 2][15:8] <= data;
									
									$display("[DMA]         clk: %0d, type : INIT_REG, addr:UPPER_CCR%0d, value:%b",clkCount,address[3:0] / 2,data);
									flag = 0;
								end
							end
						end
						8:
							begin
							command <= data;
							
							$display("[DMA]         clk: %0d, type : INIT_REG, addr:COMMAND, value:%b",clkCount,data);
							end
						9:
						begin
							request <= data;
							
							$display("[DMA]         clk: %0d, type : INIT_REG, addr:REQUEST, value:%b",clkCount,data);
						end
						10:
						begin
							mask <= data;
							
							$display("[DMA]         clk: %0d, type : INIT_REG, addr:MASK, value:%b",clkCount,data);
						end
						11:
						begin
							mode[data[1:0]] <= data[7:2];
							$display("[DMA]         clk: %0d, type : INIT_REG, addr:MODE%0d, value:%b",clkCount,data[1:0],data[7:2]);
						end		
						//software commands to be added
					endcase
				end
			end
		end
	end
	S0:
	begin
		$display("[DMA]         clk: %0d, addr:STATE, value:S0",clkCount);
		if(HLDA == 0) 
			nextState <= S0;
		else 
		begin 
			if(command[0])
				nextState <= S11; //memory to memory
			else if(command[0] == 0)
				nextState <= S1;  //IO to memory or memory to IO
		end
	end
	S1:
	begin
		$display("[DMA]         clk: %0d, addr:STATE, value:S1 (IO/MEM)",clkCount);
		AEN = 1;
		DACK[source] <= 1;
		a <= car[source][7:0];
		d <= car[source][15:8];
		nextState <= S2;
	end
	S2:
	begin
		$display("[DMA]         clk: %0d, addr:STATE, value:S2",clkCount);
		if(MEM_OR_IO) // IO to Memory
		begin
			IOR <= 1;
			if(READY_IO)
			begin
				$display("io ready");
				AEN = 1;
				a <= car[source][7:0];
				d <= car[source][15:8];
				MEMW = 1;
			end 
			if(READY)
			begin
				$display("mem ready");
				AEN = 3;
				nextState <= S4;
			end
		end
		else 			   // Memory to IO
		begin
			MEMR <= 1;
			if(READY)
			begin
				IOW = 1;
			end 
			if(READY_IO)
			begin
				AEN = 2;
				nextState <= S4;
			end
		end
	end
	S4:
	begin
		$display("[DMA]         clk: %0d, addr:STATE, value:S4",clkCount);
		MEMR = 0;
		IOW = 0;
		MEMW = 0;
		IOR = 0;
		case(mode[source][5:4])
			0: // Demand
			begin
				if(demandEnd == 0)
				begin
					nextState = S1;
					if(mode[source][3] == 0) 		  // increment
						car[source] = car[source] + 1;
					else				  // decrement
						car[source] = car[source] - 1;
				end
				else if(demandEnd)
				begin
					DACK[source] <= 0;
					nextState = SI;
					if(command[4]) // Rotating Priority
					begin
						for(i = req; i < 3; i = i + 1)
						begin
							temp = Priority[i];
							Priority[i] = Priority[i + 1];
							Priority[i + 1] = temp;
						end
					end
				end
			end
			1: // Single
			begin
				DACK[source] <= 0;
				nextState <= SI;
				if(command[4]) // Rotating Priority
				begin
					for(i = req; i < 3; i = i + 1)
					begin
						temp = Priority[i];
						Priority[i] = Priority[i + 1];
						Priority[i + 1] = temp;
					end
				end
			end
			2: // Block
			begin
				ccr[source] = ccr[source] - 1;
				$display("[DMA]         clk: %0d, type : INIT_REG, addr:CCR%0d, value:%b",clkCount,source,ccr[source]);
				if(ccr[source] == 0)
				begin
					DACK[source] <= 0;
					nextState <= SI;
					if(command[4]) // Rotating Priority
					begin
						for(i = source; i < 3; i = i + 1)
						begin
							temp = Priority[i];
							Priority[i] = Priority[i + 1];
							Priority[i + 1] = temp;
						end
					end
				end
				else
				begin
					nextState = S1;
					if(mode[source][3] == 0) begin		  // increment
						car[source] = car[source] + 1;
						$display("[DMA]         clk: %0d, type : INIT_REG, addr:CCR%0d, value:%b",clkCount,source ,car[source]);
					end else begin				  // decrement
						car[source] = car[source] - 1;
						$display("[DMA]         clk: %0d, type : INIT_REG, addr:CCR%0d, value:%b",clkCount,source ,car[source]);
					end				
				end
			end
		endcase
	end
	S11:
	begin
		$display("[DMA]         clk: %0d, addr:STATE, value:S11 (MEM/MEM)",clkCount);		
		DACK[source] <= 1;
		AEN <= 1;
		nextState <= S12;
	end
	S12:
	begin
		$display("[DMA]         clk: %0d, addr:STATE, value:S12",clkCount);		
		MEMR <= 1;
		a <= car[source][7:0];
		d <= car[source][15:8];
		nextState <= S14;
	end
	S14:
	begin
		if(!READY) begin
			$display("[DMA]         clk: %0d, addr:STATE, value:S14",clkCount);
			AEN = 2;
			temporary <= data;
			MEMR<=0;
			nextState <= S21;
		end
		else
		begin
			nextState <= currentState;
		end 
	end
	S21:
	begin
		$display("[DMA]         clk: %0d, addr:STATE, value:S21",clkCount);
		AEN <= 1;
		nextState <= S22;
	end
	S22:
	begin
		$display("[DMA]         clk: %0d, addr:STATE, value:S22",clkCount);
		MEMW <= 1;
		a <= car[dest][7:0];
		d <= car[dest][15:8];
		nextState <= S23;
	end
	S23:
	begin
		$display("[DMA]         clk: %0d, addr:STATE, value:S23",clkCount);
		if(READY)
		begin
			d <= temporary;
			nextState <= S24;
		end
		/*else
		begin
			
			nextState <= S24;
		end*/
	end	
	S24:
	begin
		$display("[DMA]         clk: %0d, addr:STATE, value:S24",clkCount);
		MEMW <= 0;
		case(mode[source][5:4])
		0: // Demand
		begin
			if(!demandEnd)
			begin
				nextState = S11;
				if(mode[source][3] == 0) 		  // increment
					car[source] = car[source] + 1;
				else				  // decrement
					car[source] = car[source] - 1;
				if(mode[dest][3] == 0)   	  // increment
					car[dest] = car[dest] + 1;
				else				  // decrement
					car[dest] = car[dest] - 1;
			end
			else
			begin
				DACK[source] <= 0;
				nextState = SI;
				if(command[4]) // Rotating Priority
				begin
					for(i = source; i < 3; i = i + 1)
					begin
						temp = Priority[i];
						Priority[i] = Priority[i + 1];
						Priority[i + 1] = temp;
					end
				end
			end
		end
		1: // Single
		begin
			DACK[source] <= 0;
			nextState <= SI;
			if(command[4]) // Rotating Priority
			begin
				for(i = source; i < 3; i = i + 1)
				begin
					temp = Priority[i];
					Priority[i] = Priority[i + 1];
					Priority[i + 1] = temp;
				end
			end
		end
		2: // Block
		begin
			ccr[dest] = ccr[dest] - 1;
			$display("[DMA]         clk: %0d, type : INIT_REG, addr:CCR%0d, value:%b",clkCount,dest,ccr[1]);
			if(ccr[dest] == 0)
			begin
				DACK[source] <= 0;
				nextState <= SI;
				if(command[4]) // Rotating Priority
				begin
					for(i = source; i < 3; i = i + 1)
					begin
						temp = Priority[i];
						Priority[i] = Priority[i + 1];
						Priority[i + 1] = temp;
					end
				end
			end
			else
			begin
				nextState <= S11;
				if(mode[source][3] == 0) begin
					car[source] = car[source] + 1;
					$display("[DMA]         clk: %0d, type : INIT_REG, addr:CAR%0d, value:%b",clkCount,source ,car[source]);
				end else begin
					car[source] = car[source] - 1;
					$display("[DMA]         clk: %0d, type : INIT_REG, addr:CAR%0d, value:%b",clkCount,source ,car[source]);
				end if(mode[dest][3] == 0) begin
					car[dest] = car[dest] + 1;
					$display("[DMA]         clk: %0d, type : INIT_REG, addr:CAR%0d, value:%b",clkCount,dest ,car[dest]);
				end else begin
					car[dest] = car[dest] - 1;
					$display("[DMA]         clk: %0d, type : INIT_REG, addr:CAR%0d, value:%b",clkCount,dest ,car[dest]);
				end			
			end
		end
		endcase
	end
	

	endcase
end
/*
always@(SWCommand)
begin
	case(SWCommand)
		0:	// reset
		begin
			currentState <= SI;
			command <= 0 ; status <= 0; temporary <= 0; mask <= 0; request <= 0;
			mode[0] <= 0;  car[0] <= 0; ccr[0] <= 0;
			mode[1] <= 0;  car[1] <= 0; ccr[1] <= 0;
			mode[2] <= 0;  car[2] <= 0; ccr[2] <= 0;
			mode[3] <= 0;  car[3] <= 0; ccr[3] <= 0;
		end
		1:
		begin
			mask = 4'b0000;
		end

	endcase
end
*/
always@(posedge clk)
begin
	clkCount = clkCount + 1;
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
