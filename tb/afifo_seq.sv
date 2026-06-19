 class afifo_base_seq extends uvm_sequence #(afifo_tr);
    `uvm_object_utils (afifo_base_seq)
    `uvm_declare_p_sequencer(afifo_sqr)

    afifo_tr tr_data;

    function new(string name = "afifo");
        super.new(name);
    endfunction

    virtual task body ();
        // tr_data = afifo_tr :: type_id :: create("tr_data");

    endtask

 endclass

 class afifo_write_seq extends afifo_base_seq;
    `uvm_object_utils (afifo_write_seq)

    function new(string name = "afifo_write_seq");
        super.new(name);
    endfunction

    virtual task body ();
        tr_data = afifo_tr :: type_id :: create("tr_data");
        start_item(tr_data);
        assert(tr_data.randomize() with {
            en == 1;
            write_read == 1;
        })
        else
            `uvm_fatal("RAND_FAIL")
        finish_item(tr_data);
    endtask

 endclass