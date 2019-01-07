`define Opcode_Width 10
module EX(
	input wire rst,
	input wire[`Opcode_Width:0] opcode_in,
	input wire[4:0] Rd_in,
	input wire[31:0] pc_in,
	input wire[31:0] data1_in,
	input wire[31:0] data2_in,
	input wire[31:0] imm_in,

	output reg[`Opcode_Width:0]  opcode_out,
	output reg[31:0] data_out,
	output reg[31:0] scrdata_out,
	output reg[4:0] Rd_out,
	output reg[31:0] new_addr_out,
	output reg       jump_flag_out,
	output wire[31:0] forwarding_data_out,
	output wire[4:0] forwarding_Rd_out
	);


always @(*) begin
	if (rst) begin
		data_out = 32'h0000_0000;
		opcode_out = 7'h00;
		Rd_out = 5'b00000;
		new_addr_out = 0;
		jump_flag_out = 0;
		scrdata_out = 0;
	end
	else begin
	jump_flag_out = 1'b0;
	scrdata_out = 0;
	new_addr_out = 0;
	opcode_out = opcode_in;
	Rd_out = Rd_in;
	data_out = 0;
	case(opcode_in[6:0])
		7'b0110011 : begin    //opcode ADD
		case(opcode_in[10:7])
		4'b0000: data_out = (data1_in + data2_in);
		4'b1000: data_out = (data1_in - data2_in);
		4'b0001: data_out = (data1_in << data2_in[4:0]);
		4'b0010: data_out = ($signed(data1_in) < $signed(data2_in));
		4'b0011: data_out = (data1_in < data2_in);
		4'b0100: data_out = (data1_in ^ data2_in);
		4'b0101: data_out = (data1_in >> data2_in[4:0]);
		4'b1101: data_out = //({32{data1_in[31]}} << {6'd32 - {1'b0, data2_in[4:0]}}) |(data1_in >> data2_in[4:0]);
		{data1_in >> data2_in[4:0]} | {32{data1_in[31]}} << (~data2_in[4:0]);
        4'b0110: data_out = (data1_in | data2_in);
        4'b0111: data_out = (data1_in & data2_in);
		endcase
		end
		7'b0110111 : begin     //LUI
            data_out = imm_in;  
        end
        7'b0010111 : begin     //AUIPC
            data_out = pc_in + imm_in;         //pc may be not right
        end
        7'b0010011: begin       //ADDI
        case(opcode_in[9:7])
            3'b000:data_out = (data1_in + imm_in);
            3'b010:data_out = ($signed(data1_in) < $signed(imm_in));
            3'b011:data_out = (data1_in < imm_in);
            3'b100:data_out = (data1_in ^ imm_in);
            3'b110:data_out = (data1_in | imm_in);
            3'b111:data_out = (data1_in & imm_in);
            3'b001:data_out = (data1_in << imm_in[4:0]);
            3'b101:data_out = (opcode_in[10]) ? //({32{data1_in[31]}} << {6'd32 - {1'b0, imm_in[4:0]}}) | (data1_in >> imm_in[4:0]) : (data1_in >> imm_in[4:0]);
        {data1_in >> imm_in[4:0]} | {32{data1_in[31]}} << (~imm_in[4:0]) : (data1_in >> imm_in[4:0]);
 
        endcase    
        end
        7'b1101111: begin       //JAL
            data_out = pc_in + 3'b100;
            jump_flag_out = 1'b1;
            new_addr_out = pc_in + imm_in;
        end
        7'b1100111: begin       //JALR
            data_out = pc_in + 3'b100;
            jump_flag_out = 1'b1;
            //new_addr_out <= {data1_in + $signed(imm_in)} & {31'b1 , 1'b0};
            new_addr_out = (data1_in + imm_in) & (32'b1111_1111_1111_1111_1111_1111_1111_1110);
        end
        7'b1100011: begin       //B
        data_out = 0;
        new_addr_out = pc_in + imm_in;
        case(opcode_in[9:7])
        3'b000: jump_flag_out = (data1_in == data2_in) ? 1'b1 : 1'b0;
        3'b001: jump_flag_out = (data1_in != data2_in) ? 1'b1 : 1'b0;
        3'b100: jump_flag_out = ($signed(data1_in) < $signed(data2_in)) ? 1'b1 : 1'b0;
        3'b101: jump_flag_out = (!($signed(data1_in) < $signed(data2_in))) ? 1'b1 : 1'b0;//(!(data1_in < data2_in)) ? 1'b1 : 1'b0;
        3'b110: jump_flag_out = (data1_in < data2_in) ? 1'b1 : 1'b0;
        3'b111: jump_flag_out = (!(data1_in < data2_in)) ? 1'b1 : 1'b0;
        endcase
        end
        7'b0000011: begin       //LOAD
            data_out = data1_in + imm_in;
        end
        7'b0100011: begin       //STORE
            data_out = data1_in + imm_in;
            scrdata_out = data2_in;
        end
        default: begin
            data_out = 32'h0000_0000;
            opcode_out = 7'h00;
            Rd_out = 5'b00000;
            new_addr_out = 0;
            jump_flag_out = 0;
            scrdata_out = 0;
        end
	endcase
	end
end
assign forwarding_data_out = data_out;
assign forwarding_Rd_out = Rd_out;
endmodule