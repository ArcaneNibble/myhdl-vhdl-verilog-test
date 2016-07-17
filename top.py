import binascii
import os
import sys

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

    # Assembling the AVR assembly code
    def assemble_avr(fn):
        os.system("avr-as -o {0}.o {0}.s".format(fn))
        os.system("avr-gcc -o {0}.elf -Wl,--section-start=.text=0 -nostartfiles {0}.o".format(fn))
        os.system("avr-objcopy -O binary {0}.elf {0}.bin".format(fn))

        f = open("{0}.bin".format(fn), 'rb')
        data = f.read()
        f.close()
        return data
    avrcode = assemble_avr("avrcode")

    # AVR PMEM
    @always(clk.posedge)
    def avr_pmem():
        if avr_pmem_ce:
            addr = int(avr_pmem_a)
            data = None
            if addr < len(avrcode) / 2:
                data = ord(avrcode[addr * 2]) | (ord(avrcode[addr * 2 + 1]) << 8)
            if data is None:
                print "ERROR AVR READ INVALID {:03X}".format(addr)
                data = 0
            else:
                print "AVR PMEM {:03X} => {:04X}".format(addr, data)

            avr_pmem_d.next = data

    # AVR I/O
    @always(clk.posedge)
    def avr_io_w():
        if avr_io_we:
            addr = int(avr_io_a)
            data = int(avr_io_do)

            if addr == 0x00:
                # Debug port
                sys.stdout.write("\x1b[31m{:c}\x1b[39m".format(data))
            else:
                print "ERROR AVR IO W {:02X} => {:02X}".format(data, addr)

    # Reset generator (temp)
    @instance
    def rst_tmp():
        avr_rst.next = 1;
        yield delay(11)
        avr_rst.next = 0;

    return (clk_gen, rst_tmp, avr_pmem, avr_io_w)

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

# J-core cosimulation
def jcore():
    os.system("perl v2p <datapath.vhm >datapath.vhd")
    os.system("perl v2p <decode_core.vhm >decode_core.vhd")
    os.system("perl v2p <mult.vhm >mult.vhd")

    os.system("ghdl -a cpu2j0_pkg.vhd components_pkg.vhd mult_pkg.vhd decode_pkg.vhd datapath_pkg.vhd cpu.vhd mult.vhd datapath.vhd register_file.vhd decode.vhd decode_body.vhd decode_table.vhd decode_core.vhd decode_table_simple.vhd decode_table_simple_config.vhd decode_table_reverse.vhd decode_table_reverse_config.vhd decode_table_rom.vhd decode_table_rom_config.vhd cpu_config.vhd jcore_unrecord_wrap.vhd dut_jcore_cpu.vhd")
    os.system("ghdl -e dut_jcore_cpu")

jcore()
sys.exit(1)

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
