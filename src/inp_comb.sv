module inp_comb (
  input clk_i,
  input srst_i,
  
  input sop_i,
  input eop_i,
  input val_i,

  output wren_o
);

logic wren;

assign wren_o = val_i & wren;

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      wren <= '0;
    else if( val_i && sop_i )
      wren <= '1;
    else if( val_i && eop_i )
      wren <= '0;
  end
endmodule
