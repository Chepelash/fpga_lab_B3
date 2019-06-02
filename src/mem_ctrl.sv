module mem_ctrl #(
  parameter AWIDTH = 4
)(
  input                     clk_i,
  input                     srst_i,
  
  input                     wren_i,
  input                     fsm_clr_i,
  
  output logic [AWIDTH-1:0] wraddr_o
);

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin : reset
        wraddr_o <= '0;
      end   : reset
    else
      begin : workflow
        if( fsm_clr_i )
          wraddr_o <= '0;
        else if( wren_i )
          wraddr_o <= wraddr_o + 1'b1;
        else
          wraddr_o <= wraddr_o;
      end   : workflow
  end

endmodule
