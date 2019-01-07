`define Reg_Num 5'b10_0000
`define Reg_Width 5'b10_0000
`define Read_Flag 1'b0
`define Write_Flag 1'b1
module Reg_Core(
    input wire clk,
	input wire rst,
	input wire[4:0] port1_in,
	input wire[4:0] port2_in,
	//input wire      ID_req_in,
	
	input wire[4:0] port3_in,
	input wire[31:0] data_in,
	//input wire      WB_req_in,

	output reg[31:0] data1_out,
	output reg[31:0] data2_out
	//output reg[31:0] dbgreg_dout
	);

	reg [31:0] Reg_mem[31:0];
/*
integer i;
always@(*) begin
if(rst) begin
    for(i = 0; i < 32; i = i + 1) begin
        Reg_mem[i] = 0;
    end
end else begin
        Reg_mem[port3_in] = data_in;
        data1_out = Reg_mem[port1_in];
        data2_out = Reg_mem[port2_in];
    end    
end
*/
always@(*) begin
    if(rst) begin
        data1_out = 0;
        data2_out = 0;
    end else begin
        data1_out = Reg_mem[port1_in];
        data2_out = Reg_mem[port2_in];
    end
end

always@(posedge clk) begin
    if(rst) begin
        Reg_mem[0] <= 0;
        Reg_mem[port3_in] <= 0;
    end else begin
        Reg_mem[port3_in] <= (port3_in) ? data_in : 0;
    end
end
endmodule