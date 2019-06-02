module bsorter #(
  parameter DWIDTH = 8,
  parameter AWIDTH = 4
)(
  input                     clk_i,
  input                     srst_i, 
  
  input do_work_i,
  input [AWIDTH-1:0] wrpntr_i,
  
  output logic rd_req_o,
  output logic [DWIDTH-1:0] data_o [AWIDTH-1:0],
  output logic val_o,
  output logic sop_o,
  output logic eop_o
);

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        // TODO
      end
    else
      begin : else_block
        
      end : else_block
  end


endmodule
