module sorting_tb;

parameter  int CLK_T    = 60;

parameter  int DWIDTH   = 32;
parameter  int AWIDTH   = 12;
parameter  int ITER_NUM = 1;

logic              clk_i;
logic              srst_i;

logic              val_i;
logic              sop_i;
logic              eop_i;
logic [DWIDTH-1:0] data_i;

logic              busy_o;
logic              val_o;
logic              sop_o;
logic              eop_o;
logic [DWIDTH-1:0] data_o;


sorting #(
  .AWIDTH ( AWIDTH ),
  .DWIDTH ( DWIDTH )
) DUT (
  .clk_i  ( clk_i  ),
  .srst_i ( srst_i ),
  
  .data_i ( data_i ),
  .sop_i  ( sop_i  ),
  .eop_i  ( eop_i  ),
  .val_i  ( val_i  ),
  
  .data_o ( data_o ),
  .sop_o  ( sop_o  ),
  .eop_o  ( eop_o  ),
  .val_o  ( val_o  ),
  .busy_o ( busy_o )
);


task automatic clk_gen;
  
  forever
    begin
      # ( CLK_T / 2 );
      clk_i <= ~clk_i;
    end
  
endtask

task automatic apply_rst;
  
  srst_i <= 1'b1;
  @( posedge clk_i );
  srst_i <= 1'b0;
  @( posedge clk_i );

endtask

task automatic init;
  
  clk_i  <= '1;
  srst_i <= '0;
  val_i  <= '0;
  sop_i  <= '0;
  eop_i  <= '0;
  data_i <= '0;

endtask



bit [DWIDTH-1:0] rand_data;
bit [DWIDTH-1:0] queue[$];
int num_of_iter;

task automatic random_write( int num_of_iter );
  queue = {};
  
  val_i <= '1;
  for( int i = 0; i < num_of_iter; i++ )
    begin
      if( i == 0 )
        sop_i <= '1;
      else if( i == num_of_iter-1 )
        eop_i <= '1;
      else
        sop_i <= '0;
      rand_data = $urandom_range(2**DWIDTH - 1);
      data_i <= rand_data;
      queue.push_front(rand_data);
      @( posedge clk_i );
    end
  val_i <= '0;
  eop_i <= '0;
  @( posedge clk_i );
endtask

task automatic flag_control( string MAX );
  int data_len;
  int cntr;
  bit test_done;  
  bit [DWIDTH-1:0] sorted_queue[$];
  
  data_len  = queue.size();
  queue.sort();
  
  while( busy_o )
    begin : while_loop
      while( val_o )
        begin : val_o

          if( cntr == 0 )
            begin : cntr_0
              if( sop_o != 1 )
                begin
                  $display("Fail! Expected sop_o!");
                  $stop();
                end
              if( eop_o == 1 )
                begin
                  $display("Fail! Unexpected eop_o!");
                  $stop();
                end
            end : cntr_0
          else if( cntr == data_len - 1 )
            begin : cntr_max
              if( sop_o == 1 )
                begin
                  $display("Fail! Unexpected sop_o!");
                  $stop();
                end
              if( eop_o != 1 )
                begin
                  $display("Fail! Expected eop_o!");
                  $stop();
                end
            end   : cntr_max
          else if( cntr < data_len - 1 )
            begin : cntr_else
              if( eop_o || sop_o )
                begin
                  $display("cntr = %d; data_len = %d", cntr, data_len);
                  $display("Fail! eop_o or sop_o in the middle of transaction!");
                  $stop();
                end
            end : cntr_else
            cntr = cntr + 1'b1;
            sorted_queue.push_back(data_o);
            
            if( MAX == "ON" )
              begin                
                if( cntr < data_len )
                  @( posedge clk_i );                                    
                else if( cntr == data_len )
                  break;
              end
            else if( MAX == "OFF" )
              begin
                @( posedge clk_i );
                if( cntr == data_len && busy_o == 1 )
                  begin
                    $display("Fail! Unexpected busy_o!");
                    $stop();
                  end
              end
            else
              begin
                $display("Fail! Unexpected MAX option!");
                $stop();
              end
            
              
        end : val_o
        if( cntr < data_len )
          @( posedge clk_i );
        else
          break;

    end   : while_loop  
  if( cntr < data_len ) // if busy go down early
    begin
      $display("Fail! Expected busy_o!");
      $stop();
    end
  if( sorted_queue != queue )
    begin
      $display("Fail! Sorting failed!");
      $display("sorted_queue = %p; queue = %p", sorted_queue, queue);
      $stop();
    end
endtask

task automatic sort_test;
  
  for( int j = 0; j < ITER_NUM; j++ )
    begin
      
      num_of_iter = $urandom_range(2**AWIDTH, 3);
      random_write( num_of_iter );
      flag_control( "OFF" );
    end
  random_write( 2**AWIDTH );
  flag_control( "OFF" );
  
  $display("Starting max test");

  for( int j = 0; j < ITER_NUM; j++ )
    begin      
      num_of_iter = $urandom_range(2**AWIDTH, 3);
      random_write( num_of_iter );
      flag_control( "ON" );
    end
  random_write( 2**AWIDTH );
  flag_control( "ON" );
endtask

initial
  begin
    init(); 
    fork
      clk_gen();
    join_none
    apply_rst();
    
    
    $display("Starting testbench!");
    
    void'($urandom(10));
    sort_test();
  
    $display("Everything is OK!");
    $stop();
    
  end

endmodule
