//串口发送模块，波特率为9600，即一秒钟发送9600次
module uart_tx (
input wire clk,
input wire rst,         //复位与FIFO复位相同
input wire [7:0] data_in,
output reg uart_tx,
output wire tx_done     //一次发送完成标志，仅当发送完成后可以接受send_en

);
localparam  BAUD_SET=1562500;        //波特率设置参数
localparam MAX=32;   //发数据计数器最大值 

reg data_cnt_en;    //发数据计数器使能,一秒发送一次，于是发完后直到秒计数器计满前不发送
reg [7:0] data_in_reg;      //寄存输入信号的寄存器，启动发送的时刻才寄存
reg [12:0] data_cnt;    //发送数据计数器，计满时发送一次
reg [3:0] data_frequency_cnt;//发送次数计数器

wire send_en;
reg data_in_d0;
reg data_in_d1;
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        data_in_d0<=0;
        data_in_d1<=0;
    end 
    else 
        data_in_d0<=data_in[0];
        data_in_d1<=data_in_d0;   
end
assign send_en=~data_in_d1&data_in_d0;

//data_in_reg
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        data_in_reg<=0;    
    end    
    else if (send_en)     
    begin
        data_in_reg<=data_in;    
    end
end

//data_cnt_en
always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        data_cnt_en<=0;    
    end    
    else if (send_en)         //秒计数器计满时，使能拉高，数据计数器重新开始计数
    begin
        data_cnt_en<=1;    
    end
end

//data_cnt
always@(posedge clk or posedge rst)
begin
    if (rst)
    begin
        data_cnt<=0;
    end
    else if (data_cnt_en) 
    begin
        if (data_cnt==MAX) 
        begin
            data_cnt<=0;    
        end    
        else 
            data_cnt<=data_cnt+1;
    end
    else
        data_cnt<=0;
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

always @(posedge clk or posedge rst) 
begin
    if (rst) 
    begin
        uart_tx<=1;    
    end    
    else case (data_frequency_cnt)
        0  : uart_tx<=1'b0;                 //次数计数器为0的时候，发送初始位0
        1  : uart_tx<=data_in_reg[0];
        2  : uart_tx<=data_in_reg[1];
        3  : uart_tx<=data_in_reg[2];
        4  : uart_tx<=data_in_reg[3];
        5  : uart_tx<=data_in_reg[4];
        6  : uart_tx<=data_in_reg[5];
        7  : uart_tx<=data_in_reg[6];
        8  : uart_tx<=data_in_reg[7];
        9  : uart_tx<=1'b1;             //次数计数器为9的时候，发送终止位9
        default: uart_tx<=uart_tx;
    endcase
end

assign tx_done=(data_frequency_cnt==9)&&(data_cnt==MAX);

endmodule







