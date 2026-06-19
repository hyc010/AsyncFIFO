module dut_wrapper #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    async_fifo_if dut_if
);

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .rclk(dut_if.rclk),
        .wclk(dut_if.wclk),
        
        .winc(dut_if.winc),
        .rinc(dut_if.rinc),

        .w_rst_n (_if.w_rst_n),
        .r_rst_n (_if.r_rst_n),

        .wdata   (_if.wdata),
        .rdata   (_if.rdata),

        .wfull   (_if.wfull),
        .rempty  (_if.rempty)
    );

endmodule