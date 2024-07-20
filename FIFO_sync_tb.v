//同步FIFO的testbech，将一个八位计数器的值输入并发给输出，频率为时钟频率50Mhz
module FIFO_tb;
reg clk;
reg srst;
reg [7:0] din;
reg wr_en;
reg rd_en;
wire [7:0] dout;
wire full;
wire almost_full;
wire wr_ack;
wire overflow;
wire empty;
wire almost_empty;
wire valid;
wire underflow;
wire [7:0] data_count;

parameter CLK_PERIOD=20;
always#(CLK_PERIOD/2) clk=~clk;

fifo_generator_0 fifo_u (
  .clk(clk),                    // input wire clk
  .srst(srst),                  // input wire srst
  .din(din),                    // input wire [7 : 0] din
  .wr_en(wr_en),                // input wire wr_en
  .rd_en(rd_en),                // input wire rd_en
  .dout(dout),                  // output wire [7 : 0] dout
  .full(full),                  // output wire full
  .almost_full(almost_full),    // output wire almost_full
  .wr_ack(wr_ack),              // output wire wr_ack
  .overflow(overflow),          // output wire overflow
  .empty(empty),                // output wire empty
  .almost_empty(almost_empty),  // output wire almost_empty
  .valid(valid),                // output wire valid
  .underflow(underflow),        // output wire underflow
  .data_count(data_count)      // output wire [7 : 0] data_count
);

initial
begin
    clk=0;
    srst=1;
    wr_en=0;
    rd_en=0;
    din=8'hff;
    #21
    srst=0;
//写操作
    while (full==0) 
    begin
        @(posedge clk);
        #1
        wr_en=1;
        din=din+1;    
    end
//写满后再写一个测试溢出
    din=8'hf0;
    @(posedge clk);
    #1
    wr_en=0;
    #2000
//读操作
    while (empty==0) 
    begin
        @(posedge clk);
        #1
        rd_en=1;
    end
//读完后再读一次
    @(posedge clk);
    #1
    rd_en=0;

    #200
    srst=1;
    #21
    srst=0;
    #2000
    $stop;
    
end


endmodule