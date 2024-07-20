module CNT_FIFO_UART_tb;
reg clk;
reg rst;
reg rst_n;
wire uart_tx;
wire tx_done;

parameter CLK_PERIOD=20;
always#(CLK_PERIOD/2) clk=~clk;

    CNT_FIFO_UART CNT_FIFO_UART_u(
        .clk(clk),
        .rst(rst),
        .rst_n(rst_n),
        .uart_tx(uart_tx),
        .tx_done(tx_done)
    );

initial
begin
    clk=0;
    rst=1;      //FIFO复位规则：必须先产生读写时钟再复位，
    rst_n=0;
    #201
    rst_n=1;
    #40000 //复位脉宽至少持续三个时钟周期      
    rst=0;
end

endmodule