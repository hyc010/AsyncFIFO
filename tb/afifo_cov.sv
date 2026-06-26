class afifo_coverage extends uvm_component;
    `uvm_component_utils(afifo_coverage)

    afifo_cfg test_cfg;

    covergroup wr_cg with function sample(
        bit       rst_n,
        bit       winc,
        bit       wfull,
        bit [7:0] wdata
    );
        option.per_instance = 1;

        cp_winc: coverpoint winc iff (rst_n) {
            bins idle  = {0};
            bins write = {1};
        }

        cp_wfull: coverpoint wfull iff (rst_n) {
            bins not_full = {0};
            bins full     = {1};
        }

        cp_wfull_trans: coverpoint wfull iff (rst_n) {
            bins full_rise = (0 => 1);
            bins full_fall = (1 => 0);
        }

        cp_wdata: coverpoint wdata iff (rst_n && winc && !wfull) {
            bins zero = {8'h00};
            bins low  = {[8'h01:8'h3f]};
            bins mid  = {[8'h40:8'hbf]};
            bins high = {[8'hc0:8'hfe]};
            bins all1 = {8'hff};
        }

        cross_winc_wfull: cross cp_winc, cp_wfull;
    endgroup

    covergroup rd_cg with function sample(
        bit       rst_n,
        bit       rinc,
        bit       rempty,
        bit [7:0] rdata
    );
        option.per_instance = 1;

        cp_rinc: coverpoint rinc iff (rst_n) {
            bins idle = {0};
            bins read = {1};
        }

        cp_rempty: coverpoint rempty iff (rst_n) {
            bins not_empty = {0};
            bins empty     = {1};
        }

        cp_rempty_trans: coverpoint rempty iff (rst_n) {
            bins empty_rise = (0 => 1);
            bins empty_fall = (1 => 0);
        }

        cp_rdata: coverpoint rdata iff (rst_n && rinc && !rempty) {
            bins zero = {8'h00};
            bins low  = {[8'h01:8'h3f]};
            bins mid  = {[8'h40:8'hbf]};
            bins high = {[8'hc0:8'hfe]};
            bins all1 = {8'hff};
        }

        cross_rinc_rempty: cross cp_rinc, cp_rempty;
    endgroup

    function new(string name = "afifo_coverage", uvm_component parent = null);
        super.new(name, parent);
        wr_cg = new();
        rd_cg = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(afifo_cfg)::get(this, "", "test_cfg", test_cfg)) begin
            `uvm_fatal("NOCFG", "coverage collector cannot get test_cfg")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        fork
            forever begin
                @(test_cfg.wr_mon_vif.wr_mon_cb);
                wr_cg.sample(
                    test_cfg.wr_mon_vif.w_rst_n,
                    test_cfg.wr_mon_vif.wr_mon_cb.winc,
                    test_cfg.wr_mon_vif.wr_mon_cb.wfull,
                    test_cfg.wr_mon_vif.wr_mon_cb.wdata
                );
            end

            forever begin
                @(test_cfg.rd_mon_vif.rd_mon_cb);
                rd_cg.sample(
                    test_cfg.rd_mon_vif.r_rst_n,
                    test_cfg.rd_mon_vif.rd_mon_cb.rinc,
                    test_cfg.rd_mon_vif.rd_mon_cb.rempty,
                    test_cfg.rd_mon_vif.rd_mon_cb.rdata
                );
            end
        join
    endtask

    virtual function void report_phase(uvm_phase phase);
        real wr_cov;
        real rd_cov;
        real total_cov;

        super.report_phase(phase);

        wr_cov    = wr_cg.get_coverage();
        rd_cov    = rd_cg.get_coverage();
        total_cov = (wr_cov + rd_cov) / 2.0;

        `uvm_info("COV_REPORT", $sformatf(
            "\n========================================\n       Coverage Final Report            \n========================================\n  Write Coverage : %0.2f%%\n  Read Coverage  : %0.2f%%\n  Total Coverage : %0.2f%%\n========================================",
            wr_cov, rd_cov, total_cov),
            UVM_LOW)
    endfunction
endclass
