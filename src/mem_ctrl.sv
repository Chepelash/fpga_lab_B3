module mem_ctrl #(
  parameter AWIDTH = 4
)(
  input                     clk_i,
  input                     srst_i,
  
  input                     val_i,
  input                     sop_i,
  input                     eop_i,
  input                     clr_i,
  
  output logic              busy_o,
  output logic [AWIDTH-1:0] wraddr_o
);

logic start;
logic fin;

logic start_next;
logic fin_next;

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        start <= '0;
        fin   <= '0;
      end
    else
      begin
        if( clr_i )
          begin
            start <= '0;
            fin   <= '0;
          end
        else
          begin
            start <= start_next;
            fin   <= fin_next;
          end
      end
  end

always_comb
  begin
    start_next = start;
    fin_next   = fin;
    if( clr_i )
      begin
        start_next = 0;
        fin_next   = 0;
      end
    if( val_i && sop_i )
      start_next = 1;
    else if( val_i && eop_i )
      fin_next = 1;    
  end

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
        else if( start_next && !fin )
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
        if( fin_next )
          busy_o <= '1;
        else if( clr_i )
          busy_o <= '0; 
      end
  end
  
  
endmodule
