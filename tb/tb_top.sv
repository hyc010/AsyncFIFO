module tb_top();
    import uvm_pkg::*;
    import afifo_test_pkg::*;
    bit wclk;
    bit rclk;

    always #20 wclk <= ~wclk;
    always #30 rclk <= ~rclk;

    initial begin 
        afifo_cfg test_cfg;
        test_cfg = afifo_cfg::type_id::create("test_cfg");

        async_fifo_if dut_if(wclk, rclk);
        dut_wrapper dut_wp(dut_if);
        

        test_cfg.wr_drv_vif = dut_if.WR_DRV;
        test_cfg.rd_drv_vif = dut_if.RD_DRV;
        test_cfg.wr_mon_vif = dut_if.WR_MON;
        test_cfg.rd_mon_vif = dut_if.RD_MON;

        uvm_config_db #(afifo_cfg) ::set (null, "uvm_test_top", "test_cfg", test_cfg);
        run_test ("base_test");
    end



endmodule