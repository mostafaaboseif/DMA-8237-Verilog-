module B_Forward(regEqulityC,reg1Data,reg2Data,rs_ID,rt_ID,regFileWriteAddr_EX,regFileWriteAddr_MEM,
                alu_output_EX,alu_output_MEM, clk);
    output reg regEqulityC;
    input wire [31:0] reg1Data;
    input wire [31:0] reg2Data;
    input wire [31:0] alu_output_EX;
    input wire [31:0] alu_output_MEM;
    input wire [4:0] rs_ID; 
    input wire [4:0] rt_ID; 
    input wire [4:0] regFileWriteAddr_EX; 
    input wire [4:0] regFileWriteAddr_MEM;
    input wire clk;
    reg [31:0] data1;
    reg [31:0] data2;

    always @(negedge clk)begin
        data1 = reg1Data;
        data2 = reg2Data;
        // $display("Branch Forward UNIT ..");
        // $display("rs : %0d, rt : %0d, writeEX : %0d, writeMEM : %0d", rs_ID, rt_ID, regFileWriteAddr_EX, regFileWriteAddr_MEM);
        // $display("rs value : %0d, rt value : %0d, ex : %0d, mem : %0d",reg1Data, reg2Data, alu_output_EX, alu_output_MEM);
        if(rs_ID == regFileWriteAddr_EX)begin
            data1 = alu_output_EX;
        end else if(rs_ID == regFileWriteAddr_MEM) begin
            data1 = alu_output_MEM;
        end

        if(rt_ID == regFileWriteAddr_EX)begin
            data2 = alu_output_EX;
        end else if(rt_ID == regFileWriteAddr_MEM) begin
            data2 = alu_output_MEM;
        end

        if (data1 == data2)begin
            regEqulityC = 1;
        end else begin
            regEqulityC = 0;
        end
        // $display("data1 is : %0d",data1);
        // $display("data2 is : %0d",data2);
        // $display("regEquality is : %0d",regEqulityC);
    end
endmodule