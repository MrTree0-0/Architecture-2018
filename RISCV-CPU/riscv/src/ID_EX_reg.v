//this file is about a pipline reg for ID_EX
`define Opcode_Width 10
module ID_EX_reg(
	input wire clk,
	input wire rst,
	input wire busy_line,
	input wire jump_flag_in,
	
	input wire[`Opcode_Width:0] opcode_in,
//	input wire[4:0] Rs1_in,
//    input wire[4:0] Rs2_in,
	input wire[31:0] data1_in,
	input wire[31:0] data2_in,
	input wire[4:0] Rd_in,
	input wire[31:0] pc_in,
	input wire[31:0] imm_in,

	output wire[`Opcode_Width:0] opcode_out,
//	output wire[4:0] Rs1_out,
//	output wire[4:0] Rs2_out,
	output wire[31:0] data1_out,
	output wire[31:0] data2_out,
	output wire[4:0] Rd_out,
	output wire[31:0] pc_out,
	output wire[31:0] imm_out
	);

reg[`Opcode_Width:0] 		q_opcode;
wire[`Opcode_Width:0] 		d_opcode;
//reg[4:0]        q_Rs1;
//wire[4:0]       d_Rs1;
//reg[4:0]        q_Rs2;
//wire[4:0]       d_Rs2;
reg[31:0] 		q_data1;
wire[31:0]		d_data1;
reg[31:0] 		q_data2;
wire[31:0] 		d_data2;
reg[4:0] 		q_Rd;
wire[4:0] 		d_Rd;
reg[31:0] 		q_pc;
wire[31:0] 		d_pc;
reg[31:0] 		q_imm;
wire[31:0] 		d_imm;

 assign d_opcode = opcode_in;
 assign d_data1 =  data1_in;
 assign d_data2 =  data2_in;
// assign d_Rs1 = Rs1_in;
// assign d_Rs2 = Rs2_in;
 assign d_Rd = Rd_in;
  assign d_pc = pc_in;
 assign d_imm = imm_in;

always @(posedge clk) begin
 	if (rst || jump_flag_in) begin
 		q_opcode <= 7'h00;
 		q_data2  <= 32'h0000_0000;
 		q_data1 <= 32'h0000_0000;
// 		q_Rs1 <= 0;
// 		q_Rs2 <= 0;
 		q_Rd <= 5'b00000;
 		q_pc <= 0;
 		q_imm <= 32'h0000_0000;
 	    
 	end
 	else begin
 	if(busy_line)begin end
 	else begin
 		q_opcode <= d_opcode;
 		q_data1 <= d_data1;
 		q_data2 <= d_data2;
// 		q_Rs1 <= d_Rs1;
// 		q_Rs2 <= d_Rs2;
 		q_Rd <= d_Rd;
 		q_pc <= d_pc;
 		q_imm <= d_imm;
 	end
 	end
 end 

assign opcode_out = q_opcode;
assign data1_out = q_data1;
assign data2_out = q_data2;
//assign Rs1_out = q_Rs1;
//assign Rs2_out = q_Rs2;
assign Rd_out = q_Rd;
assign pc_out = q_pc;
assign imm_out = q_imm;

 endmodule