module Reg_id_ex(control_out,reg1Data_out,reg2Data_out,i_value_out,shmt_out,rt_out,rd_out,rs_out,func_out,pc_out,
                 control_in,reg1Data_in,reg2Data_in,shmt_in,i_value_in,rt_in,rd_in,rs_in,func_in,pc_in,clk);
    output reg [10:0] control_out;
    output reg [31:0] reg1Data_out;
    output reg [31:0] reg2Data_out;
    output reg [31:0] i_value_out;
    output reg [4:0] shmt_out;
    output reg [4:0] rt_out;
    output reg [4:0] rd_out;
    output reg [4:0] rs_out;
    output reg [5:0] func_out;
    output reg [14:0] pc_out;
    input wire [14:0] pc_in;
    input wire [10:0] control_in;
    input wire [31:0] reg1Data_in;
    input wire [31:0] reg2Data_in;
    input wire [31:0] i_value_in;
    input wire [4:0] shmt_in;
    input wire [4:0] rt_in;
    input wire [4:0] rd_in;
    input wire [4:0] rs_in;
    input wire [5:0] func_in;
    input wire clk;

    always @(posedge clk)begin
        control_out <= control_in;
        reg1Data_out <= reg1Data_in;
        reg2Data_out <= reg2Data_in;
        shmt_out <= shmt_in;
        i_value_out <= i_value_in;
        rt_out <= rt_in;
        rd_out <= rd_in;
        rs_out <= rs_in;
        func_out <= func_in;
        pc_out <= pc_in;
    end

endmodule