`define RstEnable 1'b1
`define RstUnable 1'b0

module IF(
    input wire          clk,
	input wire 			rst,

    //connect with mem
	input wire[31:0]	inst_in,
    input wire[31:0]    pc_back,
    input wire[1:0]          IF_or_MEM,
    output reg[2:0]     data_length,
    output reg[31:0]    pc_addr_out,
    output reg[1:0]     rw_IF_out,

    //it's going to jump
    input wire[31:0]    new_addr_in,
    input wire          jump_flag_in,
    

	input wire          busy_line,
	input wire          busy_in,

	output reg[31:0] 	inst_out,
	output reg[31:0]    pc_out

	);

reg waiting_mem;//you send the address, there needs one circle to get
reg jump_flag;//record the jump
reg[31:0] new_addr;
reg finish;
always @(posedge clk) begin
    if (rst) begin
        pc_addr_out <= 0;
        rw_IF_out <= 0;
        data_length <= 0;
        inst_out <= 0;
        pc_out <= 0;
        jump_flag <= 0;
        new_addr <= 0;
        finish <= 1'b1;
    end else begin
        rw_IF_out <= 2'b01;
        data_length <= 3'b100;
        if(jump_flag_in) begin
            jump_flag <= 1'b1;
            new_addr <= new_addr_in;
        end else begin
            
        end
        if (busy_in) begin //mem_ctrl is busying, so just hold on
            if(busy_line) begin
                
            end else begin
                inst_out <= 0;
                pc_out <= 0;
            end
        end else begin //mem_ctrl is not busy
            if(IF_or_MEM == 2'b00 ) begin //yeah, it's the data we need && first_cyc == 2'b00
                finish <= ~finish;
                if(finish == 1'b1) begin
                    pc_addr_out <= (jump_flag) ? new_addr : (pc_addr_out + 3'b100);
                end else begin
                    inst_out <= (jump_flag) ? 0 : inst_in;
                    pc_out <= (jump_flag) ? 0 : pc_back;
                    jump_flag <= 0;
                    new_addr <= 0;
                end
            end else begin //it's not the data we need so hold on
            if(busy_line) begin
            end else begin
                inst_out <= 0;
                pc_out <= 0;
            end
            end
        end
    end
end


endmodule