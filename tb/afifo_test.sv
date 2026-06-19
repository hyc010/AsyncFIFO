class base_test extends uvm_test;
    `uvm_component_utils (base_test)

    function new(string name, uvm_component parent = null);
        super.new (name, parent);
    endfunction

    afifo_env m_env;

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        m_env = afifo_env :: type_id :: create("m_env", this);
    endfunction

    virtual task run_phase (uvm_phase phase);
    endtask
    
endclass

class basic_1w1r_test extends base_test;
    `uvm_component_utils (basic_1w1c_test)
    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase (uvm_phase phase);
        afifo_write_seq wr_sequence;
        afifo_read_seq rd_sequence;
        phase.raise_objection(this);
        
        wr_sequence = afifo_write_seq::type_id::create("wr_sequence");
        rd_sequence = afifo_read_seq::type_id::create("rd_sequence");

        wr_sequence.start(m_env.wr_agent.wr_sequencer);
        rd_sequence.start(m_env.rd_agent.rd_sequencer);
        
        phase.drop_objection(this);
    endtask
endclass