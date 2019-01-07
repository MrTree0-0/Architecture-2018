// RISCV32I CPU top module
// port modification allowed for debugging purposes
`define Opcode_Width 10
module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	input  wire					        rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)
wire[4:0] ID_Rsc1_addr;
wire[4:0] ID_Rsc2_addr;
wire[31:0] reg_ID_data1;
wire[31:0] reg_ID_data2;
wire[4:0] WB_reg_addr;
wire[31:0] WB_reg_data;
//wire       ID_req;
//wire       WB_req;
Reg_Core reg_core(
  .clk(clk_in),
  .rst(rst_in),
  .data_in(WB_reg_data),
  .port1_in(ID_Rsc1_addr),
  .port2_in(ID_Rsc2_addr),
//  .ID_req_in(ID_req),
  .port3_in(WB_reg_addr),
//  .WB_req_in(WB_req),
  //.rw_flag_in(rw_flag),
  .data1_out(reg_ID_data1),
  .data2_out(reg_ID_data2)

  //.dbgreg_dout(dbgreg_dout)
  );

wire[1:0] rw_IF;
wire[1:0] rw_MEM;
wire[1:0]      IF_or_MEM;
wire[31:0] addr_from_IF;
wire[31:0] addr_from_MEM;
wire[31:0] pc_back;
wire[31:0] data_from_MEM;
wire[2:0] data_length_IF;
wire[2:0] data_length_MEM;
wire[31:0] data_to_cpu;
wire       busy;
wire       done;
mem_ctrl mem_ctrl0(
    .clk(clk_in),
    .rst(rst_in),
    .rw_IF_in(rw_IF),
    .rw_MEM_in(rw_MEM),
    .addr_from_IF(addr_from_IF),
    .addr_from_MEM(addr_from_MEM),
    .pc_back(pc_back),
    .data_length_IF(data_length_IF),
    .data_length_MEM(data_length_MEM),
    .data_to_cpu(data_to_cpu),
    .data_from_cpu(data_from_MEM),
    .IF_or_MEM(IF_or_MEM),
    .busy_out(busy),
//    .done(done),
    
    .data_from_mem(mem_din),
    .rw_mem(mem_wr),
    .addr_to_mem(mem_a),
    .data_to_mem(mem_dout)   
);

wire busy_line;
wire busy_MEM;
pipline_ctrl pipline_ctrl0(
    .busy_MEM(busy_MEM),
    .busy_line(busy_line)
);


wire[31:0] IF_inst;
wire[31:0] IF_pc;
wire[31:0] new_addr;
wire       jump_flag;
IF IF0(
  .clk(clk_in),
  .rst(rst_in),
  .inst_in(data_to_cpu),
  .busy_in(busy),
  .IF_or_MEM(IF_or_MEM),
  .busy_line(busy_line),
  .jump_flag_in(jump_flag),
  .new_addr_in(new_addr),
  .pc_back(pc_back),
  
  .pc_addr_out(addr_from_IF),
  .data_length(data_length_IF),
  .rw_IF_out(rw_IF),
  .pc_out(IF_pc),

  .inst_out(IF_inst)
  );

wire[31:0] IF_ID_inst;
wire[31:0] IF_ID_pc;
IF_ID_reg IF_ID_reg0(
  .clk(clk_in),
  .rst(rst_in),
  .inst_in(IF_inst),
  .pc_in(IF_pc),
//  .busy_in(busy),
//  .done_in(done),
   .busy_line(busy_line),
   .jump_flag_in(jump_flag),

  .pc_out(IF_ID_pc),
  .inst_out(IF_ID_inst)
  );


wire[`Opcode_Width:0] ID_opcode;
wire[31:0] ID_data1;
wire[31:0] ID_data2;
wire[4:0] ID_Rd;
wire[31:0] ID_pc;
wire[31:0] ID_imm;
wire[4:0] forwarding_Rd;
wire[31:0] forwarding_data;
ID ID0(
  .rst(rst_in),
  .inst_in(IF_ID_inst),
  .data1_in(reg_ID_data1),
  .data2_in(reg_ID_data2),
  .forwarding_Rd_in(forwarding_Rd),
  .forwarding_data_in(forwarding_data),
  .pc_in(IF_ID_pc),
  
  .opcode_out(ID_opcode),
//  .req_out(ID_req),
  .Rsc1_addr_out(ID_Rsc1_addr),
  .Rsc2_addr_out(ID_Rsc2_addr),

  .data1_out(ID_data1),
  .data2_out(ID_data2),
  .pc_out(ID_pc),
  .Rd_out(ID_Rd),
  .imm_out(ID_imm)
  );


wire[`Opcode_Width:0] ID_EX_opcode;
wire[31:0] ID_EX_data1;
wire[31:0] ID_EX_data2;
wire[4:0]  ID_EX_Rd;
wire[31:0] ID_EX_imm;
wire[31:0] ID_EX_pc;
ID_EX_reg ID_EX_reg0(
  .clk(clk_in),
  .rst(rst_in),
  .opcode_in(ID_opcode),
  .data1_in(ID_data1),
  .data2_in(ID_data2),
    .busy_line(busy_line),
    .jump_flag_in(jump_flag),
  
  .Rd_in(ID_Rd),
  .pc_in(ID_pc),
  .imm_in(ID_imm),

  .opcode_out(ID_EX_opcode),
  .data1_out(ID_EX_data1),
  .data2_out(ID_EX_data2),
  .Rd_out(ID_EX_Rd),
  .pc_out(ID_EX_pc),
  .imm_out(ID_EX_imm)
  );

wire[`Opcode_Width:0] EX_opcode;
wire[31:0] EX_data;
wire[4:0]  EX_Rd;
wire[31:0] EX_scrdata;
EX EX0(
  .rst(rst_in),
  .opcode_in(ID_EX_opcode),
  .data1_in(ID_EX_data1),
  .pc_in(ID_EX_pc),
  .Rd_in(ID_EX_Rd),
  .data2_in(ID_EX_data2),
  .imm_in(ID_EX_imm),

  .opcode_out(EX_opcode),
  .data_out(EX_data),
  .scrdata_out(EX_scrdata),
  .Rd_out(EX_Rd),
  .new_addr_out(new_addr),
  .jump_flag_out(jump_flag)
  //.forwarding_Rd_out(forwarding_Rd),
  //.forwarding_data_out(forwarding_data)
  );

wire[`Opcode_Width:0] EX_MEM_opcode;
wire[31:0] EX_MEM_data;
wire[4:0]  EX_MEM_Rd;
wire[31:0] EX_MEM_scrdata;
EX_MEM_reg EX_MEM_reg0(
  .clk(clk_in),
  .rst(rst_in),
  .opcode_in(EX_opcode),
  .data_in(EX_data),
  .scrdata_in(EX_scrdata),
  .Rd_in(EX_Rd),
  .jump_flag_in(jump_flag),
    .busy_line(busy_line),

  .opcode_out(EX_MEM_opcode),
  .scrdata_out(EX_MEM_scrdata),
  .data_out(EX_MEM_data),
  .Rd_out(EX_MEM_Rd)

  );


wire[`Opcode_Width:0] MEM_opcode;
wire[4:0] MEM_Rd;
wire[31:0] MEM_data;
MEM MEM0(
    .clk(clk_in),
  .rst(rst_in),
  .opcode_in(EX_MEM_opcode),
  .IF_or_MEM(IF_or_MEM),
  .data_in(EX_MEM_data),
  .scrdata_in(EX_MEM_scrdata),
  
  .Rd_in(EX_MEM_Rd),
  .data_mem_in(data_to_cpu),
  .addr_mem_out(addr_from_MEM),
  .rw_out(rw_MEM),
  .data_length_out(data_length_MEM),
  .data_mem_out(data_from_MEM),
  .busy_in(busy),
  .done_in(done),

  .opcode_out(MEM_opcode),
  .busy_out(busy_MEM),
  .Rd_out(MEM_Rd),
  .data_out(MEM_data)

  );


wire[`Opcode_Width:0] MEM_WB_opcode;
wire[31:0] MEM_WB_data;
wire[4:0]  MEM_WB_Rd;
MEM_WB_reg MEM_WB_reg0(
  .clk(clk_in),
  .rst(rst_in),
  .opcode_in(MEM_opcode),
  .data_in(MEM_data),
  .Rd_in(MEM_Rd),
  
   .busy_line(busy_line),

  .opcode_out(MEM_WB_opcode),
  .data_out(MEM_WB_data),
  .Rd_out(MEM_WB_Rd),
  .forwarding_Rd(forwarding_Rd),
  .forwarding_data(forwarding_data)

  );

WB WB0(
  .rst(rst_in),
  .opcode_in(MEM_WB_opcode),
  .Rd_in(MEM_WB_Rd),
  .data_in(MEM_WB_data),

  .Rd_addr_out(WB_reg_addr),
  .data_out(WB_reg_data)
//  .req_out(WB_req)
);


always @(posedge clk_in)
  begin
    if (rst_in)
      begin
         
      end
    else if (!rdy_in)
      begin
      
      end
    else
      begin
      
      end
  end


endmodule