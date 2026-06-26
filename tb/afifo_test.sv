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
    `uvm_component_utils (basic_1w1r_test)
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

        wr_sequence.num_transactions = 16;
        rd_sequence.num_transactions = 16;

        // Step 1: Write 16 transactions to fill FIFO
        wr_sequence.start(m_env.wr_agent.wr_sequencer);

        // Step 2: Wait for CDC sync + data propagation
        #200;

        // Step 3: Read 16 transactions
        rd_sequence.start(m_env.rd_agent.rd_sequencer);

        // Allow monitor/scoreboard to receive the last sampled read item
        #100;
        
        phase.drop_objection(this);
    endtask
endclass


class write_full_test extends base_test;
    `uvm_component_utils(write_full_test)

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        afifo_write_seq wr_sequence;
        afifo_read_seq  rd_sequence;

        phase.raise_objection(this);

        wr_sequence = afifo_write_seq::type_id::create("wr_sequence");
        rd_sequence = afifo_read_seq ::type_id::create("rd_sequence");

        // Write more than FIFO depth. Depth is 16, so the last 4 writes
        // should happen while wfull is asserted and should not be accepted.
        wr_sequence.num_transactions = 20;
        rd_sequence.num_transactions = 20;

        wr_sequence.start(m_env.wr_agent.wr_sequencer);

        // Wait for write pointer synchronization into read clock domain.
        #300;

        // Read enough times to drain all accepted writes and also attempt
        // reads after empty. The monitor/scoreboard only publish valid reads.
        rd_sequence.start(m_env.rd_agent.rd_sequencer);

        #100;

        phase.drop_objection(this);
    endtask
endclass


class read_empty_test extends base_test;
    `uvm_component_utils(read_empty_test)

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        afifo_write_seq wr_sequence;
        afifo_read_seq  rd_sequence;

        phase.raise_objection(this);

        wr_sequence = afifo_write_seq::type_id::create("wr_sequence");
        rd_sequence = afifo_read_seq ::type_id::create("rd_sequence");

        // First try to read while FIFO is empty. These reads should be blocked
        // by rempty and should not create scoreboard transactions.
        rd_sequence.num_transactions = 4;
        rd_sequence.start(m_env.rd_agent.rd_sequencer);

        // Then write a small number of valid items.
        wr_sequence.num_transactions = 4;
        wr_sequence.start(m_env.wr_agent.wr_sequencer);

        // Wait for CDC synchronization before reading back.
        #200;

        // Read more than the number of valid writes. The extra reads should
        // happen when rempty is asserted and should not be accepted.
        rd_sequence.num_transactions = 8;
        rd_sequence.start(m_env.rd_agent.rd_sequencer);

        #100;

        phase.drop_objection(this);
    endtask
endclass
