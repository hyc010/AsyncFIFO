module rptr_empty #(
    // parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    input rclk,
    input r_rst_n,
    input rinc,
    input [ADDR_WIDTH:0] w2r_wptr,
    output reg rempty,
    // output r_almost_empty,
    output [ADDR_WIDTH:0] rptr,
    output [ADDR_WIDTH-1:0] raddr
);
reg [ADDR_WIDTH:0] rptr_binary;
wire rempty_wire;
// wire r_almost_empty_wire;
wire [ADDR_WIDTH:0] rptr_binary_next;
wire [ADDR_WIDTH:0] rptr_gray_next;


assign rptr_binary_next = rptr_binary + (rinc & (~rempty));
assign rptr_gray_next = (rptr_binary_next >> 1) ^ rptr_binary_next;
assign rptr = (rptr_binary >> 1) ^ rptr_binary;
assign rempty_wire = rptr_gray_next == w2r_wptr;

assign raddr = rptr_binary[ADDR_WIDTH-1:0];

always @(posedge rclk or negedge r_rst_n) begin
    if (!r_rst_n) begin
        rempty <= 1'b1;
    end
    else begin
        rempty <= rempty_wire;
    end
end

always @(posedge rclk or negedge r_rst_n) begin
    if (!r_rst_n) begin
        rptr_binary <= 0;
    end
    else begin
        rptr_binary <= rptr_binary_next;
    end
end
endmodule

