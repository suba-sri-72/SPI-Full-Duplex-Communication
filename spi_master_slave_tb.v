
module spi_master_slave_tb;

parameter DATA_WIDTH = 8;

reg clk;
reg rst_n;
reg data_valid;

reg [DATA_WIDTH-1:0] parallel_data;
reg [DATA_WIDTH-1:0] slave_tx_data;

wire spi_clk;
wire spi_cs;
wire spi_mosi;
wire spi_miso;

wire [DATA_WIDTH-1:0] parallel_out;
wire [DATA_WIDTH-1:0] master_rx;

wire data_valid_out;

//---------------- MASTER ----------------

spi__master #(
    .DATA_WIDTH(DATA_WIDTH),
    .CLK_DIV(4)
) master (
    .clk(clk),
    .rst_n(rst_n),

    .parallel_data(parallel_data),
    .data_valid(data_valid),
    .spi_miso(spi_miso),

    .spi_clk(spi_clk),
    .spi_cs(spi_cs),
    .spi_mosi(spi_mosi),
    .parallel_out(master_rx)
);

//---------------- SLAVE ----------------

spi__slave #(
    .DATA_WIDTH(DATA_WIDTH)
) slave (
    .clk(clk),
    .rst_n(rst_n),

    .spi_clk(spi_clk),
    .spi_cs(spi_cs),
    .spi_mosi(spi_mosi),

    .tx_data(slave_tx_data),

    .parallel_out(parallel_out),
    .spi_miso(spi_miso),
    .data_valid(data_valid_out)
);

//---------------- CLOCK ----------------

initial begin
    clk = 0;
end

always #5 clk = ~clk;

//---------------- STIMULUS ----------------

initial begin

    rst_n = 0;
    data_valid = 0;

    parallel_data = 8'b10110010;
    slave_tx_data = 8'b11001010;

    #20;
    rst_n = 1;

    #30;
    data_valid = 1;

    #10;
    data_valid = 0;

    // Wait for slave to receive 8 bits
    wait(data_valid_out == 1);

    // Wait for master transaction to finish
    wait(spi_cs == 1);

    #20;

    $display("----------------------------------");

    $display("MASTER TRANSMITTED = %b",
              parallel_data);

    $display("SLAVE RECEIVED     = %b",
              parallel_out);

    $display("SLAVE TRANSMITTED  = %b",
              slave_tx_data);

    $display("MASTER RECEIVED    = %b",
              master_rx);

    $display("----------------------------------");

    if((parallel_out == parallel_data) &&
       (master_rx == slave_tx_data))

        $display("SPI FULL DUPLEX TEST PASSED");

    else
        $display("SPI FULL DUPLEX TEST FAILED");

    #50;
    $finish;

end

//---------------- MONITOR ----------------

initial begin

    $monitor(
        "TIME=%0t CS=%b SCLK=%b MOSI=%b MISO=%b SLAVE_RX=%b MASTER_RX=%b VALID=%b",
        $time,
        spi_cs,
        spi_clk,
        spi_mosi,
        spi_miso,
        parallel_out,
        master_rx,
        data_valid_out
    );

end

endmodule

