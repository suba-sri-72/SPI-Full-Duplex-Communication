
module spi__master #(
    parameter DATA_WIDTH = 8,
    parameter CLK_DIV = 4
)(
    input wire clk,
    input wire rst_n,

    input wire [DATA_WIDTH-1:0] parallel_data,
    input wire data_valid,
    input wire spi_miso,

    output reg spi_clk,
    output reg spi_cs,
    output reg spi_mosi,
    output reg [DATA_WIDTH-1:0] parallel_out
);

reg [DATA_WIDTH-1:0] shift_reg;
reg [DATA_WIDTH-1:0] rx_shift_reg;

reg [3:0] bit_cnt;
reg [1:0] state;
reg [15:0] clk_cnt;
reg spi_clk_en;

reg spi_clk_d;

wire falling_edge;
wire rising_edge;

localparam IDLE  = 2'd0;
localparam LOAD  = 2'd1;
localparam SHIFT = 2'd2;
localparam DONE  = 2'd3;

// Edge detection
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        spi_clk_d <= 0;
    else
        spi_clk_d <= spi_clk;
end

assign falling_edge = (!spi_clk && spi_clk_d);
assign rising_edge  = (spi_clk && !spi_clk_d);

// SPI clock divider
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        clk_cnt <= 0;
        spi_clk <= 0;
    end
    else if(spi_clk_en) begin
        if(clk_cnt == CLK_DIV-1) begin
            clk_cnt <= 0;
            spi_clk <= ~spi_clk;
        end
        else
            clk_cnt <= clk_cnt + 1;
    end
    else begin
        clk_cnt <= 0;
        spi_clk <= 0;
    end
end

// FSM
always @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin
        state <= IDLE;
        spi_cs <= 1;
        spi_mosi <= 0;
        bit_cnt <= 0;
        spi_clk_en <= 0;
        shift_reg <= 0;
        rx_shift_reg <= 0;
        parallel_out <= 0;
    end

    else begin

        case(state)

        IDLE: begin
            spi_cs <= 1;
            spi_clk_en <= 0;

            if(data_valid)
                state <= LOAD;
        end

        LOAD: begin
            spi_cs <= 0;

            shift_reg <= parallel_data;
            rx_shift_reg <= 0;

            bit_cnt <= DATA_WIDTH-1;

            spi_clk_en <= 1;

            spi_mosi <= parallel_data[DATA_WIDTH-1];

            state <= SHIFT;
        end

        SHIFT: begin

            // Receive data on rising edge
            if(rising_edge) begin
                rx_shift_reg <= {
                    rx_shift_reg[DATA_WIDTH-2:0],
                    spi_miso
                };
            end

            // Transmit data on falling edge
            if(falling_edge) begin

                if(bit_cnt == 0) begin
                    parallel_out <= rx_shift_reg;
                    state <= DONE;
                end

                else begin
                    bit_cnt <= bit_cnt - 1;
                    spi_mosi <= shift_reg[bit_cnt-1];
                end

            end

        end

        DONE: begin
            spi_cs <= 1;
            spi_clk_en <= 0;
            spi_mosi <= 0;
            state <= IDLE;
        end

        default: state <= IDLE;

        endcase
    end
end

endmodule

