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
logic              sort_done; // end of sorting operation
logic [AWIDTH-1:0] intr_cntr_next;

// rdaddr_o goes to ram memory
assign rdaddr_o = intr_cntr_next;

// comb values goes to ram memory in writing operation
always_comb
  begin
    intr_cntr_next = intr_cntr;
    if( wren_i )
        intr_cntr_next = intr_cntr + 1'b1;    
  end

// send sorted data from data_array in output phase, when sort_done
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_o <= '0;
    else
      begin
        if( eop_o )
          data_o <= '0;
        else if( sort_done ) 
          data_o <= data_array[intr_cntr];
      end
  end

// control signals
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
        // clear at the end of output operation
        if( eop_o )
          begin
            val_o <= '0;
            eop_o <= '0;
            sop_o <= '0;
          end
        // generate start of output transaction after sorting is done
        else if( sort_done ) 
          begin
            // start condition
            if( intr_cntr == ( cntr_i - 1'b1 ) )
              begin
                val_o <= '1;
                sop_o <= '1;
                eop_o <= '0;
              end
            // finish condition
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

// intr_cntr controls rdaddr_o and data_array 
always_ff @( posedge clk_i )
  begin
    if( srst_i )
     intr_cntr <= '0;
    else
      begin
        if( eop_o )
          intr_cntr <= '0;
        // output operation. 
        else if( sort_done )
          intr_cntr <= intr_cntr - 1'b1;
        // writing operation starts right after eop_i
        else if( wren_i && !writing_done ) 
          begin
            if( intr_cntr != ( cntr_i - 1'b1 ) )
              intr_cntr <= intr_cntr_next;
          end 
      end
  end

// flag indicates end of writing phase
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      writing_done <= '0;
    else
      begin
        // reset flag at the end of output transaction
        if( eop_o )
          writing_done <= '0;
        // flag set up when all values from ram memory have been written to data_array
        else if( wren_i && !writing_done )
          begin              
            if( intr_cntr == ( cntr_i - 1'b1 ) )
              writing_done <= '1;              
            else
              writing_done <= '0;                  
          end
      end
  end

// flag indicates end of sorting phase
always_ff @( posedge clk_i )  
  begin
    if( srst_i )
      sort_done <= '0;
    else 
      begin
        // reset flag at the end of output transaction
        if( eop_o )
          sort_done    <= '0;
        // flag set up when all values have been sorted
        else if( writing_done && !sort_done ) 
          begin
            if( i_iterator == ( cntr_i - 1'b1 ) ) 
              sort_done <= '1;
            else 
              sort_done <= '0;
          end
      end
  end

// data_array control
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      data_array <= '{default: '0};
    else
      begin
        // clear register array
        if( eop_o )
          data_array <= '{default: '0};
        // sorting operation
        else if( writing_done && !sort_done ) 
          begin
            // sorting is not done
            if( i_iterator != ( cntr_i - 1'b1 ) ) 
              begin
                // swap 
                if( data_array[j_iterator] < data_array[j_iterator+1] )
                  begin
                    data_array[j_iterator]   <= data_array[j_iterator+1];
                    data_array[j_iterator+1] <= data_array[j_iterator];
                  end            
              end
          end
       // writing from ram memory
        else if( wren_i && !writing_done )
          data_array[intr_cntr] <= data_i;
      end
  end

// iterator control
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        i_iterator <= '0;
        j_iterator <= '0;
      end      
    else
      begin : main_else
        // reset values at the end of output transaction
        if( eop_o )
          begin
            i_iterator <= '0;
            j_iterator <= '0;
          end
        // sorting operation. Finishes at i_iterator == ( cntr_i - 1'b1 )
        else if( writing_done && !sort_done ) 
          begin            
            if( i_iterator != ( cntr_i - 1'b1 ) ) 
              begin
                if( j_iterator == ( cntr_i - 1'b1 ) )
                  begin
                    j_iterator <= '0;
                    i_iterator <= i_iterator + 1'b1;
                  end
                else
                  begin
                    j_iterator <= j_iterator + 1'b1;
                  end

              end
          end       
      end   : main_else
  end  




endmodule

