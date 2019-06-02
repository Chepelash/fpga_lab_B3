module bsorter #(
  parameter DWIDTH = 8,
  parameter AWIDTH = 4
)(
  input                     clk_i,
  input                     srst_i, 
  
  input                     sort_op_i,
  input                     output_op_i,
  input                     clear_op_i,
  
  input        [AWIDTH-1:0] cntr_i,
  input        [DWIDTH-1:0] data_i,
  
  output logic              sort_done_o,
  output logic [DWIDTH-1:0] data_o
);


/*
  sorting op has 2 operations:
  - writing into registers;
  - sorting.
*/
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
