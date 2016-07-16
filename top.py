import os

from myhdl import *

@block
def Toplevel(clk,
             avr_rst,
             avr_pmem_ce,
             avr_pmem_a,
             avr_pmem_d,
             avr_dmem_we,
             avr_dmem_a,
             avr_dmem_di,
             avr_dmem_do,
             avr_io_re,
             avr_io_we,
             avr_io_a,
             avr_io_do,
             avr_io_di,
             avr_irq,
             avr_irq_ack):
    # Clock generator
    clkhalfperiod = delay(10)
    @always(clkhalfperiod)
    def clk_gen():
        clk.next = not clk

    # Reset generator (temp)
    @instance
    def rst_tmp():
        avr_rst.next = 1;
        yield delay(11)
        avr_rst.next = 0;

    return (clk_gen, rst_tmp)

# Navre AVR cosimulation
def navre(clk,
          avr_rst,
          avr_pmem_ce,
          avr_pmem_a,
          avr_pmem_d,
          avr_dmem_we,
          avr_dmem_a,
          avr_dmem_di,
          avr_dmem_do,
          avr_io_re,
          avr_io_we,
          avr_io_a,
          avr_io_do,
          avr_io_di,
          avr_irq,
          avr_irq_ack):
    os.system("iverilog -o navre softusb_navre.v dut_softusb_navre.v")
    return Cosimulation("vvp -m ./myhdl-icarus.vpi navre",
        clk=clk,
        rst=avr_rst,
        pmem_ce=avr_pmem_ce,
        pmem_a=avr_pmem_a,
        pmem_d=avr_pmem_d,
        dmem_we=avr_dmem_we,
        dmem_a=avr_dmem_a,
        dmem_di=avr_dmem_di,
        dmem_do=avr_dmem_do,
        io_re=avr_io_re,
        io_we=avr_io_we,
        io_a=avr_io_a,
        io_do=avr_io_do,
        io_di=avr_io_di,
        irq=avr_irq,
        irq_ack=avr_irq_ack)

# FIXME move this?
clk = Signal(False)

avr_rst = Signal(False)
avr_pmem_ce = Signal(False)
avr_pmem_a = Signal(intbv(0)[11:])
avr_pmem_d = Signal(intbv(0)[16:])
avr_dmem_we = Signal(False)
avr_dmem_a = Signal(intbv(0)[13:])
avr_dmem_di = Signal(intbv(0)[8:])
avr_dmem_do = Signal(intbv(0)[8:])
avr_io_re = Signal(False)
avr_io_we = Signal(False)
avr_io_a = Signal(intbv(0)[13:])
avr_io_do = Signal(intbv(0)[8:])
avr_io_di = Signal(intbv(0)[8:])
avr_irq = Signal(intbv(0)[8:])
avr_irq_ack = Signal(intbv(0)[8:])

toplevel_inst = Toplevel(
    clk,
    avr_rst,
    avr_pmem_ce,
    avr_pmem_a,
    avr_pmem_d,
    avr_dmem_we,
    avr_dmem_a,
    avr_dmem_di,
    avr_dmem_do,
    avr_io_re,
    avr_io_we,
    avr_io_a,
    avr_io_do,
    avr_io_di,
    avr_irq,
    avr_irq_ack)
navre_inst = navre(
    clk,
    avr_rst,
    avr_pmem_ce,
    avr_pmem_a,
    avr_pmem_d,
    avr_dmem_we,
    avr_dmem_a,
    avr_dmem_di,
    avr_dmem_do,
    avr_io_re,
    avr_io_we,
    avr_io_a,
    avr_io_do,
    avr_io_di,
    avr_irq,
    avr_irq_ack)
toplevel_inst.config_sim(trace=True)
sim = Simulation(toplevel_inst, navre_inst)
sim.run(1000)
