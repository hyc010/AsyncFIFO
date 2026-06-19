class afifo_wr_mon extends uvm_monitor;
    `uvm_component_utils(afifo_wr_mon)
    uvm_analysis_port #(afifo_tr) wr_mon_ap;

    afifo_cfg test_cfg;
    virtual async_fifo_if.WR_MON vif;
    function new(string name = "afifo_wr_mon", uvm_component parent = null);
        super.new(name, parent);
        wr_mon_ap = new("wr_mon_ap", this);
    endfunction

    virtual function build_phase(uvm_phase phase);
        if(!uvm_config_db #(afifo_cfg)::get(this, "", "test_cfg", test_cfg)) begin
            `uvm_fatal("NOVIF", "write cannot get virtual interface")
        end
        vif = test_cfg.wr_mon_vif;    // connect to write monitor interface
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        afifo_tr tr;
        forever begin
            @(vif.wr_mon_cb);
            if (vif.wr_mon_cb.winc) begin //采集正确的数据
                tr = afifo_tr::type_id::create("wr_tr");
                tr.en         = 1'b1;
                tr.write_read = 1'b1;
                tr.data       = vif.wr_mon_cb.wdata;
                tr.wfull      = vif.wr_mon_cb.wfull;
            end
            wr_mon_ap.write(tr);

        end
    endtask


endclass

class afifo_rd_mon extends uvm_monitor;
    `uvm_component_utils(afifo_wr_mon)
    uvm_analysis_port #(afifo_tr) rd_mon_ap;

    afifo_cfg test_cfg;

    virtual async_fifo_if.RD_MON vif;
    function new(string name = "afifo_rd_mon", uvm_component parent = null)
        super.new(name, parent);
    endfunction

    virtual function build_phase(uvm_phase phase);
        if(!uvm_config_db #(afifo_cfg)::get(this, "", "test_cfg", test_cfg)) begin
            `uvm_fatal("NOVIF", "read cannot get virtual interface")
        end
        vif = test_cfg.rd_mon_vif;
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        afifo_tr tr;
        forever begin
            @(vif.rd_mon_cb)
            if (vif.wr_mon_cb.rinc) begin
                tr = afifo_tr::type_id::create("rd_tr");
                tr.en         = 1'b1;
                tr.write_read = 1'b1;
                tr.data       = vif.wr_mon_cb.wdata;
                tr.wfull      = vif.wr_mon_cb.wfull;
            end
        end
    endtask
    
endclass