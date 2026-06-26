`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)

class afifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(afifo_scoreboard)

    uvm_analysis_imp_wr #(afifo_tr, afifo_scoreboard) wr_export;
    uvm_analysis_imp_rd #(afifo_tr, afifo_scoreboard) rd_export;

    bit [7:0] expect_queue[$];

    int write_count    = 0;
    int read_count     = 0;
    int match_count    = 0;
    int mismatch_count = 0;

    function new(string name = "afifo_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        wr_export = new("wr_export", this);
        rd_export = new("rd_export", this);
    endfunction

    virtual function void write_wr(afifo_tr tr);
        if (tr.write_read && tr.en) begin
            expect_queue.push_back(tr.data);
            write_count++;
            `uvm_info("SCB_WR",
                $sformatf("Write: 0x%02X, queue_size=%0d", tr.data, expect_queue.size()),
                UVM_MEDIUM)
        end
    endfunction

    virtual function void write_rd(afifo_tr tr);
        bit [7:0] expected;

        if (!tr.write_read && tr.en) begin
            read_count++;

            if (expect_queue.size() == 0) begin
                `uvm_error("SCB_UNEXP",
                    $sformatf("Unexpected read! Data=0x%02X, but FIFO empty", tr.data))
                return;
            end

            expected = expect_queue.pop_front();

            if (expected !== tr.data) begin
                mismatch_count++;
                `uvm_error("SCB_MISMATCH",
                    $sformatf("Data mismatch! Expected=0x%02X, Got=0x%02X", expected, tr.data))
            end else begin
                match_count++;
                `uvm_info("SCB_MATCH",
                    $sformatf("Match! Expected=0x%02X, Got=0x%02X", expected, tr.data),
                    UVM_MEDIUM)
            end
        end
    endfunction

    virtual function void check_phase(uvm_phase phase);
        if (expect_queue.size() != 0) begin
            `uvm_error("SCB_LEFTOVER",
                $sformatf("Simulation ended but %0d items still in FIFO!", expect_queue.size()))
        end

        `uvm_info("SCB_REPORT", $sformatf(
            "\n========================================\n       Scoreboard Final Report          \n========================================\n  Total Writes : %0d\n  Total Reads  : %0d\n  Matches      : %0d\n  Mismatches   : %0d\n  Leftover     : %0d\n========================================",
            write_count, read_count, match_count, mismatch_count, expect_queue.size()),
            UVM_LOW)
    endfunction
endclass
