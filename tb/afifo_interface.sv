interface async_fifo_if #(
    parameter DATA_WIDTH = 8
) (
    input logic wclk,
    input logic rclk
);
    logic w_rst_n;
    logic r_rst_n;
    logic winc;
    logic rinc;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;
    logic wfull;
    logic rempty;

// write-side clocking block
    clocking wr_drv_cb @(posedge wclk);
        output winc;
        output wdata;
        input  wfull;
    endclocking

    // read-side clocking block
    clocking rd_drv_cb @(posedge rclk);
        output rinc;
        input  rdata;
        input  rempty;
    endclocking

    // monitor write side
    clocking wr_mon_cb @(posedge wclk);
        input winc;
        input wdata;
        input wfull;
    endclocking

    // monitor read side
    clocking rd_mon_cb @(posedge rclk);
        input rinc;
        input rdata;
        input rempty;
    endclocking

    modport WR_DRV (
        clocking wr_drv_cb,
        input wclk,
        input w_rst_n
    );

    modport RD_DRV (
        clocking rd_drv_cb,
        input rclk,
        input r_rst_n
    );

    modport WR_MON (
        clocking wr_mon_cb,
        input wclk,
        input w_rst_n
    );

    modport RD_MON (
        clocking rd_mon_cb,
        input rclk,
        input r_rst_n
    );


endinterface