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
// grab intr_cntr on the falling edge of wren_i
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


// writing into registers
logic [DWIDTH-1:0] data_array [AWIDTH-1:0];
logic              writing_done; // end of writing operation
logic [AWIDTH-1:0] intr_cntr;

assign rdaddr_o = intr_cntr;

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        //data_array   <= '{'0}; // or data_array <= '{default: 0};
        data_array <= '{default: 0};
        writing_done <= '0;  
        intr_cntr    <= '0;
      end
    else
      begin : else_block
      
        if( clear_op_i )
          begin
           // data_array   <= '{'0}; // or data_array <= '{default: 0};
            data_array <= '{default: 0};
            intr_cntr    <= '0; 
            writing_done <= '0;
          end
        else if( sort_op_i && !writing_done )
          begin : writing_into_registers
            data_array[intr_cntr] <= data_i;
            intr_cntr <= intr_cntr + 1'b1;
            if( intr_cntr == cntr_i )
              writing_done <= '1;
          end   : writing_into_registers      
        
        
      end   : else_block
  end

// sorting starts after writing_done == 1'b1

logic swapped;
logic [AWIDTH-1:0] len;
logic [AWIDTH-1:0] i;
logic [AWIDTH-1:0] j;


always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        swapped <= '1;
        len     <= '0;
        i       <= '0;
        j       <= '0;
        sort_done_o <= '0;
      end
    else 
      begin : main_else
        if( writing_done ) // writing into regs is done
          begin : writing_done_block
            if( !sort_done_o )              
              begin : sorting
                
                if( i == cntr_i - 1'b1 )
                  begin
                    sort_done_o <= '1;
                  end     
                else if( j == cntr_i - 1'b1 )
                  begin
                    j <= '0;
                    i <= i + 1'b1;
                  end
                else
                  begin
                    j <= j + 1'b1;
                  end
                       
                if( data_array[j] > data_array[j+1] )
                  begin
                    data_array[j]   <= data_array[j+1];
                    data_array[j+1] <= data_array[j];
                  end
              end : sorting
            else if( clear_op_i )
              begin
                swapped <= '1;
                len     <= '0;
                i       <= '0;
                j       <= '0;
                sort_done_o <= '0;
              end
          end   : writing_done_block 
        else
          begin
            len <= cntr_i;
          end
      end : main_else
  end

  
// outup operations
logic [AWIDTH-1:0] outpt_cntr;
logic outpt_done;

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        // TODO
        outpt_cntr <= '0;
        outpt_done <= '0;
      end
    else
      begin : main_else
        if( output_op_i && !outpt_done )
          begin
            data_o <= data_array[outpt_cntr];
            outpt_cntr <= outpt_cntr + 1'b1;
            if( outpt_cntr == AWIDTH-1 )
              begin
                outpt_done <= '1;
              end
          end
        else if( clear_op_i )
          begin
           // clearinng after output
           outpt_cntr <= '0;
           outpt_done <= '0;
          end
        else if( writing_done )
          begin
            // sort operation started
            outpt_cntr <= cntr_i;
          end
      end   : main_else
  end

endmodule

