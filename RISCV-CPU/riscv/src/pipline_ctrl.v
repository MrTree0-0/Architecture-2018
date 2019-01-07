module pipline_ctrl(
	input wire busy_MEM,

	output reg busy_line
);

always @* begin
	if(busy_MEM)
		busy_line <= 1'b1;
	else begin
		busy_line <= 1'b0;
	end
end

endmodule
