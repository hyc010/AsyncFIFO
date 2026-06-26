class afifo_wr_drv extends uvm_driver #(afifo_tr);
    `uvm_component_utils(afifo_wr_drv)

    afifo_cfg test_cfg;
    virtual async_fifo_if.WR_DRV vif;
    afifo_tr req;

    function new(string name = "afifo_wr_drv", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(afifo_cfg)::get(this, "", "test_cfg", test_cfg)) begin
             `uvm_fatal("NOVIF", "write cannot get virtual interface")
        end
        vif = test_cfg.wr_drv_vif;
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        vif.wr_drv_cb.winc <= 1'b0;
        wait(vif.w_rst_n == 1'b1);

        forever begin
            seq_item_port.get_next_item(req);
            if(req.write_read) begin
                @(vif.wr_drv_cb);
                vif.wr_drv_cb.winc <= req.en;
                vif.wr_drv_cb.wdata <= req.data;
                @(vif.wr_drv_cb);
                vif.wr_drv_cb.winc <= 1'b0;
            end
            else begin
                `uvm_error("WR_DRV_ERR", "write driver receives a read transaction")
            end
            seq_item_port.item_done();
        end
    endtask
endclass


class afifo_rd_drv extends uvm_driver #(afifo_tr);
    `uvm_component_utils(afifo_rd_drv)

    afifo_cfg test_cfg;
    virtual async_fifo_if.RD_DRV vif;
    afifo_tr req;

    function new(string name = "afifo_rd_drv", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(afifo_cfg) ::get (this, "", "test_cfg", test_cfg)) begin
             `uvm_fatal("NOVIF", "read cannot get virtual interface")
        end
        vif = test_cfg.rd_drv_vif;
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        vif.rd_drv_cb.rinc <= 0;
        wait(vif.r_rst_n == 1'b1);

        forever begin
            seq_item_port.get_next_item(req);
            if(!req.write_read) begin
                // T0: assert read enable
                @(vif.rd_drv_cb);
                vif.rd_drv_cb.rinc <= 1'b1;
                // T1: sample data while rinc still high, then deassert
                @(vif.rd_drv_cb);
                req.data = vif.rd_drv_cb.rdata;
                vif.rd_drv_cb.rinc <= 1'b0;
            end
            else begin
                `uvm_error("RD_DRV_ERR", "read driver receives a write request")
            end
            seq_item_port.item_done();
        end
    endtask

endclass
