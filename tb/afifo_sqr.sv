class afifo_sqr extends uvm_sequencer #(afifo_tr);

    `uvm_component_utils(afifo_sqr)

    function new(string name = "afifo_sqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction


endclass