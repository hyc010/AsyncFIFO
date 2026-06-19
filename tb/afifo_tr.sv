class afifo_tr extends uvm_sequence_item;

    rand bit en;
    rand bit write_read;         // write when 1, read when 0
    rand bit [7:0] data;

    bit wfull;
    bit rempty;

     `uvm_object_utils_begin(afifo_tr)
        `uvm_field_int(en, UVM_ALL_ON);
        `uvm_field_int(write_read, UVM_ALL_ON);
        `uvm_field_int(data, UVM_ALL_ON);
        `uvm_field_int(wfull, UVM_ALL_ON);
        `uvm_field_int(rempty, UVM_ALL_ON);
    `uvm_object_utils_end

    

    function new(string name = "afifo_tr");
        super.new(name);
    endfunction

endclass