module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input wclk,
    input winc,
    input wfull,
    input [DATA_WIDTH-1:0] = wdata,
    input [ADDR_WIDTH-1:0] waddr,
    input rclk,
    input rinc,
    input rempty,
    input [ADDR_WIDTH-1:0] raddr,
    output reg [DATA_WIDTH-1:0] rdata
);
reg [0:ADDR_WIDTH-1] memory [DATA_WIDTH-1:0];
always @(posedge wclk) begin
    if(winc & ~wfull)
        memory[waddr] <= wdata;
end

always @(posedge rclk) begin
    if(rinc & ~rempty)
        rdata <= memory[raddr];
end
endmodule