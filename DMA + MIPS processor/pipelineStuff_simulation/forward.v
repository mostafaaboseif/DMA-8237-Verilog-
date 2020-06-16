module ForwardUnit(upperMuxSel, lowerMuxSel, rs_EX, rt_EX, regFileWriteAddr_MEM, regFileWriteAddr_WB, regWriteC_EX, regWriteC_MEM, clk);
	input wire [4:0] rs_EX;
    input wire [4:0] rt_EX;
    input wire [4:0] regFileWriteAddr_MEM;                   // addr of write register in exceute stage
    input wire [4:0] regFileWriteAddr_WB;                  // addr of write register in memory stage
	input wire regWriteC_EX;                                // register write control signal in execute stage
    input wire regWriteC_MEM;                               // register write control signal in memory stage
	input wire clk;
    output reg [1:0] upperMuxSel;
    output reg [1:0] lowerMuxSel;

	always @(negedge clk) begin
        upperMuxSel <= 0;
        lowerMuxSel <= 0;
        if(regFileWriteAddr_MEM == rs_EX) begin
            upperMuxSel <= 2;
            // $display("Forwarding happend for rs #1");
        end else if(regFileWriteAddr_WB == rs_EX) begin
            upperMuxSel <= 1;
            // $display("Forwarding happend for rs #2");
        end

        if(regFileWriteAddr_MEM == rt_EX) begin
            lowerMuxSel <= 2;
            // $display("Forwarding happend for rt #1");
        end else if(regFileWriteAddr_WB == rt_EX) begin
            lowerMuxSel <= 1;
            // $display("Forwarding happend for rt #2");
        end
    end
endmodule
