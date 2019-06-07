module sorting_tb;

parameter  int CLK_T  = 60;

parameter  int DWIDTH = 8;
parameter  int AWIDTH = 3;


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


endtask



bit [DWIDTH-1:0] rand_data;
int queue[$];
int num_of_iter;

task automatic random_write( int num_of_iter );
  int data_len;
  
  int cntr;
  bit test_done;  
  int sorted_queue[$];
  
  
  
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
  
//  data_len = queue.size();
//  $display("data_len == %d", data_len);
//  
//  queue.sort();
//  $display("%p", queue);
//  while( !test_done )
//    begin
//      @( posedge clk_i );
//      if( busy_o != '1 )
//        begin
//          $display("Fail! Expected busy_o!");
//          $stop();
//        end
//      while( val_o == 1 )
//        begin : val_o_1
//          sorted_queue.push_back( data_o ); 
//          $display("cntr = %d", cntr);
//          if( busy_o != '1 )
//            begin
//              $display("Fail! Expected busy_o!");
//              $stop();
//            end
//          if( cntr == 0 )
//            begin : val_start  
//              $display("cntr == 0");
//              if( sop_o != '1 )
//                begin
//                  $display("Fail! Expected sop_o at start!");
//                  $stop();
//                end
//              if( eop_o == '1 )
//                begin
//                  $display("Fail! Unxpected eop_o at start!");
//                  $stop();
//                end              
//            end : val_start
//          else if( cntr == data_len - 1 )
//            begin : val_end
//              test_done = 1;
//              $display("cntr == data_len-1");
//              if( sop_o == '1 )
//                begin
//                  $display("Fail! Unexpected sop_o at end!");
//                  $stop();
//                end             
//              if( eop_o != '1 )
//                begin
//                  $display("Fail! Expected eop_o at end!");
//                  $stop();
//                end
//            end   : val_end
//            cntr = cntr + 1;
//            @( posedge clk_i );
//        end : val_o_1
//        if( test_done )
//          begin            
//            $display("test_done");
//            @( posedge clk_i );
//            if( val_o == 1 || eop_o == 1 || sop_o == 1 || busy_o == 1 )
//              begin
//                $display("Fail! Unexpected flags at end!");
//                $stop();
//              end            
//          end
//    end
//    
//    if( queue != sorted_queue )
//      begin
//        $display("%p", sorted_queue);
//        $display("Fail! Data was not sorted");
//        $stop();
//      end
  
endtask

task automatic flag_control;
  int data_len;
  int cntr;
  bit test_done;  
  int sorted_queue[$];
  
  data_len  = queue.size();
  queue.sort();
  $display("%p", queue);
  while( !test_done )
    begin
      @( posedge clk_i );
      if( busy_o != '1 )
        begin
          $display("Fail! Expected busy_o!");
          $stop();
        end
      while( val_o == 1 )
        begin : val_o_1
          sorted_queue.push_back( data_o );
          cntr = cntr + 1;
          if( busy_o != '1 )
            begin
              $display("Fail! Expected busy_o!");
              $stop();
            end
          if( cntr == 0 )
            begin : val_start              
              if( sop_o != '1 )
                begin
                  $display("Fail! Expected sop_o at start!");
                  $stop();
                end
              if( eop_o == '1 )
                begin
                  $display("Fail! Unxpected eop_o at start!");
                  $stop();
                end              
            end : val_start
          else if( cntr == data_len )
            begin : val_end
              test_done = 1;
              if( sop_o == '1 )
                begin
                  $display("Fail! Unexpected sop_o at end!");
                  $stop();
                end             
              if( eop_o != '1 )
                begin
                  $display("Fail! Expected eop_o at end!");
                  $stop();
                end
            end   : val_end
            @( posedge clk_i );
        end : val_o_1
        if( test_done )
          begin            
            
            @( posedge clk_i );
            if( val_o == 1 || eop_o == 1 || sop_o == 1 || busy_o == 1 )
              begin
                $display("Fail! Unexpected flags at end!");
                $stop();
              end            
          end
    end
    
    if( queue != sorted_queue )
      begin
        $display("%p", sorted_queue);
        $display("Fail! Data was not sorted");
        $stop();
      end
    for( int k = 0; k < queue.size(); k++ )
      queue.delete(0);
endtask

task automatic sort_test;
  void'($urandom(10));
  for( int j = 0; j < 3; j++ )
    begin
      
      num_of_iter = $urandom_range(2**AWIDTH-1, 3);
      random_write( num_of_iter );
      flag_control();
    end
  for( int i = 0; i < 100; i++ )
    @( posedge clk_i );
 
  
endtask

initial
  begin
    init(); // todo
    fork
      clk_gen();
    join_none
    apply_rst();
    
    
    $display("Starting testbench!");
    
    sort_test();
    $display(" test - OK!");
    
    
    $display(" test - OK!");
    
    
    $display("test - OK!");
  
    $display("Everything is OK!");
    $stop();
    
  end

endmodule
