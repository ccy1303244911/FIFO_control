///异步FIFO测试，写入一个以50Mhz计数的8为计数器，当FIFO中存储量达到能够进行32次读操作时，以100Mhz从中读取32个16位数据
module FIFO_async_tb;
reg rst;
reg wr_clk;
reg rd_clk;
reg [7:0] din;
reg wr_en;
reg rd_en;
wire [15:0] dout;
wire full;
wire almost_full;
wire wr_ack;
wire overflow;
wire empty;
wire almost_empty;
wire valid;
wire underflow;
wire [7:0] rd_data_count;
wire [8:0] wr_data_count;
wire wr_rst_busy;
wire rd_rst_busy;

reg [5:0] cnt;

parameter CLK_PERIOD_1=20;  //写时钟周期
parameter CLK_PERIOD_2=10;  //读时钟周期
always#(CLK_PERIOD_1/2) wr_clk=~wr_clk;
always#(CLK_PERIOD_2/2) rd_clk=~rd_clk;
//读次数计数器cnt
always @(posedge rd_clk or posedge rst) 
begin
    if (rst) 
    begin
        #1 cnt<=0;    
    end   
    else if (cnt>=6'd31) 
    begin
        #1 cnt<=0;
    end
    else if (rd_en) 
    begin
        #1 cnt<=cnt+1;     
    end
end

always @(posedge rd_clk or posedge rst) 
begin
    if (rst) 
    begin
        #1 rd_en<=0;    
    end    
    else if (rd_data_count>31) //只要可读数据达到32个，就拉高rd_en开始读写
    begin
        #1 rd_en<=1;    
    end
    else if (cnt>=31) 
    begin
        #1 rd_en<=0;    
    end
end

fifo_generator_1 FIFO_async_u (
  .rst(rst),                      // input wire rst
  .wr_clk(wr_clk),                // input wire wr_clk
  .rd_clk(rd_clk),                // input wire rd_clk
  .din(din),                      // input wire [7 : 0] din
  .wr_en(wr_en),                  // input wire wr_en
  .rd_en(rd_en),                  // input wire rd_en
  .dout(dout),                    // output wire [15 : 0] dout
  .full(full),                    // output wire full
  .almost_full(almost_full),      // output wire almost_full
  .wr_ack(wr_ack),                // output wire wr_ack
  .overflow(overflow),            // output wire overflow
  .empty(empty),                  // output wire empty
  .almost_empty(almost_empty),    // output wire almost_empty
  .valid(valid),                  // output wire valid
  .underflow(underflow),          // output wire underflow
  .rd_data_count(rd_data_count),  // output wire [7 : 0] rd_data_count
  .wr_data_count(wr_data_count),  // output wire [8 : 0] wr_data_count
  .wr_rst_busy(wr_rst_busy),      // output wire wr_rst_busy
  .rd_rst_busy(rd_rst_busy)      // output wire rd_rst_busy
);

initial
begin
    wr_clk=1;
    rd_clk=1;
    rst=1;
    wr_en=0;
    din=8'hff;
    #61     //复位持续时间要大于三个系统时钟周期
    rst=0;

@(negedge wr_rst_busy)
wait (rd_rst_busy==0)
    repeat(257)  
    begin
        @(posedge wr_clk)
        #1
        wr_en=1;
        din=din+1;
    end
    wr_en=0;
    #1000
    $stop;
end

endmodule

