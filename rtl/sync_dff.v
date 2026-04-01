module sync_dff #(
    parameter ADDR_WIDTH = 4,
    parameter sync_dpth = 2
) (
    input clk,
    input rst_n,
    input [ADDR_WIDTH-1:0] in,
    output reg [ADDR_WIDTH-1:0] out
);

wire sync_regs [sync_dpth:0];
assign out = sync_regs[sync_dpth];
assign sync_regs[0] = in;
genvar i;
generate
    for (i = 0; i < sync_dpth-1; i = i + 1) begin:
    dff u_dff (
        .clk(clk),
        .rst_n(rst_n),
        .d(sync_regs[i]),
        .q(sync_regs[i+1])
    );
    end
endgenerate
endmodule

