module testbench();
parameter ADDR_WIDTH = 4;
parameter DATA_WIDTH = 8;
reg wclk;
reg rclk;
reg w_rst_n;
reg r_rst_n;
reg winc;
reg rinc;
reg [DATA_WIDTH-1:0] wdata;
wire [DATA_WIDTH-1:0] rdata;
wire wfull;
wire wempty;

async_fifo #(
   .ADDR_WIDTH(ADDR_WIDTH),
   .DATA_WIDTH(DATA_WIDTH)
) dut (
    .wclk(wclk),
    .rclk(rclk),
    .w_rst_n(w_rst_n),
    .r_rst_n(r_rst_n),
    .winc(winc),
    .rinc(rinc),
    .wdata(wdata),
    .rdata(rdata),
    .wfull(wfull),
    .rempty(rempty)
 );

initial wclk = 0;
always #2 wclk = ~wclk;      // write clock

initial rclk = 0;
always #3 rclk = ~rclk;      // read clock

initial begin
  w_rst_n = 0;
  r_rst_n = 0;
  winc = 0;
  rinc = 0;
  wdata = 0;
  
  #10 w_rst_n = 1; r_rst_n = 1;
  
  // Test write
  #10 wdata = 8'hAA; winc = 1;
  #4 winc = 0;
  
  // Test read
  #30 rinc = 1;
  #6 rinc = 0;
  
  #20 $finish;
end

// task write_one(input [DATA_WIDTH-1:0] write_data);
// endtask

// task read_one(output [DATA_WIDTH-1:0] read_data);
// endtask

endmodule