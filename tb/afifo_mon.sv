class afifo_wr_mon extends uvm_monitor;
    `uvm_component_utils(afifo_wr_mon)
    uvm_analysis_port #(afifo_tr) wr_mon_ap;

    afifo_cfg test_cfg;
    virtual async_fifo_if.WR_MON vif;
    function new(string name = "afifo_wr_mon", uvm_component parent = null);
        super.new(name, parent);
        wr_mon_ap = new("wr_mon_ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(afifo_cfg)::get(this, "", "test_cfg", test_cfg)) begin
            `uvm_fatal("NOVIF", "write cannot get virtual interface")
        end
        vif = test_cfg.wr_mon_vif;
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        begin
            afifo_tr tr;
            forever begin
                @(vif.wr_mon_cb);
                if (!vif.w_rst_n) begin
                    continue;
                end
                if (vif.wr_mon_cb.winc && !vif.wr_mon_cb.wfull) begin
                    tr = afifo_tr::type_id::create("wr_tr");
                    tr.en         = 1'b1;
                    tr.write_read = 1'b1;
                    tr.data       = vif.wr_mon_cb.wdata;
                    tr.wfull      = vif.wr_mon_cb.wfull;
                    wr_mon_ap.write(tr);
                end
            end
        end
    endtask

endclass


class afifo_rd_mon extends uvm_monitor;
    `uvm_component_utils(afifo_rd_mon)
    uvm_analysis_port #(afifo_tr) rd_mon_ap;

    afifo_cfg test_cfg;
    virtual async_fifo_if.RD_MON vif;

    function new(string name = "afifo_rd_mon", uvm_component parent = null);
        super.new(name, parent);
        rd_mon_ap = new("rd_mon_ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(afifo_cfg)::get(this, "", "test_cfg", test_cfg)) begin
            `uvm_fatal("NOVIF", "read cannot get virtual interface")
        end
        vif = test_cfg.rd_mon_vif;
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        begin
            afifo_tr tr;
            forever begin
                @(vif.rd_mon_cb);
                if (!vif.r_rst_n) begin
                    continue;
                end
                if (vif.rd_mon_cb.rinc && !vif.rd_mon_cb.rempty) begin
                    // fifo_mem updates rdata on this rclk edge. Clocking-block
                    // inputs are sampled before that update, so wait a tiny
                    // amount and sample the raw rdata after NBA updates.
                    #1ps;
                    tr = afifo_tr::type_id::create("rd_tr");
                    tr.en         = 1'b1;
                    tr.write_read = 1'b0;
                    tr.data       = vif.rdata;
                    tr.rempty     = 1'b0;
                    rd_mon_ap.write(tr);
                end
            end
        end
    endtask

endclass
