`include "if_id_reg.v"
`include "id_ex_reg.v"
`include "ex_mem_reg.v"
`include "mem_wb_reg.v"
`include "control_syn.v"
`include "forward.v"
`include "../insMemory.v"
`include "regFile.v"
`include "../alu.v"
`include "../mux.v"
`include "../aluControl.v"
`include "../syscall.v"
`include "dataMemory.v"
`include "../signExtend.v"
`include "hazard.v"
`include "branchForward.v"

module pipeLineTB();
    
    reg [31:0] PC = 0;
    wire [31:0] inst_instMem_to_reg;        // wire from inst memory to if_id register
    wire [31:0] inst_reg_out;               // wire from if_id register (inst)
    wire [31:0] pc_ID;                      // wire from if_id register (pc in id stage)
    wire [14:0] pc_EX;                      // pc in inst in exe stage
    wire [14:0] pc_MEM;                     // pc in inst in mem stage
    wire [14:0] pc_WB;                      // pc in inst in wb stage
    wire [31:0] reg1Data;                   // wire from regfile to id_ex register (rs)
    wire [31:0] reg2Data;                   // wire from regfile to id_ex register (rt)
    wire [5:0] opCode_ID;                   // wire which is the opcode from the inst code
    wire [4:0] rs_ID, rs_EX;                // wire which is the rs from the inst code
    wire [4:0] rt_ID;                       // wire which is the rt from the inst code
    wire [31:0] rt_value_EX;                // value of rt
    wire [4:0] rd_ID, rd_EX;                // wire which is the rd from the inst code
    wire [4:0] shamt_ID, shamt_EX;          // wire which is the shamt from the inst code
    wire [5:0] func_ID, func_EX;            // wire which is the func from the inst code
    wire [15:0] i_value_ID_16Bit;           // wire which is the immediate Value from the inst code
    wire [31:0] i_value_ID_32Bit;           // wire which is the immediate Value from the inst code
    wire regDestC_ID, regDestC_EX;          // register disnation control line
    wire memReadC_ID,
         memReadC_EX,
         memReadC_MEM;                      // memory read control line
    wire memToRegC_ID,
         memToRegC_EX,
         memToRegC_MEM,
         memToRegC_WB;                      // memory OR register control line
    wire memWriteC_ID,
         memWriteC_EX,
         memWriteC_MEM;                     // memory write control line
    wire syscall_ID;                        // syscall signal
    wire [3:0] ALUOpC_ID, ALUOpC_EX;        // alu opcode control line
    wire ALUSrcC_ID, ALUSrcC_EX;            // alu src control line
    wire regWriteC_ID,
         regWriteC_EX,
         regWriteC_MEM,
         regWriteC_WB;                      // register write control signal
    wire [4:0] rt_EX;                       // wire which is the rt in ex stage
    wire [31:0] i_value_EX;                 // wire which is the immediate Value in ex stage
    wire [31:0] reg1Data_EX;                // wire of register (rs) in ex stage
    wire [31:0] reg2Data_EX;                // wire of register (rt) in ex stage
    wire zero;                              // zero flag of alu
    wire [31:0] alu_output_EX;              // output of the alu in excute stage
    wire [4:0] regFileWriteAddr_EX,         
               regFileWriteAddr_MEM, 
               regFileWriteAddr_WB;         // adress of writing in regFile
    wire [31:0] in_alu;                     // 2nd input of alu
    wire [3:0] alu_sel;                     // alu operation select
    wire [2:0] ALUOp;                       // alu opcode
    wire [1:0] upperMuxSel;                 // upper mux of alu rs
    wire [1:0] lowerMuxSel;                 // upper mux of alu rt
    wire [31:0] upperMux1out;       
    wire [31:0] upperMux2out;
    wire [31:0] lowerMux1out;
    wire [31:0] lowerMux2out;
    wire [31:0] mem_write_addr;             // writing address of data memory in mem stage
    wire [31:0] mem_Write_Data;             // data to be written in mem stage (rt register)
    wire [31:0] data_memory_out;            // output of memory read in mem stage
    wire [31:0] mem_data_WB;                // output of memory read in WB stage
    wire [31:0] alu_output_WB;              // output of the alu in WB stage
    wire [31:0] regWriteData;               // Data to be written in reg file
    wire finish_ID, finish_EX,
         finish_MEM, finish_WB;             // control signal to indicate program is finished (used in debuging)
    wire memHold;                            
    wire pcHold;                            
    wire IFFlush;
    wire regEqulityC;                       // control line for beq and bne 
    wire branchC;                           // branch control line
    wire branchNotC;                        // branch control line
    wire IF_Flush;                          // Control signal to flush if_id reg
    reg IF_Flush_ID;                          // Control signal to flush if_id reg
    reg IF_Flush_EX;                          // Control signal to flush if_id reg
    reg IF_Flush_MEM;                          // Control signal to flush if_id reg
    reg IF_Flush_WB;                          // Control signal to flush if_id reg
    wire jump;
    wire jal;
	wire JumpR;
    reg clk = 0;
    wire flush;
    integer clk_count = 0;

    assign opCode_ID = inst_reg_out[31:26];
    assign rs_ID = inst_reg_out[25:21];
    assign rt_ID = inst_reg_out[20:16];
    assign rd_ID = inst_reg_out[15:11];
    assign shamt_ID = inst_reg_out[10:6];
    assign func_ID = inst_reg_out[5:0];
    assign i_value_ID_16Bit = {rd_ID,shamt_ID,func_ID};
    // assign regEqulityC = (reg1Data == reg2Data) ? 1 : 0;

    /*
        Instruction fetch stage
        Contents : instMemory
                   if_id_reg
    */
    InstMem insMemory(inst_instMem_to_reg,PC[14:0]);
    Reg_if_id if_id (inst_reg_out,pc_ID,inst_instMem_to_reg,PC,flush,clk);
    /*
        Instruction decode stage
        Contents : regFile
                   control unit  
                   id_ex_reg
                   signExtend
        NOTES :    in this stage there will be branching logic
    */
    RegFile regFile(reg1Data,reg2Data,regWriteC_WB,rs_ID,rt_ID,regFileWriteAddr_WB,regWriteData,clk,pc_ID); // clk and PC for the gui
    SignExtend immediateValue(i_value_ID_32Bit,i_value_ID_16Bit);   
    Control control(regDestC_ID, memReadC_ID, memToRegC_ID, ALUOpC_ID, memWriteC_ID, ALUSrcC_ID,
                    regWriteC_ID, opCode_ID, func_ID, finish_ID, syscall_ID, branchC, branchNotC,
                    flush, jump, JumpR, jal);
    sysCall call(syscall_ID, reg1Data, reg2Data, clk,pc_ID);
    Hazard_detection hazard(memHold, pcHold, IFFlush, memReadC_EX, rt_EX, rd_EX, rs_ID, rt_ID, opCode_ID, clk);
    wire [10:0] control_hazard_mux_output;
    Mux_11 control_hazard_mux({control_hazard_mux_output},IFFlush,
                            {regDestC_ID, memReadC_ID, memToRegC_ID, ALUOpC_ID, memWriteC_ID, ALUSrcC_ID, regWriteC_ID, finish_ID},
                            11'b0);
    Reg_id_ex id_ex({regDestC_EX, memReadC_EX, memToRegC_EX, ALUOpC_EX, memWriteC_EX, ALUSrcC_EX, regWriteC_EX, finish_EX}
                    ,reg1Data_EX,reg2Data_EX,i_value_EX,shamt_EX,rt_EX,rd_EX,rs_EX,func_EX, pc_EX
                    ,control_hazard_mux_output
                    ,reg1Data,reg2Data,shamt_ID,i_value_ID_32Bit,rt_ID,rd_ID,rs_ID,func_ID,pc_ID[14:0],clk);
    B_Forward BF(regEqulityC,reg1Data,reg2Data,rs_ID,rt_ID,regFileWriteAddr_EX,regFileWriteAddr_MEM,
                alu_output_EX,mem_write_addr, clk);
    and(branchSelOut_1,branchC,regEqulityC);
    not(n_regEqulityC,regEqulityC);
    and(branchSelOut_2,branchNotC,n_regEqulityC);
    or(branchSelOut,branchSelOut_1,branchSelOut_2);
    and(flushFromBranch, flush, branchSelOut);
    or(temp1, flushFromBranch, jump);
    or(IF_Flush, temp1, JumpR);
    /*
        Instruction Execute stage
        Contents : alu
                   ex_mem_reg
                   alu_src mux
                   regDestination mux
                   alu control unit
                   forwarding unit
    */
    ALU alu(upperMux2out, in_alu, alu_sel, alu_output_EX, shamt_EX, zero);
    ALUControl alu_control(ALUOpC_EX, func_EX, alu_sel);                    // ALUOp from control
    Mux_32 aluSrc(in_alu,ALUSrcC_EX,lowerMux2out ,i_value_EX);               // aluSrcC from control
    Mux_5 regDest(regFileWriteAddr_EX,regDestC_EX,rt_EX,rd_EX);
    ForwardUnit forwad(upperMuxSel, lowerMuxSel, rs_EX, rt_EX, regFileWriteAddr_MEM, regFileWriteAddr_WB, regWriteC_EX, regWriteC_MEM, clk);
    Mux_32 upperMux1(upperMux1out, upperMuxSel[0], reg1Data_EX, data_memory_out);
    Mux_32 upperMux2(upperMux2out, upperMuxSel[1], upperMux1out, mem_write_addr);
    Mux_32 lowerMux1(lowerMux1out, lowerMuxSel[0], reg2Data_EX, data_memory_out);
    Mux_32 lowerMux2(lowerMux2out, lowerMuxSel[1], lowerMux1out, mem_write_addr);
    Reg_ex_mem ex_mem({memReadC_MEM, memToRegC_MEM, memWriteC_MEM, regWriteC_MEM, finish_MEM}
                      ,mem_write_addr,mem_Write_Data,regFileWriteAddr_MEM,pc_MEM
                      ,{memReadC_EX, memToRegC_EX, memWriteC_EX, regWriteC_EX, finish_EX}
                      ,alu_output_EX,reg2Data_EX,regFileWriteAddr_EX,pc_EX,clk);
    /*
        Instruction Memory stage
        Contents : data memory
                   mem_wb_reg
        NOTES : no control lines connected
    */        
    DataMem data_memory(data_memory_out,mem_write_addr,mem_Write_Data,memReadC_MEM,memWriteC_MEM,PC,clk); // clk and pc for gui
    Reg_mem_wb mem_wb({memToRegC_WB,regWriteC_WB, finish_WB}, mem_data_WB, alu_output_WB, regFileWriteAddr_WB,pc_WB
                    , {memToRegC_MEM,regWriteC_MEM, finish_MEM}, data_memory_out, mem_write_addr, regFileWriteAddr_MEM,pc_MEM,clk);
    /*
        Instruction WB stage
        Contents : muxs for memory writing
        NOTES : no control lines connected
    */
    Mux_32 memToReg(regWriteData,memToRegC_WB,alu_output_WB,mem_data_WB);
    

    always @(finish_WB) begin
        if(finish_WB == 1) begin
            $finish();
        end
    end

    always begin
        #5
        clk <= ~ clk;
    end

    always @(posedge clk)begin

        if(branchSelOut) begin
            PC <= (i_value_ID_32Bit<<2) + PC;
            // $display("branching");
        end else if(jump) begin
            PC <= {PC[31:28],rs_ID,rt_ID,rd_ID,shamt_ID,func_ID} << 2;
            // $display("branching");
        end else if(JumpR) begin
            PC <= reg1Data;
            // $display("branching");
        end else begin 
            PC <= PC + 4;
            // $display("branching");
        end

        IF_Flush_ID <= IF_Flush;
        IF_Flush_EX <= IF_Flush_ID;
        IF_Flush_MEM <= IF_Flush_EX;
        IF_Flush_WB <= IF_Flush_MEM;

        clk_count <= clk_count + 1;
        $display("[IF stage]    clk: %0d, PC:%0d, Flush:%0d,",clk_count, PC, IF_Flush);  
        $display("[ID stage]    clk: %0d, PC:%0d, Flush:%0d,",clk_count, pc_ID, IF_Flush_ID);
        $display("[EXE stage]   clk: %0d, PC:%0d, Flush:%0d,",clk_count, pc_EX, IF_Flush_EX);
        if(memWriteC_MEM)begin
            $display("[MEM stage]   clk: %0d, PC:%0d, write:1, memAdress:%0d, value:%0d, Flush:%0d,",clk_count,pc_MEM,mem_write_addr,mem_Write_Data, IF_Flush_MEM);
        end else begin
            $display("[MEM stage]   clk: %0d, PC:%0d, write:0, Flush:%0d,",clk_count, pc_MEM, IF_Flush_MEM);
        end
        if(regWriteData === 32'bx) begin
            $display("[WB stage]    clk: %0d, PC:%0d, regNumber:%0d, regValue:%b, Flush:%0d,\n",clk_count,pc_WB,5'b0,32'b0, 0);      
        end else begin
            $display("[WB stage]    clk: %0d, PC:%0d, regNumber:%0d, regValue:%b, Flush:%0d,\n",clk_count,pc_WB,regFileWriteAddr_WB,regWriteData, IF_Flush_WB);      
        end
    end

endmodule

// Some Questions ?? why alu_op is 4 bits 