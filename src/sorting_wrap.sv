module sorting_wrap #(
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

logic [DWIDTH-1:0] data_i_wrap; 
logic              sop_i_wrap; // start of transaction
logic              eop_i_wrap; // end of transaction
logic              val_i_wrap; // valid for sop_i, eop_i, data_i

logic [DWIDTH-1:0] data_o_wrap;
logic              sop_o_wrap; // start of transaction
logic              eop_o_wrap; // end of transaction
logic              val_o_wrap; // valid for sop_o, eop_o, data_o

logic              busy_o_wrap; //

sorting #(
  .AWIDTH ( AWIDTH ),
  .DWIDTH ( DWIDTH )
) bsorter (
  .clk_i  ( clk_i  ),
  .srst_i ( srst_i ),
  
  .data_i ( data_i_wrap ),
  .sop_i  ( sop_i_wrap  ),
  .eop_i  ( eop_i_wrap  ),
  .val_i  ( val_i_wrap  ),
  
  .data_o ( data_o_wrap ),
  .sop_o  ( sop_o_wrap  ),
  .eop_o  ( eop_o_wrap  ),
  .val_o  ( val_o_wrap  ),
  .busy_o ( busy_o_wrap )
);

always_ff @( posedge clk_i )
  begin
    data_i_wrap <= data_i;
    sop_i_wrap  <= sop_i;
    eop_i_wrap  <= eop_i;
    val_i_wrap  <= val_i;
    
    data_o <= data_o_wrap;
    sop_o  <= sop_o_wrap;
    eop_o  <= eop_o_wrap;
    val_o  <= val_o_wrap;
    busy_o <= busy_o_wrap;
  end


endmodule
