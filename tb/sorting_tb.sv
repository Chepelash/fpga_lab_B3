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
  
  clk_i <= '1;
  srst_i <= '0;
  val_i <= '0;
sop_i <= '0;
eop_i <= '0;


endtask



bit [DWIDTH-1:0] rand_data;
int num_of_iter;
int seed;
task automatic sort_test;
  num_of_iter = 4;
  seed = 10;
  void'($urandom(seed));
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
      @( posedge clk_i );
    end
  val_i <= '0;
  eop_i <= '0;
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
