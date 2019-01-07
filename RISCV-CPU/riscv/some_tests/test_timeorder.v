\timescale 1ps/1ps
module test_timeorder();
reg clk;
reg rst;

initial begin
	clk = 1'b0;
	forever #1 clk = ~clk;
end


initial begin
	rst = 1'b1;
	#10 rst = 1'b0;
end

reg[2:0] test1;
reg[3:0] test2;
reg[3:0] test3;
always @(posedge clk) begin
	if (rst) begin
		test1 <= 3'b101;
		test2 <= 0;
		test3 <= 0;	
	end
	else begin
		test2 <= test1 + 1;
		test3  = test1 + 1;
	end
end

endmodule