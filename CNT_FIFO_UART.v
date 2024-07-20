//设计一个异步FIFO，将16位50Mhz计数器中的数值用波特率为1562500的串口发给电脑
module CNT_FIFO_UART(
input wire clk,
input wire rst,     //FIFO复位
input wire rst_n,   //uart慢时钟域复位
output wire uart_tx,
output wire tx_done

);
reg [15:0] cnt;         //产生输入FIFO数据的计数器
reg [12:0] data_cnt;    
reg [3:0] data_frequency_cnt;
reg [5:0] rst_cnt;
reg rst_over;
reg wr_en_ctrl;  //发给wr_en端口的使能控制信号
reg rd_en_ctrl;  //发给rd_en端口的使能控制信号
wire rd_clk;
wire wr_clk;

wire [7:0] dout;     //FIFO中读出的八位数据，每次读出一个，直接接入uart_tx输入即可
wire full;
wire almost_full;
wire wr_ack;
wire overflow;
wire empty;
wire almost_empty;
wire valid;
wire underflow;
wire [17:0] rd_data_count;
wire [16:0] wr_data_count;
wire wr_rst_busy;
wire rd_rst_busy;

localparam MAX=32;

//产生写时钟wr_clk，直接将系统时钟接入
assign wr_clk=clk;

//data_cnt
always@(posedge clk or posedge rst)
begin
    if (rst)
    begin
        data_cnt<=0;
    end
    else if (data_cnt==MAX) 
    begin
        data_cnt<=0;    
    end    
    else 
        data_cnt<=data_cnt+1;
end

//data_frequency_cnt
always@(posedge clk or posedge rst)
begin
    if(rst)
    begin
        data_frequency_cnt<=0;
    end
    else if (data_cnt==MAX) 
    begin
        if (data_frequency_cnt==9)      //发送次数计数器，计数到10时清零
        begin
            data_frequency_cnt<=0;
        end    
        else
        data_frequency_cnt<=data_frequency_cnt+1;
    end
end

//复位计数器，带safety circuid的异步FIFO复位后至少等待60个慢时钟周期
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        rst_cnt=0;
        rst_over<=0;
    end    
    else if (rst_cnt==61) 
    begin
        rst_cnt<=0; 
        rst_over<=1;   
    end
    else if ((data_frequency_cnt==9)&&(data_cnt==MAX)) 
    begin
        rst_cnt<=rst_cnt+1;
    end
        
end
//产生输入FIFO的计数值cnt
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        cnt<=0;    
    end    
    else if (rst_over) 
    begin
        cnt<=cnt+1;    
    end
    else if (cnt==65535) 
    begin
        cnt<=0;    
    end
end

always @(posedge wr_clk or posedge rst) 
begin
    if (rst) 
    begin
        wr_en_ctrl<=0;    
    end    
    else if (!full&&rst_over) 
    begin
        wr_en_ctrl<=1;    
    end
end

always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        rd_en_ctrl<=0;    
    end    
    else if (!empty) 
    begin
        rd_en_ctrl<=1;    
    end
end

    uart_tx uart_tx_u(
        .clk    (clk    )     ,
        .rst    (rst )     ,  
        .data_in(dout)        ,
        .uart_tx(uart_tx)     ,
        .tx_done(tx_done)     
    );

    fifo_generator_2 your_instance_name (
        .rst(rst),                      // input wire rst
        .wr_clk(clk),                // input wire wr_clk
        .rd_clk(rd_clk),                // input wire rd_clk
        .din(cnt),                      // input wire [15 : 0] din
        .wr_en(wr_en_ctrl),                  // input wire wr_en
        .rd_en(rd_en_ctrl),                  // input wire rd_en
        .dout(dout),                    // output wire [7 : 0] dout
        .full(full),                    // output wire full
        .almost_full(almost_full),      // output wire almost_full
        .wr_ack(wr_ack),                // output wire wr_ack
        .overflow(overflow),            // output wire overflow
        .empty(empty),                  // output wire empty
        .almost_empty(almost_empty),    // output wire almost_empty
        .valid(valid),                  // output wire valid
        .underflow(underflow),          // output wire underflow
        .rd_data_count(rd_data_count),  // output wire [17 : 0] rd_data_count
        .wr_data_count(wr_data_count),  // output wire [16 : 0] wr_data_count
        .wr_rst_busy(wr_rst_busy),      // output wire wr_rst_busy
        .rd_rst_busy(rd_rst_busy)      // output wire rd_rst_busy
    );

    FIFO_UART_rd_clk FIFO_UART_rd_clk_u(
        .clk(clk),
        .rst_n(rst_n),
        .rd_clk(rd_clk)

    );

endmodule
