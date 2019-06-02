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


endmodule
