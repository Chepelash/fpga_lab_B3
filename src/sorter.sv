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
logic [AWIDTH-1:0] i;
logic [AWIDTH-1:0] j;
logic sort_done;

assign rdaddr_o = intr_cntr;

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        data_o       <= '0;
        intr_cntr    <= '0;
        writing_done <= '0;
        sort_done    <= '0;
        data_array   <= '{default: '0};
        i            <= '0;
        j            <= '0;
        val_o        <= '0;
        eop_o        <= '0;
        sop_o        <= '0;
      end      
    else
      begin : main_else
        /*
        operations with data_array:
        - clear;
        - output;
        - sorting;
        - writing.
        */
        if( eop_o )
          begin
            val_o        <= '0;
            eop_o        <= '0;
            sop_o        <= '0;
            data_o       <= '0;
            intr_cntr    <= '0;
            writing_done <= '0;
            data_array   <= '{default: '0};
            sort_done    <= '0;
            i            <= '0;
            j            <= '0;
          end
        else if( sort_done ) // output
          begin            
            data_o    <= data_array[intr_cntr];
            intr_cntr <= intr_cntr - 1'b1;     
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
        else if( writing_done && !sort_done ) // sorting
          begin
            if( i == cntr_i - 1'b1 ) // sorting done
              begin
                sort_done <= '1;
              end
            else
              begin  
                sort_done <= '0;
                if( j == ( cntr_i - 1'b1 ) )
                  begin
                    j <= '0;
                    i <= i + 1'b1;
                  end
                else
                  begin
                    j <= j + 1'b1;
                    i <= i;
                  end
                // sorting
                 if( data_array[j] < data_array[j+1] )
                   begin
                    data_array[j]   <= data_array[j+1];
                    data_array[j+1] <= data_array[j];
                   end
              end
          end
        else if( wren_i && !writing_done ) // writing
            begin              
              if( intr_cntr == ( cntr_i - 1'b1 ) )
                writing_done <= '1;              
              else
                begin
                  writing_done <= '0;
                  intr_cntr    <= intr_cntr + 1'b1;
                end                
              data_array[intr_cntr] <= data_i;
            end        
      end   : main_else
  end  




endmodule

