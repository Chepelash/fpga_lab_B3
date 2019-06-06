module sorter #(
  parameter DWIDTH = 8,
  parameter AWIDTH = 4
)(
  input                     clk_i,
  input                     srst_i, 
  
  input                     wren_i,
  input                     sort_op_i,
  input                     output_op_i,
  input                     clear_op_i,
  
  input        [AWIDTH-1:0] cntr_i,
  input        [DWIDTH-1:0] data_i,
  
  output logic [AWIDTH-1:0] rdaddr_o,
  output logic              sort_done_o,
  output logic [DWIDTH-1:0] data_o
);


/*
  sorting op has 2 operations:
  - writing into registers;
  - sorting.
*/

// writing
// grab intr_cntr on the falling edge of wren_i ??
logic wren;
logic wren_temp;

assign wren = wren_temp & ( ~wren_i );

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      wren_temp <= '0;
    else
      wren_temp <= wren_i;
  end

// data_array operations
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        intr_cntr <= '0;
        writing_done <= '0;
        sort_done_o <= '0;
        data_array <= '{default: '0};
        i <= '0;
        j <= '0;
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
        if( clear_op_i )
          begin
            intr_cntr    <= '0;
            writing_done <= '0;
            data_array   <= '{default: '0};
            sort_done_o <= '0;
            i <= '0;
            j <= '0;
          end
        else if( output_op_i ) // output
          begin            
            data_o <= data_array[intr_cntr];
            intr_cntr <= intr_cntr - 1'b1;
          end
        else if( writing_done && !sort_done_o ) // sorting
          begin
            if( i == cntr_i - 1'b1 ) // sorting done
              begin
                sort_done_o <= '1;
              end
            else
              begin                
              // iterattors
               sort_done_o <= '0;
                if( j == cntr_i - 1'b1 )
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
                    data_array[j] <= data_array[j+1];
                    data_array[j+1] <= data_array[j];
                  end
               
              end
          end
        else if( sort_op_i && !writing_done ) // writing

            begin
              intr_cntr <= intr_cntr + 1'b1;
              if( intr_cntr == cntr_i )            
                writing_done <= '1;              
              else
                writing_done <= '0;
                
              data_array[intr_cntr] <= data_i;
            end
        
      end   : main_else
  end
  
// intr_cntr operations



// writing into registers
logic [DWIDTH-1:0] data_array [AWIDTH-1:0];
logic              writing_done; // end of writing operation
logic [AWIDTH-1:0] intr_cntr;
logic [AWIDTH-1:0] i;
logic [AWIDTH-1:0] j;


assign rdaddr_o = intr_cntr;

// data_array control



endmodule

