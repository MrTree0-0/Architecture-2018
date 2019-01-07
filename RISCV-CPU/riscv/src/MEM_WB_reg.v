//this file is about a pipline reg for MEM_WB
`define Opcode_Width 10
module MEM_WB_reg(
	input wire clk,
	input wire rst,
    input wire busy_line,

	input wire[`Opcode_Width:0]  opcode_in,
	input wire[31:0] data_in,
	input wire[4:0]  Rd_in,

    output wire[31:0] forwarding_data,
    output wire[4:0] forwarding_Rd,
	output wire[`Opcode_Width:0] opcode_out,
	output wire[31:0] data_out,
	output wire[4:0] Rd_out
	);

reg[`Opcode_Width:0] 		q_opcode;
wire[`Opcode_Width:0] 		d_opcode;
reg[31:0] 		q_data;
wire[31:0] 		d_data;
reg[4:0] 		q_Rd;
wire[4:0]		d_Rd;

assign d_opcode = opcode_in;
assign d_data = data_in;
assign d_Rd = Rd_in;

always @(posedge clk) begin
	if (rst) begin
		q_opcode <= 7'h00;
		q_data <= 32'h0000_0000;
		q_Rd <= 5'h00;
	end
	else begin
	if(busy_line)begin end
	else begin
		q_opcode <= d_opcode;
		q_data <= d_data;
		q_Rd <= d_Rd;
	end
	end
end



assign opcode_out = q_opcode;
assign data_out = q_data;
assign Rd_out = q_Rd;
assign forwarding_data = q_data;
assign forwarding_Rd = q_Rd;
endmodule