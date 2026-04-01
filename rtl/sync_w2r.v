module sync_w2r #(
    // parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    input rclk,
    input r_rst_n,
    input [ADDR_WIDTH:0] wptr,
    output reg [ADDR_WIDTH:0] w2r_wptr
);
reg [ADDR_WIDTH:0] wptr_d;

always @(posedge rclk or negedge r_rst_n) begin
    if (!r_rst_n) begin
        w2r_wptr <= 0;
        wptr_d <= 0;
    end
    else begin
        w2r_wptr <= wptr_d;
        wptr_d <= wptr;
    end
end

endmodule 