class afifo_env extends uvm_env;
    `uvm_component_utils(afifo_env)
    afifo_wr_agt wr_agent;
    afifo_rd_agt rd_agent;
    afifo_scoreboard m_scoreboard;

    function new (string name = "afifo_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

virtual function build_phase(uvm_phase phase);
    wr_agent = afifo_agent :: type_id :: create("wr_agent", this);
    rd_agent = afifo_agent :: type_id :: create("rd_agent", this);
    m_scorebord = afifo_scoreboard :: type_id :: create("m_scoreboard", this);
endfunction

endclass