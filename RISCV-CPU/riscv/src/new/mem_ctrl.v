//this is mem_ctrl module

module mem_ctrl
#(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 8
)
(
	input wire clk,
	input wire rst,


	input wire[1:0] rw_IF_in,
	input wire[1:0] rw_MEM_in,
	input wire[ADDR_WIDTH - 1:0] addr_from_IF,//add provided by CPU
	input wire[ADDR_WIDTH - 1:0]   addr_from_MEM,
	input wire[2:0] data_length_IF,					//data's data_length
	input wire[2:0] data_length_MEM,					//data's data_length

    output reg[1:0]      IF_or_MEM,              //1 MEM 0 IF
	output reg[31:0] data_to_cpu,			//data send to CPU
	output reg[ADDR_WIDTH - 1:0] pc_back,  //pc_back which 
	
    input wire[31:0] data_from_cpu,         //data provided by CPU

	

    //to show whether it's busy
	output wire      busy_out,
	
    //it's connect to the mem part
	input wire[DATA_WIDTH - 1:0] data_from_mem,//data get from mem
	output wire 				  rw_mem,
	output wire[ADDR_WIDTH - 1:0] addr_to_mem, //addr send to mem
	output reg[DATA_WIDTH - 1:0] data_to_mem//data send to mem

);


reg busy;
reg[2:0]  length;
reg[2:0]  re_length;
reg[31:0] addr_now;
reg[31:0] data_to_write;
reg rw;
reg w_first_cyc;
reg hold;
always@(posedge clk) begin
    if(rst) begin
        IF_or_MEM <= 2'b11;
        data_to_cpu <= 0;
        pc_back <= 0;
        busy <= 0;
        length <= 0;
        re_length <= 0;
        data_to_mem <= 0;
        w_first_cyc <= 0;
        hold <= 1'b0;
    end else begin
        if(hold) begin
            hold <= 1'b0;
        end else begin
        if(~busy) begin//it's not busy, can get data!
                if(rw_MEM_in == 2'b01) begin //it's going to do LOAD
                    busy <= 1'b1;
                    IF_or_MEM <= 2'b01;
                    rw <= 1'b0;
                    data_to_cpu <= 0;
                    length <= data_length_MEM + 1'b1;
                    re_length <= data_length_MEM;
                    addr_now <= addr_from_MEM;
                    pc_back <= 0;
                end else 
                if(rw_MEM_in == 2'b10) begin //it's going to do STORE
                    busy <= 1'b1;
                    IF_or_MEM <= 2'b01;
                    rw <= 1'b1;
                    w_first_cyc <= 1'b1;
                    data_to_write <= data_from_cpu;
                    length <= data_length_MEM;
                    re_length <= data_length_MEM;
                    addr_now <= addr_from_MEM;
                    pc_back <= 0;
                end else 
                if(rw_IF_in == 2'b01) begin //it's going to do IF read
                    busy <= 1'b1;
                    IF_or_MEM <= 2'b00;
                    rw <= 1'b0;
                    data_to_cpu <= 0;
                    length <= data_length_IF + 1'b1;
                    re_length <= data_length_IF;
                    addr_now <= addr_from_IF;
                    pc_back <= addr_from_IF;
                end else begin
                    busy <= 1'b0;
                    IF_or_MEM <= 2'b11;
                    rw <= 1'b0;
                    data_to_mem <= 0;
                    data_to_write <= 0;
                    data_to_cpu <= 0;
                    length <= 0;
                    addr_now <= 0;
                    pc_back <= 0;
                end
            end else begin //it's busy now, so just continue doing it's work    
            if(length == 0) begin
                busy <= 1'b0;
                hold <= 1'b1;

                if(rw == 1'b1) begin
                    data_to_cpu <= data_to_cpu >> ((3'b100 - re_length) << 3);
                    rw <= 0;
                    addr_now <= 0;
                    data_to_mem <= 0;
                end
                else begin 
                    data_to_cpu <= data_to_cpu;
                    rw <= 0;
                    addr_now <= 0;
                end
                //rw <= 1'b0;
            end else begin
            if(rw == 1'b0) begin
                /*case(length)
                    3'b100: data_to_cpu[7:0]   <= data_from_mem;
                    3'b011: data_to_cpu[15:8]  <= data_from_mem;
                    3'b010: data_to_cpu[23:16] <= data_from_mem;
                    3'b001: data_to_cpu[31:24] <= data_from_mem;
                endcase*/
                data_to_cpu = data_to_cpu >> 8;
                data_to_cpu[31:24] = data_from_mem;
            end else begin
                /*case(length)
                    3'b100: data_to_mem <= data_to_write[7:0];
                    3'b011: data_to_mem <= data_to_write[15:8];
                    3'b010: data_to_mem <= data_to_write[23:16];
                    3'b001: data_to_mem <= data_to_write[31:24];
                endcase*/
                data_to_mem = data_to_write[7:0];
                data_to_write = data_to_write >> 8;
                w_first_cyc <= 1'b0;
            end
                length <= length - 1'b1;
                addr_now <= (w_first_cyc) ? addr_now : addr_now + 1'b1;
            end
            end
        end
    end
end

assign busy_out = busy;
assign rw_mem = rw;
assign addr_to_mem = addr_now;

endmodule