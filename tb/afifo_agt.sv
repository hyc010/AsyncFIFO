class afifo_wr_agt extends uvm_agent;
    `uvm_component_utils(afifo_wr_agt)
    afifo_wr_drv wr_driver;
    afifo_wr_mon wr_monitor;
    afifo_sqr wr_sequencer, rd_sequencer;
    
    function new (string name = "afifo_wr_agt", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function build_phase(uvm_phase phase);
        wr_driver = afifo_wr_drv :: type_id :: create("wr_driver", this);
        wr_monitor = afifo_wr_mon :: type_id :: create("wr_monitor", this);
        wr_sequencer = afifo_wr_sqr :: type_id :: create("wr_sequencer", this);
    endfunction

    virtual function connect_phase(uvm_phase phase)
        super.connect_phase(phase);
        wr_driver.seq_item_port.connect(wr_sequencer.seq_item_export);
    endfunction



endclass

class afifo_rd_agt extends uvm_agent;
    `uvm_component_utils(afifo_rd_agt)
    afifo_wr_drv rd_driver;
    afifo_wr_mon rd_monitor;
    afifo_wr_sqr rd_sequencer;
    
    function new (string name = "afifo_rd_agt", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function build_phase(uvm_phase phase);
        super.build_phase(phase);
        rd_driver = afifo_rd_drv :: type_id :: create("rd_driver", this);
        rd_monitor = afifo_rd_mon :: type_id :: create("rd_monitor", this);
        rd_sequencer = afifo_rd_sqr :: type_id :: create("rd_sequencer", this);
    endfunction

    virtual function connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        rd_driver.seq_item_port.connect(rd_sequencer.seq_item_export);
    endfunction


endclass