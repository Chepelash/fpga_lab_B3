module fsm #(
  parameter AWIDTH = 4
)(
  input                     clk_i,
  input                     srst_i, 
  
  input                     wren_i,
  input                     sort_done_i,
  input        [AWIDTH-1:0] cntr_i,
  
  output logic              busy_o,
  output logic              sort_op_o,
  output logic              output_op_o,
  output logic              clear_op_o,
  output logic              val_o,
  output logic              sop_o,
  output logic              eop_o
);


// wren generation on falling wren_i
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

logic [AWIDTH-1:0] int_cntr;
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      int_cntr <= '0;
    else if( wren )
      int_cntr <= cntr_i;
    else if( state == OUTPUT_S )
      int_cntr <= int_cntr - 1'b1;
    else
      int_cntr <= int_cntr;
      
  end

// FSM states
enum logic [1:0] {IDLE_S,
                  SORT_S,
                  OUTPUT_S} state, next_state;

// FSM blocks
always_ff @( posedge clk_i )
  begin
    if( srst_i )
      state <= IDLE_S;
    else
      state <= next_state;
  end


always_comb
  begin
    next_state = state;
    case( state )
      IDLE_S: begin
        next_state = wren ? SORT_S : IDLE_S;
      end
      
      SORT_S: begin
        next_state = sort_done_i ? OUTPUT_S : SORT_S;
      end
      
      OUTPUT_S: begin
        next_state = ( int_cntr == '0 ) ? IDLE_S : OUTPUT_S;
      end
      
      default: begin
        next_state = IDLE_S;
      end
    endcase
  end

always_ff @( posedge clk_i )
  begin
    if( srst_i )
      begin
        busy_o      <= '0;
        sort_op_o   <= '0;
        output_op_o <= '0;
        clear_op_o  <= '0;
        val_o       <= '0;
        sop_o       <= '0;
        eop_o       <= '0;
      end
    else
      begin
        case( state )
          IDLE_S: begin
            busy_o      <= '0;
            sort_op_o   <= '0;
            output_op_o <= '0;
            clear_op_o  <= '0;
            val_o       <= '0;
            sop_o       <= '0;
            eop_o       <= '0;
          end
          
          SORT_S: begin
            busy_o      <= '1;
            sort_op_o   <= '1;
            output_op_o <= '0;
            clear_op_o  <= '0;
            val_o       <= '0;
            sop_o       <= '0;
            eop_o       <= '0;
          end
          
          OUTPUT_S: begin
            busy_o      <= '1;
            sort_op_o   <= '0;
            output_op_o <= '1;
            // flag control here !!!!!!
            if( int_cntr == cntr_i )
              begin
                val_o      <= '1;
                sop_o      <= '1;
                eop_o      <= '0;
                clear_op_o <= '0;
              end
            else if( int_cntr == '0 )
              begin
                val_o      <= '1;
                sop_o      <= '0;
                eop_o      <= '1;
                clear_op_o <= '1;
              end
            else
              begin
                val_o      <= '1;
                sop_o      <= '0;
                eop_o      <= '0;
                clear_op_o <= '0;
              end
          end
          
          default: begin
            busy_o      <= '0;
            sort_op_o   <= '0;
            output_op_o <= '0;
            clear_op_o  <= '0;
            val_o       <= '0;
            sop_o       <= '0;
            eop_o       <= '0;
          end
          
        endcase
      end
  end

endmodule
