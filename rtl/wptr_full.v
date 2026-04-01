module wptr_full #(
    // parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    input wclk,
    input w_rst_n,
    input winc,
    input [ADDR_WIDTH:0] r2w_rptr,
    output reg wfull,
    output [ADDR_WIDTH:0] wptr,
    output [ADDR_WIDTH-1:0] waddr
);
reg [ADDR_WIDTH:0] wptr_binary;
wire wfull_wire;   
wire [ADDR_WIDTH:0] wptr_binary_next;
wire [ADDR_WIDTH:0] wptr_gray_next;


assign wptr_binary_next = wptr_binary + (winc & (~wfull));
assign wptr_gray_next = (wptr_binary_next >> 1) ^ wptr_binary_next;
assign wptr = (wptr_binary >> 1) ^ wptr_binary;
assign wfull_wire = wptr_gray_next == {~r2w_rptr[ADDR_WIDTH:ADDR_WIDTH-1], r2w_rptr[ADDR_WIDTH-2:0]};

assign waddr = wptr[ADDR_WIDTH-1:0];

always @(posedge wclk or negedge w_rst_n) begin
    if (!w_rst_n) begin
        wfull <= 1'b0;
    end
    else begin
        wfull <= wfull_wire;
    end
end

always @(posedge wclk or negedge w_rst_n) begin
    if (!w_rst_n) begin
        wptr_binary <= 0;
    end
    else begin
        wptr_binary <= wptr_binary_next;
    end
end
endmodule