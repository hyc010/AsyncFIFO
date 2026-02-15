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

rptr_empty #(
    ADDR_WIDTH
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
    ADDR_WIDTH
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
    DATA_WIDTH,
    ADDR_WIDTH
) u_fifo_mem (
   .rclk(rclk),
   .wclk(wclk),
   .winc(winc),
   .rinc(rinc),
   .wdata(wdata),
   .rdata(rdata),
   .waddr(waddr),
   .raddr(raddr),
   .wfull(wfull),
   .rempty(rempty)
);

sync_r2w #(
    ADDR_WIDTH
) u_sync_r2w (
   .wclk(wclk),
   .w_rst_n(w_rst_n),
   .rptr(rptr),
   .r2w_rptr(r2w_rptr)
);

sync_w2r #(
    ADDR_WIDTH
) u_sync_w2r (
   .rclk(rclk),
   .r_rst_n(r_rst_n),
   .wptr(wptr),
   .w2r_wptr(w2r_wptr)
);



endmodule