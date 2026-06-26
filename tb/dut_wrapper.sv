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

        .w_rst_n (dut_if.w_rst_n),
        .r_rst_n (dut_if.r_rst_n),

        .wdata   (dut_if.wdata),
        .rdata   (dut_if.rdata),

        .wfull   (dut_if.wfull),
        .rempty  (dut_if.rempty)
    );

endmodule