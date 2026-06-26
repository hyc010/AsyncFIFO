module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter FALL_THROUGH = 0  // 0=classic 1-cycle read latency, 1=write-through (data visible immediately)
)(
    input wclk,
    input wen,
    input [ADDR_WIDTH-1:0] waddr,
    input [DATA_WIDTH-1:0] wdata,
    input rclk,
    input r_rst_n,
    input ren,
    input [ADDR_WIDTH-1:0] raddr,
    output reg [DATA_WIDTH-1:0] rdata
);
    reg [DATA_WIDTH-1:0] memory [0:2**ADDR_WIDTH-1];

    // Write port
    always @(posedge wclk) begin
        if (wen)
            memory[waddr] <= wdata;
    end

    // Read port with optional fall-through
    // NOTE: forward comparison (waddr==raddr) crosses clock domains.
    // For production, synchronize waddr to rclk before comparison.
    // Here kept simple for educational purpose; set FALL_THROUGH=0 for safest behavior.
    wire forward_en = (FALL_THROUGH == 1) && wen && ren && (waddr == raddr);

    always @(posedge rclk or negedge r_rst_n) begin
        if (!r_rst_n) begin
            rdata <= '0;
        end else if (ren) begin
            rdata <= forward_en ? wdata : memory[raddr];
        end
    end
endmodule
