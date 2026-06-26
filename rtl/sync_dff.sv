module sync_dff #(
    parameter WIDTH     = 5,
    parameter SYNC_DPTH = 2
) (
    input  clk,
    input  rst_n,
    input  [WIDTH-1:0] in,
    output [WIDTH-1:0] out
);

    logic [WIDTH-1:0] sync_regs [SYNC_DPTH];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < SYNC_DPTH; i++) sync_regs[i] <= '0;
        end else begin
            sync_regs[0] <= in;
            for (int i = 1; i < SYNC_DPTH; i++) sync_regs[i] <= sync_regs[i-1];
        end
    end

    assign out = sync_regs[SYNC_DPTH-1];

endmodule

