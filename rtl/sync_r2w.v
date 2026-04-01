module sync_r2w #(
    // parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    input wclk,
    input w_rst_n,
    input [ADDR_WIDTH:0] rptr,
    output reg [ADDR_WIDTH:0] r2w_rptr
);
reg [ADDR_WIDTH:0] rptr_d;

always @(posedge wclk or negedge w_rst_n) begin
    if (!w_rst_n) begin
        r2w_rptr <= 0;
        rptr_d <= 0;
    end
    else begin
        rptr_d <= rptr;
        r2w_rptr <= rptr_d;
    end
end

endmodule 