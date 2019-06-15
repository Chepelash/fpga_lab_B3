module mem_ctrl #(
  parameter AWIDTH = 4
)(
  input                     clk_i,
  input                     srst_i,
  
  input                     val_i,
  input                     eop_i,
  input                     clr_i,
  
  output logic              busy_o,
  output logic [AWIDTH-1:0] wraddr_o
);

// wraddr_o goes to ram memory
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin : reset
        wraddr_o <= '0;
      end   : reset
    else
      begin : workflow
        if( clr_i )
          wraddr_o <= '0;
        else if( val_i )
          wraddr_o <= wraddr_o + 1'b1;
      end   : workflow
  end

// busy_o control.
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        busy_o <= '0;
      end
    else
      begin
        if( eop_i )
          busy_o <= '1;
        else if( clr_i )
          busy_o <= '0; 
      end
  end
  
  
endmodule
