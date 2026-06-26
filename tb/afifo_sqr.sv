class afifo_sqr extends uvm_sequencer #(afifo_tr);

    `uvm_component_utils(afifo_sqr)

    function new(string name = "afifo_sqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction


endclass


class afifo_wr_sqr extends afifo_sqr;
    `uvm_component_utils(afifo_wr_sqr)

    function new(string name = "afifo_wr_sqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass


class afifo_rd_sqr extends afifo_sqr;
    `uvm_component_utils(afifo_rd_sqr)

    function new(string name = "afifo_rd_sqr", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass