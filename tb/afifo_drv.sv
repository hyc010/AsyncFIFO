class afifo_wr_drv extends uvm_driver;
    `uvm_component_utils(afifo_wr_drv)

    afifo_cfg test_cfg;
    virtual async_fifo_if.WR_DRV vif;
    function new(string name = "afifo_wr_drv", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(afifo_cfg)::get(this, "", "test_cfg", test_cfg)) begin
             `uvm_fatal("NOVIF", "write cannot get virtual interface")
        end
        vif = test_cfg.wr_drv_vif;       //connect virual interface in config_db to that in this component
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        vif.wr_drv_cb.winc <= 1'b0;
        vif.wr_drv_cb.winc <= '0;

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


class afifo_rd_drv extends uvm_driver;
    `uvm_component_utils(afifo_rd_drv)

    afifo_cfg test_cfg;
    virtual async_fifo_if.RD_DRV vif;
    function new(string name = "afifo_rd_drv", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(afifo_cfg) ::get (this, "", "test_cfg", test_cfg)) begin
             `uvm_fatal("NOVIF", "read cannot get virtual interface")
        end
        vif = test_cfg.rd_drv_vif;
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        vif.rd_drv_cb.rinc <= 0;

        forever begin
            seq_item_port.get_next_item(req);
            if(!req.write_read) begin
                @(vif.rd_drv_cb);
                vif.rd_drv_cb.rinc <= 1'b1;
                @(vif.rd_drv_cb);
                vif.rd_drv_cb.rinc <= 1'b0;
            end
            else begin
                `uvm_error("RD_DRV_ERR", "read driver receives a write request")
            end
            seq_item_port.item_done();
        end
    endtask


endclass