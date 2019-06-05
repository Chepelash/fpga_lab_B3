module sorting #(
  parameter AWIDTH = 3,
  parameter DWIDTH = 8
)(
  input                     clk_i,
  input                     srst_i,
  
  input        [DWIDTH-1:0] data_i, 
  input                     sop_i, // start of transaction
  input                     eop_i, // end of transaction
  input                     val_i, // valid for sop_i, eop_i, data_i
  
  output logic [DWIDTH-1:0] data_o,
  output logic              sop_o, // start of transaction
  output logic              eop_o, // end of transaction
  output logic              val_o, // valid for sop_o, eop_o, data_o
  
  output logic              busy_o //
);


inp_comb
  inp_comb_1  (
  .clk_i      ( clk_i    ),
  .srst_i     ( srst_i   ),
  
  .sop_i      ( sop_i    ),
  .eop_i      ( eop_i    ),
  .val_i      ( val_i    ),
  
  .wren_o ( wren )
);

ram_memory      #(
  .DWIDTH        ( DWIDTH      ),
  .AWIDTH        ( AWIDTH      )
) ram_mem        (
  .clk_i         ( clk_i       ),
  .srst_i        ( srst_i      ), 
  
  .wren_i    ( wren    ), 
  .wrpntr_i  ( wrpntr  ),
  .data_i    ( data_i      ),
  
  .rdpntr_i ( rdpntr ),
  
  .q_o       ( data      )
);

mem_cntr #(
  .AWIDTH ( AWIDTH )
) writer (
  .clk_i         ( clk_i       ),
  .srst_i        ( srst_i      ), 
  
  .wren_i    ( wren    ), 
  .fsm_clr_i ( fsm_clr ),
  
  .wraddr_o ( wrpntr )
);

fsm #(
  .AWIDTH ( AWIDTH )
) fsmachine (
  .clk_i         ( clk_i       ),
  .srst_i        ( srst_i      ), 
  
  .wren_i    ( wren    ), 
  .sort_done_i ( sort_done ),
  .cntr_i ( wrpntr ),
  
  .busy_o ( busy_o ),
  .sort_op_o ( fsm_sort_op ),
  .output_op_o ( fsm_output_op ),
  .clear_op_o ( fsm_clr ),
  .val_o ( val_o ),
  .sop_o ( sop_o ),
  .eop_o ( eop_o )
  
);

sorter #(
  .DWIDTH ( DWIDTH ),
  .AWIDTH ( AWIDTH )
) srt_outp_module (
  .clk_i         ( clk_i       ),
  .srst_i        ( srst_i      ), 
  
  .wren_i    ( wren    ), 
  .sort_op_i ( fsm_sort_op ),
  .output_op_i ( fsm_output_op ),
  .clear_op_i ( fsm_clr ),
  
  .cntr_i ( wrpntr ),
  .data_i ( data ),
  
  .rdaddr_o ( rdpntr ),
  .sort_done_o ( sort_done ),
  .data_o ( data_o )
);

endmodule
