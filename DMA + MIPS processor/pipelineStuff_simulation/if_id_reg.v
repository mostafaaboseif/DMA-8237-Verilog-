module Reg_if_id(inst_out,pc_out,inst_in,pc_in,flush,clk);
    output reg [31:0] inst_out;
    output reg [31:0] pc_out;
    input wire [31:0] inst_in;
    input wire [31:0] pc_in;
    input wire clk;
    input wire flush;
    always @(posedge clk)begin
        if(flush) begin
            inst_out <= 0;
            pc_out <= pc_in;
        end else begin
            inst_out <= inst_in;
            pc_out <= pc_in;
        end
    end

endmodule