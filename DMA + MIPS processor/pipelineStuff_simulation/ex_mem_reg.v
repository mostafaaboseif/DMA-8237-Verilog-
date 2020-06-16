module Reg_ex_mem(control_out,alu_output_out,mem_Write_Data_out,rd_out,pc_out,
                  control_in,alu_output_in,mem_Write_Data_in,rd_in,pc_in,clk);
    output reg [4:0] control_out;
    output reg [31:0] alu_output_out;
    output reg [31:0] mem_Write_Data_out;
    output reg [4:0] rd_out;
    output reg [14:0] pc_out;
    input wire [14:0] pc_in;
    input wire [4:0] control_in;
    input wire [31:0] alu_output_in;
    input wire [31:0] mem_Write_Data_in;
    input wire [4:0] rd_in;
    input wire clk;

    always @(posedge clk)begin
        control_out <= control_in;
        alu_output_out <= alu_output_in;
        mem_Write_Data_out <= mem_Write_Data_in;
        rd_out <= rd_in;
        pc_out <= pc_in;
    end
endmodule