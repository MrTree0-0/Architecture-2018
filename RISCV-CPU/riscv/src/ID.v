`define Opcode_Width 10

module ID(
	input wire rst,

	input wire[31:0] inst_in,
	input wire[31:0] data1_in,
	input wire[31:0] data2_in,
    input wire[4:0] forwarding_Rd_in,
    input wire[31:0] forwarding_data_in,
    input wire[31:0] pc_in,

	output reg[`Opcode_Width:0]  opcode_out,
	//output wire[4:0]  Rs1_out,
	//output wire[4:0]  Rs2_out,
	output reg[4:0]  Rsc1_addr_out,
	output reg[4:0]  Rsc2_addr_out,
	//output reg       req_out,

	output reg[31:0] data1_out,
	output reg[31:0] data2_out,
	output reg[4:0]  Rd_out,
	output reg[31:0] pc_out,
	output reg[31:0] imm_out
	);

reg 	  rw_flag;

always @(*) begin
	if (rst) begin
		data1_out = 32'h0000_0000;
		data2_out = 32'h0000_0000;
		Rsc1_addr_out = 0;
		Rsc2_addr_out = 0;
		imm_out = 32'h0000_0000;
		opcode_out = 10'h0000;
		pc_out = 0;
		Rd_out = 0;
		//req_out <= 0;
	end
	else begin
	opcode_out = {1'b0, inst_in[14:12], inst_in[6:0]};
	pc_out = pc_in;
	Rd_out = 0;
	Rsc1_addr_out = 0;
    Rsc2_addr_out = 0;
    data1_out = 32'h0000_0000;
    data2_out = 32'h0000_0000;
    imm_out = 32'h0000_0000;
	//if(pc_in != 0) $display("%h", pc_in);
	case (inst_in[6:0])
		7'b0110011 : begin  	//ADD
			Rsc1_addr_out = inst_in[19:15];
			Rsc2_addr_out = inst_in[24:20];
			//req_out = 1'b1;
			Rd_out = inst_in[11:7];
			data1_out = (forwarding_Rd_in == Rsc1_addr_out) ? forwarding_data_in : data1_in;
			data2_out = (forwarding_Rd_in == Rsc2_addr_out) ? forwarding_data_in : data2_in;
			imm_out = 32'b0;
			opcode_out = {inst_in[30], inst_in[14:12], inst_in[6:0]};
		end
		7'b0110111 : begin     //LUI
		    Rsc1_addr_out = 0;
		    Rsc2_addr_out = 0;
		    Rd_out = inst_in[11:7];
		    data1_out = 0;
		    data2_out = 0;
		    imm_out = {inst_in[31:12], 12'b0};
		end
		7'b0010111 : begin    //AUIPC
		    Rsc1_addr_out = 0;
		    Rsc2_addr_out = 0;
		    Rd_out = inst_in[11:7];
		    data1_out = 0;
		    data2_out = 0;
			imm_out = {inst_in[31:12], 12'b0};
		end
		7'b0010011 : begin    //ADDI
		    Rsc1_addr_out = inst_in[19:15];
		    Rsc2_addr_out = 0;
		    Rd_out = inst_in[11:7];
		    data1_out = (forwarding_Rd_in == Rsc1_addr_out) ? forwarding_data_in : data1_in;
            data2_out = 0;
            opcode_out = {inst_in[30], inst_in[14:12], inst_in[6:0]};
            imm_out = {{21{inst_in[31]}}, inst_in[30:20]};
		end
		7'b1101111 : begin    //JAL
		   Rsc1_addr_out = 0;
		   Rsc2_addr_out = 0;
		   Rd_out = inst_in[11:7];
		   data1_out = 0;
		   data2_out = 0;
		   imm_out = {{12{inst_in[31]}}, inst_in[19:12], inst_in[20], inst_in[30:25], inst_in[24:21], 1'b0};
		end
		7'b1100111: begin     //JALR
		   Rsc1_addr_out = inst_in[19:15];
		   Rsc2_addr_out = 0;
		   Rd_out = inst_in[11:7];
		   data1_out = (forwarding_Rd_in == Rsc1_addr_out) ? forwarding_data_in : data1_in;
		   data2_out = 0;
		   imm_out = {{20{inst_in[31]}} ,inst_in[31:20]};
		end
		7'b1100011: begin     //B
		  opcode_out = {inst_in[30], inst_in[14:12], inst_in[6:0]};
		  Rsc1_addr_out = inst_in[19:15];
          Rsc2_addr_out = inst_in[24:20];
          Rd_out = 0;
          data1_out = (forwarding_Rd_in == Rsc1_addr_out) ? forwarding_data_in : data1_in;
          data2_out = (forwarding_Rd_in == Rsc2_addr_out) ? forwarding_data_in : data2_in;
//          imm_out = {{20{inst_in[31]}}, inst_in[7], inst_in[30:25],inst_in[11:8], 1'b0};
          imm_out = {{20{inst_in[31]}}, inst_in[7], inst_in[30:25],inst_in[11:8], 1'b0};
        end
        7'b0000011: begin  //LOAD
          Rsc1_addr_out = inst_in[19:15];
          Rsc2_addr_out = 0;
          Rd_out = inst_in[11:7];
          data1_out = (forwarding_Rd_in == Rsc1_addr_out) ? forwarding_data_in : data1_in;
          data2_out = 0;
          imm_out = {{21{inst_in[31]}}, inst_in[30:20]};
        end
        7'b0100011: begin  //STORE
          Rsc1_addr_out = inst_in[19:15];
          Rsc2_addr_out = inst_in[24:20];
          Rd_out = 0;
          data1_out = (forwarding_Rd_in == Rsc1_addr_out) ? forwarding_data_in : data1_in;
          data2_out = (forwarding_Rd_in == Rsc2_addr_out) ? forwarding_data_in : data2_in;
          imm_out = {{21{inst_in[31]}}, inst_in[30:25], inst_in[11:7]};
        end
        default: begin
            data1_out = 32'h0000_0000;
            data2_out = 32'h0000_0000;
            Rsc1_addr_out = 0;
            Rsc2_addr_out = 0;
            imm_out = 32'h0000_0000;
            opcode_out = 6'b00_0000;
            pc_out = 0;
            Rd_out = 0;
        end
    endcase
	end
end	

//assign Rs1_out = Rsc1_addr_out;
//assign Rs2_out = Rsc2_addr_out;

endmodule