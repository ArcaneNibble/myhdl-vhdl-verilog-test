module dut_softusb_navre;
    reg clk;
    reg rst;

    // FIXME: parameter handling
    wire pmem_ce;
    wire [10:0] pmem_a;
    reg [15:0] pmem_d;

    wire dmem_we;
    wire [12:0] dmem_a;
    reg [7:0] dmem_di;
    wire [7:0] dmem_do;

    wire io_re;
    wire io_we;
    wire [5:0] io_a;
    wire [7:0] io_do;
    reg [7:0] io_di;

    reg [7:0] irq;
    wire [7:0] irq_ack;

    softusb_navre dut (
        .clk(clk),
        .rst(rst),

        .pmem_ce(pmem_ce),
        .pmem_a(pmem_a),
        .pmem_d(pmem_d),

        .dmem_we(dmem_we),
        .dmem_a(dmem_a),
        .dmem_di(dmem_di),
        .dmem_do(dmem_do),

        .io_re(io_re),
        .io_we(io_we),
        .io_a(io_a),
        .io_do(io_do),
        .io_di(io_di),

        .irq(irq),
        .irq_ack(irq_ack)
    );

    initial begin
        $from_myhdl(clk, rst, pmem_d, dmem_di, io_di, irq);
        $to_myhdl(pmem_ce, pmem_a, dmem_we, dmem_a, dmem_do,
            io_re, io_we, io_a, io_do, irq_ack);
    end

endmodule
