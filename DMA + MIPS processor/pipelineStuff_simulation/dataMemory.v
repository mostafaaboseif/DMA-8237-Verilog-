module DataMem(data,address,wData,read,write,PC,clk);
    output wire [31:0] data;
    input wire [31:0] wData;
    input wire [31:0] address;
    input wire read;
    input wire write;
    input wire [31:0] PC;
    input wire clk;
    reg [7:0] memory [0:32767];
    integer clk_Count = 0;
    assign data = (read) ? {memory[address+3],memory[address+2],memory[address+1],memory[address]} : 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    always @(negedge clk) begin
        if (write === 1) begin
            memory[address] = wData[7:0];
            memory[address + 1] = wData[15:8];
            memory[address + 2] = wData[23:16];
            memory[address + 3] = wData[31:24];
        end
    end
    always @(posedge clk)begin
        clk_Count = clk_Count + 1;
    end
endmodule
