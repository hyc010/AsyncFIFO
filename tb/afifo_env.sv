class afifo_env extends uvm_env;
    `uvm_component_utils(afifo_env)
    afifo_wr_agt wr_agent;
    afifo_rd_agt rd_agent;
    afifo_scoreboard m_scoreboard;
    afifo_coverage m_coverage;

    function new (string name = "afifo_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_agent = afifo_wr_agt :: type_id :: create("wr_agent", this);
        rd_agent = afifo_rd_agt :: type_id :: create("rd_agent", this);
        m_scoreboard = afifo_scoreboard :: type_id :: create("m_scoreboard", this);
        m_coverage = afifo_coverage :: type_id :: create("m_coverage", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        wr_agent.wr_monitor.wr_mon_ap.connect(m_scoreboard.wr_export);
        rd_agent.rd_monitor.rd_mon_ap.connect(m_scoreboard.rd_export);
    endfunction

endclass
