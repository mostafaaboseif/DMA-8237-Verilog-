module RegFile(reg1Data,reg2Data,regW,r1A,r2A,wrA,wrD,clk,PC);
    output wire [31:0] reg1Data;    //register 1 Data
    output wire [31:0] reg2Data;    //register 2 Data
    input wire [31:0] wrD;          //write data
    input wire regW;                //register write
    input wire [4:0] r1A;           //register 1 address
    input wire [4:0] r2A;           //register 2 address
    input wire [4:0] wrA;           //write register address
    input wire clk;
    input wire [31:0] PC;           //For debuging issues 
    reg [31:0] Registers [0:31];
    integer clk_Count = 0; 
    integer i;
    
    assign reg1Data = Registers[r1A];
    assign reg2Data = Registers[r2A];
    
    initial begin
        $readmemb("/home/mgtm/Verilog/Mips/Verilog/reg.txt",Registers);
        Registers[29] = 'h00007fff - 3;
        $write("[Reg Init]    ");
        for(i = 0; i < 32; i = i + 1)begin
            $write("%b, ",Registers[i]);
        end
        $write("\n");
    end 
    
    always @(negedge clk)begin
        if(regW == 1) begin
            if(wrA != 0)begin
                Registers[wrA] = wrD;
            end
        end
    end

    always @(posedge clk)begin
        clk_Count <= clk_Count + 1;
        if (clk_Count == 10000) begin
            $finish();
        end
    end
endmodule