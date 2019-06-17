module sorting #(
  parameter AWIDTH = 5,
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

logic [AWIDTH-1:0] wrpntr;
logic [AWIDTH-1:0] rdpntr;
logic [DWIDTH-1:0] data;
logic              clr;

ram_memory #(
  .DWIDTH   ( DWIDTH ),
  .AWIDTH   ( AWIDTH )
) ram_mem   (
  .clk_i    ( clk_i  ),
  
  .wren_i   ( val_i  ), 
  .wrpntr_i ( wrpntr ),
  .data_i   ( data_i ),
  
  .rdpntr_i ( rdpntr ),
  
  .q_o      ( data   )
);

mem_ctrl   #(
  .AWIDTH   ( AWIDTH )
) writer    (
  .clk_i    ( clk_i  ),
  .srst_i   ( srst_i ), 
  
  .val_i    ( val_i  ), 
  .sop_i    ( sop_i  ), 
  .eop_i    ( eop_i  ),
  .clr_i    ( eop_o  ),
  
  .busy_o   ( busy_o ),
  .wraddr_o ( wrpntr )
);


sorter           #(
  .DWIDTH         ( DWIDTH ),
  .AWIDTH         ( AWIDTH )
) srt_outp_module (
  .clk_i          ( clk_i  ),
  .srst_i         ( srst_i ), 
  
  .wren_i         ( busy_o ), 
  
  .cntr_i         ( wrpntr ),
  .data_i         ( data   ),
  
  .rdaddr_o       ( rdpntr ),  
  .data_o         ( data_o ),
  .sop_o          ( sop_o  ),
  .eop_o          ( eop_o  ),
  .val_o          ( val_o  )
);

endmodule
