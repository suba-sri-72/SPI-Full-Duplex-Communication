//module declare
module spi__slave #(
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst_n, //active low rst

    input wire spi_clk, //clk receicved frm master
    input wire spi_cs, //chip select =0 only slave selected
    input wire spi_mosi, // serial data from master

    input wire [DATA_WIDTH-1:0] tx_data, //data slave wants to transmit
    output reg [DATA_WIDTH-1:0] parallel_out, //received parallel data  
    output reg spi_miso, //serial data sent to master 
    output reg data_valid //indicates a complete byte received
);
//internal registers 
reg [DATA_WIDTH-1:0] shift_reg;  //store incomng mosi bits
reg [DATA_WIDTH-1:0] tx_shift_reg; //stores outgoing data

reg [3:0] bit_cnt;   //counts recived bits
reg [3:0] tx_bit_cnt; //counts transmitted bit

// SPI clock synchronization
reg spi_clk_d1;
reg spi_clk_d2;
reg spi_clk_d3;

// Chip select synchronization
reg spi_cs_d1;
reg spi_cs_d2;
reg spi_cs_d3;

// MOSI synchronization
reg spi_mosi_d1;
reg spi_mosi_d2;

wire rising_edge;
wire falling_edge;
wire cs_falling_edge;

// Edge detection
assign rising_edge = spi_clk_d2 && !spi_clk_d3; //receive mosi 0-1
assign falling_edge = !spi_clk_d2 && spi_clk_d3; //1-0 transmit miso

assign cs_falling_edge = spi_cs_d3 && !spi_cs_d2; //start transaction

// Main sequential logic
always @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin  //active low rst

        shift_reg    <= 0;
        tx_shift_reg <= 0;
        parallel_out <= 0;

        bit_cnt      <= 0;
        tx_bit_cnt   <= 0;

        spi_miso     <= 0;
        data_valid   <= 0;

        spi_clk_d1 <= 0;
        spi_clk_d2 <= 0;
        spi_clk_d3 <= 0;

        spi_cs_d1 <= 1;
        spi_cs_d2 <= 1;
        spi_cs_d3 <= 1;

        spi_mosi_d1 <= 0;
        spi_mosi_d2 <= 0;

    end

    else begin

        // Synchronize SPI signals
        spi_clk_d1 <= spi_clk;
        spi_clk_d2 <= spi_clk_d1;
        spi_clk_d3 <= spi_clk_d2;

        spi_cs_d1 <= spi_cs;
        spi_cs_d2 <= spi_cs_d1;
        spi_cs_d3 <= spi_cs_d2;

        spi_mosi_d1 <= spi_mosi;
        spi_mosi_d2 <= spi_mosi_d1;

        data_valid <= 0;

        // Slave selected cs change 1-0
        if (cs_falling_edge) begin

            shift_reg <= 0;
            bit_cnt <= 0;

            tx_shift_reg <= tx_data; //tx data into a tx shift reg
            tx_bit_cnt <= DATA_WIDTH-1; //set 7 for an 8 -bit transfer

            spi_miso <= tx_data[DATA_WIDTH-1]; //7 bit msb on to a miso

        end

        // Slave not selected
        else if (spi_cs_d2) begin

            bit_cnt <= 0;
            tx_bit_cnt <= 0;

            shift_reg <= 0;
            tx_shift_reg <= 0;

            spi_miso <= 0;

        end

        else begin

            // Receive data on rising edge 0-1 the slave recieve 1 bit from
	    // mosi
            if (rising_edge) begin 

                shift_reg <= {shift_reg[DATA_WIDTH-2:0],spi_mosi_d2};//take the loweer 7bits, add newly recived bit at the lsb

                if (bit_cnt == DATA_WIDTH-1) begin //7

                    parallel_out <= {shift_reg[DATA_WIDTH-2:0],
                                     spi_mosi_d2};

                    bit_cnt <= 0;
                    data_valid <= 1;

                end

                else begin
                    bit_cnt <= bit_cnt + 1;
                end

            end

            // Transmit data on falling edge
            if (falling_edge) begin

                if (tx_bit_cnt != 0) begin

                    tx_shift_reg <= {tx_shift_reg[DATA_WIDTH-2:0],
                                     1'b0};

                    spi_miso <= tx_shift_reg[DATA_WIDTH-2];

                    tx_bit_cnt <= tx_bit_cnt - 1; // decrement the tx bit count 

                end

                else begin
                    spi_miso <= 0;
                end

            end

        end

    end

end

endmodule
