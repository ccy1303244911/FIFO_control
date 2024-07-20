//FIFO打包uart模块的读时钟
module FIFO_UART_rd_clk(
input wire clk,
input wire rst_n,
output reg rd_clk

);
reg [8:0] clk_cnt;     //发送一组包括八个数据和起始位，停止位，周期为6400ns，需要对系统时钟采样320次，故需要九位计数器
localparam cnt_MAX=160-1;

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n) 
    begin
        clk_cnt<=0;    
    end    
    else if (clk_cnt==cnt_MAX) 
    begin
        clk_cnt<=0;    
    end
    else 
        clk_cnt<=clk_cnt+1;
end

always @(posedge clk or negedge rst_n) 
begin
    if (!rst_n)
    begin
        rd_clk<=0;
    end    
    else if (clk_cnt==cnt_MAX) 
    begin
        rd_clk<=~rd_clk;    
    end
end

endmodule
