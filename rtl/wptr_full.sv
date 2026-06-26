module wptr_full #(
    parameter ADDR_WIDTH = 4
) (
    input wclk,
    input w_rst_n,
    input winc,
    input [ADDR_WIDTH:0] r2w_rptr,
    output reg wfull,
    output reg [ADDR_WIDTH:0] wptr,
    output [ADDR_WIDTH-1:0] waddr
);
    reg [ADDR_WIDTH:0] wptr_binary;
    wire wfull_wire;
    wire [ADDR_WIDTH:0] wptr_binary_next;
    wire [ADDR_WIDTH:0] wptr_gray_next;
    wire [ADDR_WIDTH:0] wptr_gray;

    assign wptr_binary_next = wptr_binary + (winc & (~wfull));
    assign wptr_gray_next   = (wptr_binary_next >> 1) ^ wptr_binary_next;
    assign wptr_gray        = (wptr_binary >> 1) ^ wptr_binary;
    assign wfull_wire       = wptr_gray_next == {~r2w_rptr[ADDR_WIDTH:ADDR_WIDTH-1], r2w_rptr[ADDR_WIDTH-2:0]};
    assign waddr            = wptr_binary[ADDR_WIDTH-1:0];

    // Sequential outputs: gray pointer registered to avoid glitches
    always @(posedge wclk or negedge w_rst_n) begin
        if (!w_rst_n) begin
            wfull <= 1'b0;
            wptr  <= '0;
        end else begin
            wfull <= wfull_wire;
            wptr  <= wptr_gray;
        end
    end

    always @(posedge wclk or negedge w_rst_n) begin
        if (!w_rst_n) begin
            wptr_binary <= '0;
        end else begin
            wptr_binary <= wptr_binary_next;
        end
    end
endmodule
