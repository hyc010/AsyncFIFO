module rptr_empty #(
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
)(
    input rclk,
    input rst_n,
    input rinc,
    input [ADDR_WIDTH:0] w2r_wptr,
    output rempty,
    output r_almost_empty,
    output [ADDR_WIDTH:0] rptr
);
reg [ADDR_WIDTH-1:0] rptr_binary;
wire [ADDR_WIDTH-1:0] rptr_binary_next;
wire [ADDR_WIDTH-1:0] 

assign rptr_binary_next = rptr_binary + (rinc & (~rempty));

assign rptr = (rptr_binary >> 1) ^ rptr_binary;

assign rempty = rptr == w2r_wptr;


always @(posedge rclk or negedge rst_n) begin
    if (!rst_n) begin
        rptr_binary <= 0;
    end
    else begin
        rptr_binary <= rptr_binary_next;
    end
end
endmodule

