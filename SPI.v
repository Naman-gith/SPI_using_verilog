module spi_master #
(
    parameter CLK_DIV = 4,
    parameter DATA_WIDTH = 8
)
(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [DATA_WIDTH-1:0] data_in,
    input wire miso,
    input wire cpol,
    input wire cpha,
    output reg mosi,
    output reg sclk,
    output reg cs,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg done
);

reg [15:0] clk_cnt;
reg spi_clk_en;
reg [5:0] bit_cnt;
reg [DATA_WIDTH-1:0] shift_reg_tx;
reg [DATA_WIDTH-1:0] shift_reg_rx;
reg active;
reg sclk_int;
reg edge_detect;

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        clk_cnt <= 0;
        spi_clk_en <= 0;
    end
    else
    begin
        if (clk_cnt == (CLK_DIV-1))
        begin
            clk_cnt <= 0;
            spi_clk_en <= 1;
        end
        else
        begin
            clk_cnt <= clk_cnt + 1;
            spi_clk_en <= 0;
        end
    end
end

always @(posedge clk or posedge rst)
begin
    if (rst)
        sclk_int <= 0;
    else if (active && spi_clk_en)
        sclk_int <= ~sclk_int;
end

always @(*)
begin
    sclk = cpol ? ~sclk_int : sclk_int;
end

always @(posedge clk or posedge rst)
begin
    if (rst)
        edge_detect <= 0;
    else if (spi_clk_en)
        edge_detect <= ~edge_detect;
end

wire leading_edge = (cpha == 0) ? (spi_clk_en && ~sclk_int) : (spi_clk_en && sclk_int);
wire trailing_edge = (cpha == 0) ? (spi_clk_en && sclk_int) : (spi_clk_en && ~sclk_int);

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        active <= 0;
        cs <= 1;
        done <= 0;
        bit_cnt <= 0;
        shift_reg_tx <= 0;
        shift_reg_rx <= 0;
        mosi <= 0;
        data_out <= 0;
    end
    else
    begin
        done <= 0;

        if (start && !active)
        begin
            active <= 1;
            cs <= 0;
            bit_cnt <= DATA_WIDTH;
            shift_reg_tx <= data_in;
            shift_reg_rx <= 0;
        end
        else if (active)
        begin
            if (leading_edge)
            begin
                mosi <= shift_reg_tx[DATA_WIDTH-1];
                shift_reg_tx <= {shift_reg_tx[DATA_WIDTH-2:0], 1'b0};
            end

            if (trailing_edge)
            begin
                shift_reg_rx <= {shift_reg_rx[DATA_WIDTH-2:0], miso};
                bit_cnt <= bit_cnt - 1;

                if (bit_cnt == 1)
                begin
                    active <= 0;
                    cs <= 1;
                    done <= 1;
                    data_out <= {shift_reg_rx[DATA_WIDTH-2:0], miso};
                end
            end
        end
    end
end

endmodule
