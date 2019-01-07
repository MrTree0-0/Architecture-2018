`define Opcode_Width 10
module WB(
	input wire rst,
	input wire[`Opcode_Width:0] opcode_in,
	input wire[4:0] Rd_in,
	input wire[31:0] data_in,

	output reg[4:0]  Rd_addr_out,
	output reg[32:0] data_out
	//output reg		 req_out
	);

always @(*) begin
	if (rst) begin
		Rd_addr_out <= 0;
		data_out <= 0;
		//req_out <= 1'b0;
	end
	else begin
		/*case(opcode_in) 
			7'b0110011 : begin  	//opcode ADD
				data_out <= data_in;
				Rd_addr_out <= Rd_in;
				//req_out <= 1'b1;
			end
			7'b0110111 : begin     //LUI
                data_out <= data_in;
                Rd_addr_out <= Rd_in;
            end
            7'b0010111 : begin     //LUI
                            data_out <= data_in;
                            Rd_addr_out <= Rd_in;
                        end
            7'b0010011 : begin     //ADDI
                data_out <= data_in;
                Rd_addr_out <= Rd_in;
            end
		endcase*/
		data_out <= data_in;
        Rd_addr_out <= Rd_in;
	end
end

endmodule