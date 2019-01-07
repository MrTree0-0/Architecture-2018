`define Opcode_Width 10
module MEM(
    input wire clk,
	input wire rst,
	input wire[`Opcode_Width:0] opcode_in,
	input wire[1:0]       IF_or_MEM,
	input wire[31:0] data_in,
	input wire[31:0] scrdata_in,
	input wire[4:0]  Rd_in,

    input wire        busy_in,
    input wire        done_in,
    input wire[31:0]  data_mem_in,
    output reg[31:0] addr_mem_out,
    output reg[1:0]   rw_out,
    output reg[2:0]   data_length_out,
    output reg[31:0]  data_mem_out,
    
    
	output reg[`Opcode_Width:0]  opcode_out,
	output reg[4:0]  Rd_out,
	output reg       busy_out,
	output reg[31:0] data_out
	);

reg[31:0] data_mem;
reg[31:0] addr_mem;
reg[2:0] data_length;
reg      mem_waiting;
always @(*) begin
	if (rst) begin
		data_out <= 31'h0000_0000;
		opcode_out <= 7'b000_0000;
		Rd_out <= 0;
		busy_out <= 0;
		mem_waiting <= 0;
	end
	else begin
        Rd_out <= Rd_in;
        opcode_out <= opcode_in;
        case(opcode_in[6:0])
        7'b0000011: begin     //LOAD
          
          addr_mem_out <= data_in;
          case(opcode_in[9:7]) 
              3'b000: data_length_out <= 3'b001;
              3'b001: data_length_out <= 3'b010;
              3'b010: data_length_out <= 3'b100;
              3'b100: data_length_out <= 3'b001;
              3'b101: data_length_out <= 3'b010;
          endcase
          if(IF_or_MEM == 2'b01 && busy_in == 1'b0) begin
            rw_out <= 2'b00;
            data_out <= data_mem_in;
            /*case(opcode_in[9:7])
              3'b000: data_out <= data_mem_in >> 24;
              3'b001: data_out <= data_mem_in >> 16;
              3'b010: data_length_out <= data_mem_in;
              3'b100: data_length_out <= data_mem_in >> 24;
              3'b101: data_length_out <= data_mem_in >> 16;
            endcase*/
            busy_out <= 1'b0;
          end else begin
            rw_out <= 2'b01;
            busy_out <= 1'b1;
          end
          mem_waiting <= 1'b1;
        end
        7'b0100011: begin   //STORE
          Rd_out <= 0;
          opcode_out <= 0;
          
          data_mem_out <= {scrdata_in};
          addr_mem_out <= data_in;
          case(opcode_in[9:7]) 
              3'b000: data_length_out <= 3'b001; //data_mem_out <= {scrdata_in << 24};end
              3'b001: data_length_out <= 3'b010; //data_mem_out <= {scrdata_in << 16};end
              3'b010: data_length_out <= 3'b100; //data_mem_out <= {scrdata_in};end
              3'b100: data_length_out <= 3'b001; //data_mem_out <= {scrdata_in << 24};end
              3'b101: data_length_out <= 3'b010; //data_mem_out <= {scrdata_in << 16};end
          endcase
          if(IF_or_MEM == 2'b01 && busy_in == 1'b0) begin
            rw_out <= 2'b00;
            busy_out <= 1'b0;
          end else begin
            rw_out <= 2'b10;
            busy_out <= 1'b1;
          end
          mem_waiting <= 1'b1;
        end
        default:begin
              rw_out <= 2'b00;
              busy_out <= 1'b0;
              data_out <= data_in;
         end
        endcase
	end
end

endmodule