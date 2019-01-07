
module IF_ID_reg(
	input wire clk,
	input wire rst,
	input wire busy_line,
	input wire jump_flag_in,
	input wire[31:0] inst_in,
	input wire[31:0] pc_in,
	
	output wire[31:0] pc_out,
	output wire[31:0] inst_out
	);

reg [31:0] q_inst;
wire[31:0] d_inst;
reg[31:0]  q_pc;
wire[31:0] d_pc;
assign     d_inst = inst_in;
assign     d_pc = pc_in;

always @(posedge clk) begin
	if (rst || jump_flag_in) begin
		q_inst <= 32'h0000_0000;
		q_pc <= 32'h0000_0000;
	end
	else  begin
	if(busy_line)begin end
	else begin
		q_inst <= d_inst;
		q_pc <= d_pc;
	end
	end
end


assign inst_out = q_inst; 
assign pc_out = q_pc;

endmodule