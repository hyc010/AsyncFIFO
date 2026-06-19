class afifo_cfg extends uvm_object;

    `uvm_object_utils(afifo_cfg)

    virtual async_fifo_if.WR_DRV wr_drv_vif;
    virtual async_fifo_if.RD_DRV rd_drv_vif;
    virtual async_fifo_if.WR_MON wr_mon_vif;
    virtual async_fifo_if.RD_MON rd_mon_vif;

    function new(string name = "afifo_cfg");
        super.new(name);
    endfunction

endclass