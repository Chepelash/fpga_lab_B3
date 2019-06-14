module sorter #(
  parameter DWIDTH = 8,
  parameter AWIDTH = 4
)(
  input                     clk_i,
  input                     srst_i, 
  
  input                     wren_i,
  input        [AWIDTH-1:0] cntr_i,
  input        [DWIDTH-1:0] data_i,
  
  output logic [AWIDTH-1:0] rdaddr_o,
  output logic [DWIDTH-1:0] data_o,
  output logic              sop_o,
  output logic              eop_o,
  output logic              val_o
);



logic [DWIDTH-1:0] data_array [2**AWIDTH-1:0];
logic              writing_done; // end of writing operation
logic [AWIDTH-1:0] intr_cntr;
logic [AWIDTH-1:0] i_iterator;
logic [AWIDTH-1:0] j_iterator;
logic              sort_done;
logic [AWIDTH-1:0] intr_cntr_next;


assign rdaddr_o = intr_cntr_next;

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_o <= '0;
    else
      begin
        if( eop_o )
          data_o <= '0;
        else if( sort_done ) // output
          data_o <= data_array[intr_cntr];
      end
  end

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        val_o <= '0;
        eop_o <= '0;
        sop_o <= '0;
      end
    else
      begin
        if( eop_o )
          begin
            val_o <= '0;
            eop_o <= '0;
            sop_o <= '0;
          end
        else if( sort_done ) // output
          begin
          if( intr_cntr == ( cntr_i - 1'b1 ) )
            begin
              val_o <= '1;
              sop_o <= '1;
              eop_o <= '0;
            end              
          else if( intr_cntr == '0 )
            begin                
              val_o <= '1;
              sop_o <= '0;
              eop_o <= '1;
            end                          
          else
            begin
              val_o <= '1;
              eop_o <= '0;
              sop_o <= '0;
            end
          end        
      end
  end

 always_ff @( posedge clk_i )
  begin
    if( srst_i )
     intr_cntr <= '0;
    else
      begin
        if( eop_o )
          intr_cntr    <= '0;
          
        else if( sort_done ) // output
          intr_cntr <= intr_cntr - 1'b1;
          
        else if( wren_i && !writing_done ) // writing
          begin
            if( intr_cntr != ( cntr_i - 1'b1 ) )
              intr_cntr <= intr_cntr_next;
          end 
      end
  end
  
 always_ff @( posedge clk_i )
  begin
    if( srst_i )
      writing_done <= '0;
    else
      begin
        if( eop_o )
          writing_done <= '0;
        else if( wren_i && !writing_done ) // writing
          begin              
            if( intr_cntr == ( cntr_i - 1'b1 ) )
              writing_done <= '1;              
            else
              writing_done <= '0;                  
          end
      end
  end
  
always_ff @( posedge clk_i )  
  begin
    if( srst_i )
      sort_done <= '0;
    else 
      begin
        if( eop_o )
          sort_done    <= '0;
        else if( writing_done && !sort_done ) // sorting
          begin
            if( i_iterator == ( cntr_i - 1'b1 ) ) // sorting done
              sort_done <= '1;
            else 
              sort_done <= '0;
          end
      end
  end

  
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_array <= '{default: '0};
    else
      begin
        if( eop_o )
          data_array <= '{default: '0};  
       else if( writing_done && !sort_done ) // sorting
         begin
          if( i_iterator != ( cntr_i - 1'b1 ) ) // sorting is not done
            begin
             if( data_array[j_iterator] < data_array[j_iterator+1] )
               begin
                data_array[j_iterator]   <= data_array[j_iterator+1];
                data_array[j_iterator+1] <= data_array[j_iterator];
               end            
            end
         end
       else if( wren_i && !writing_done ) // writing              
         data_array[intr_cntr] <= data_i;
      end
  end
  
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        i_iterator <= '0;
        j_iterator <= '0;
      end      
    else
      begin : main_else
        if( eop_o )
          begin
            i_iterator <= '0;
            j_iterator <= '0;
          end
        else if( writing_done && !sort_done ) // sorting
          begin            
            if( i_iterator != ( cntr_i - 1'b1 ) ) // sorting done
              begin
                if( j_iterator == ( cntr_i - 1'b1 ) )
                  begin
                    j_iterator <= '0;
                    i_iterator <= i_iterator + 1'b1;
                  end
                else
                  begin
                    j_iterator <= j_iterator + 1'b1;
                    i_iterator <= i_iterator;
                  end

              end
          end       
      end   : main_else
  end  



always_comb
  begin
    intr_cntr_next = intr_cntr;
    if( wren_i )
        intr_cntr_next = intr_cntr + 1'b1;
  end
  

endmodule

