module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    input rclk,
    input wclk,
    input winc,
    input rinc,
    input w_rst_n,
    input r_rst_n,
    input [DATA_WIDTH-1:0] wdata,
    output [DATA_WIDTH-1:0] rdata,
    output wfull,
    output rempty
);
    wire [ADDR_WIDTH:0] wptr, rptr;
    wire [ADDR_WIDTH-1:0] waddr, raddr;
    wire [ADDR_WIDTH:0] r2w_rptr, w2r_wptr;
    wire fifo_wen, fifo_ren;

    // Generate actual memory enable signals
    assign fifo_wen = winc & ~wfull;
    assign fifo_ren = rinc & ~rempty;

    rptr_empty #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_rptr_empty (
        .rclk(rclk),
        .rinc(rinc),
        .raddr(raddr),
        .w2r_wptr(w2r_wptr),
        .r_rst_n(r_rst_n),
        .rptr(rptr),
        .rempty(rempty)
    );

    wptr_full #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_wptr_full (
        .wclk(wclk),
        .winc(winc),
        .waddr(waddr),
        .r2w_rptr(r2w_rptr),
        .w_rst_n(w_rst_n),
        .wptr(wptr),
        .wfull(wfull)
    );

    fifo_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .FALL_THROUGH(0)
    ) u_fifo_mem (
        .wclk(wclk),
        .wen(fifo_wen),
        .waddr(waddr),
        .wdata(wdata),
        .rclk(rclk),
        .r_rst_n(r_rst_n),
        .ren(fifo_ren),
        .raddr(raddr),
        .rdata(rdata)
    );

    // Reusable synchronizer: read pointer → write clock domain
    sync_dff #(
        .WIDTH(ADDR_WIDTH + 1),
        .SYNC_DPTH(2)
    ) u_sync_r2w (
        .clk(wclk),
        .rst_n(w_rst_n),
        .in(rptr),
        .out(r2w_rptr)
    );

    // Reusable synchronizer: write pointer → read clock domain
    sync_dff #(
        .WIDTH(ADDR_WIDTH + 1),
        .SYNC_DPTH(2)
    ) u_sync_w2r (
        .clk(rclk),
        .rst_n(r_rst_n),
        .in(wptr),
        .out(w2r_wptr)
    );
endmodule
