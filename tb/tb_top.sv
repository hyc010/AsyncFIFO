`include "test_select.svh"

module tb_top();
    import uvm_pkg::*;
    import afifo_test_pkg::*;
    bit wclk;
    bit rclk;

    always #20 wclk <= ~wclk;
    always #30 rclk <= ~rclk;

    // DUT interface and wrapper
    async_fifo_if dut_if(wclk, rclk);
    dut_wrapper dut_wp(dut_if);

    // Reset release sequence
    initial begin
        dut_if.w_rst_n = 1'b0;
        dut_if.r_rst_n = 1'b0;
        #100;
        dut_if.w_rst_n = 1'b1;
        dut_if.r_rst_n = 1'b1;
    end

    initial begin 
        afifo_cfg test_cfg;
        test_cfg = afifo_cfg::type_id::create("test_cfg");

        test_cfg.wr_drv_vif = dut_if.WR_DRV;
        test_cfg.rd_drv_vif = dut_if.RD_DRV;
        test_cfg.wr_mon_vif = dut_if.WR_MON;
        test_cfg.rd_mon_vif = dut_if.RD_MON;

        uvm_config_db #(afifo_cfg) ::set (null, "", "test_cfg", test_cfg);
        run_test(`SELECTED_TEST);
    end

endmodule
