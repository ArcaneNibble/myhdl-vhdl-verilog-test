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
             avr_irq_ack,
             j2_rst,
             j2_db_en,
             j2_db_a,
             j2_db_rd,
             j2_db_wr,
             j2_db_we,
             j2_db_do,
             j2_db_lock,
             j2_db_di,
             j2_db_ack,
             j2_inst_en,
             j2_inst_a,
             j2_inst_jp,
             j2_inst_d,
             j2_inst_ack,
             j2_debug_ack,
             j2_debug_do,
             j2_debug_rdy,
             j2_debug_en,
             j2_debug_cmd,
             j2_debug_ir,
             j2_debug_di,
             j2_debug_d_en,
             j2_event_ack,
             j2_event_lvl_o,
             j2_event_slp,
             j2_event_dbg,
             j2_event_en,
             j2_event_cmd,
             j2_event_vec,
             j2_event_msk,
             j2_event_lvl_i):
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
        j2_rst.next = 1;
        yield delay(11)
        avr_rst.next = 0;
        j2_rst.next = 0;

    # Assembling the SH2 assembly code
    def assemble_sh2(fn):
        os.system("sh2elf-as -o {0}.o {0}.s".format(fn))
        os.system("sh2elf-gcc -o {0}.elf -Wl,--section-start=.text=0 -nostartfiles -nostdlib {0}.o".format(fn))
        os.system("sh2elf-objcopy -O binary --only-section=.text {0}.elf {0}.bin".format(fn))

        f = open("{0}.bin".format(fn), 'rb')
        data = f.read()
        f.close()
        return data
    j2code = assemble_sh2("sh2code")

    # J2 IRAM
    @always(j2_inst_en, j2_inst_a)
    def j2_iram():
        if j2_inst_en:
            addr = int(j2_inst_a)
            data = None
            if addr < len(j2code) / 2:
                data = ord(j2code[addr * 2 + 1]) | (ord(j2code[addr * 2]) << 8)
            if data is None:
                print "ERROR J2 IREAD INVALID {:08X}".format(addr)
                data = 0
            else:
                print "J2 IRAM {:08X} => {:04X}".format(addr, data)

            j2_inst_d.next = data
            j2_inst_ack.next = True
        else:
            j2_inst_ack.next = False

    # J2 DRAM
    @always(j2_db_en, j2_db_a, j2_db_rd, j2_db_wr, j2_db_we, j2_db_do)
    def j2_dram():
        if j2_db_en:
            addr = int(j2_db_a) & ~3
            datain = int(j2_db_do)
            if j2_db_rd:
                data = None
                if (addr + 3) < len(j2code):
                    data = (ord(j2code[addr + 3]) |
                            (ord(j2code[addr + 2]) << 8) |
                            (ord(j2code[addr + 1]) << 16) |
                            (ord(j2code[addr]) << 24))
                if data is None:
                    print "ERROR J2 DREAD INVALID {:08X}".format(addr)
                    data = 0
                else:
                    print "J2 DRAM {:08X} => {:08X}".format(addr, data)

                j2_db_di.next = data
            if j2_db_wr:
                if addr == 0xaaaa0000:
                    # Debug port
                    sys.stdout.write("\x1b[32m{:c}\x1b[39m".format(
                        datain & 0xFF))
                else:
                    print "ERROR J2 DWRITE INVALID {:08X} => {:08X}".format(
                        datain, addr)
            j2_db_ack.next = True
        else:
            j2_db_ack.next = False

    return (clk_gen, rst_tmp, avr_pmem, avr_io_w, j2_iram, j2_dram)

# Navre AVR cosimulation
def navre(clk,
          rst,
          pmem_ce,
          pmem_a,
          pmem_d,
          dmem_we,
          dmem_a,
          dmem_di,
          dmem_do,
          io_re,
          io_we,
          io_a,
          io_do,
          io_di,
          irq,
          irq_ack):
    os.system("iverilog -o navre softusb_navre.v dut_softusb_navre.v")
    return Cosimulation("vvp -m ./myhdl-icarus.vpi navre",
        clk=clk,
        rst=rst,
        pmem_ce=pmem_ce,
        pmem_a=pmem_a,
        pmem_d=pmem_d,
        dmem_we=dmem_we,
        dmem_a=dmem_a,
        dmem_di=dmem_di,
        dmem_do=dmem_do,
        io_re=io_re,
        io_we=io_we,
        io_a=io_a,
        io_do=io_do,
        io_di=io_di,
        irq=irq,
        irq_ack=irq_ack)

# J-core cosimulation
def jcore(clk,
          rst,
          db_en,
          db_a,
          db_rd,
          db_wr,
          db_we,
          db_do,
          db_lock,
          db_di,
          db_ack,
          inst_en,
          inst_a,
          inst_jp,
          inst_d,
          inst_ack,
          debug_ack,
          debug_do,
          debug_rdy,
          debug_en,
          debug_cmd,
          debug_ir,
          debug_di,
          debug_d_en,
          event_ack,
          event_lvl_o,
          event_slp,
          event_dbg,
          event_en,
          event_cmd,
          event_vec,
          event_msk,
          event_lvl_i):
    os.system("perl v2p <datapath.vhm >datapath.vhd")
    os.system("perl v2p <decode_core.vhm >decode_core.vhd")
    os.system("perl v2p <mult.vhm >mult.vhd")

    os.system("ghdl -a cpu2j0_pkg.vhd components_pkg.vhd mult_pkg.vhd decode_pkg.vhd datapath_pkg.vhd cpu.vhd mult.vhd datapath.vhd register_file.vhd decode.vhd decode_body.vhd decode_table.vhd decode_core.vhd decode_table_reverse.vhd decode_table_reverse_config.vhd cpu_config.vhd jcore_unrecord_wrap.vhd dut_jcore_cpu.vhd")
    os.system("ghdl -e dut_jcore_cpu")

    return Cosimulation("./dut_jcore_cpu --wave=j2.ghw --vpi=./myhdl-ghdl.vpi",
        from_myhdl_clk=clk,
        from_myhdl_rst=rst,
        to_myhdl_db_en=db_en,
        to_myhdl_db_a=db_a,
        to_myhdl_db_rd=db_rd,
        to_myhdl_db_wr=db_wr,
        to_myhdl_db_we=db_we,
        to_myhdl_db_do=db_do,
        to_myhdl_db_lock=db_lock,
        from_myhdl_db_di=db_di,
        from_myhdl_db_ack=db_ack,
        to_myhdl_inst_en=inst_en,
        to_myhdl_inst_a=inst_a,
        to_myhdl_inst_jp=inst_jp,
        from_myhdl_inst_d=inst_d,
        from_myhdl_inst_ack=inst_ack,
        to_myhdl_debug_ack=debug_ack,
        to_myhdl_debug_do=debug_do,
        to_myhdl_debug_rdy=debug_rdy,
        from_myhdl_debug_en=debug_en,
        from_myhdl_debug_cmd=debug_cmd,
        from_myhdl_debug_ir=debug_ir,
        from_myhdl_debug_di=debug_di,
        from_myhdl_debug_d_en=debug_d_en,
        to_myhdl_event_ack=event_ack,
        to_myhdl_event_lvl_o=event_lvl_o,
        to_myhdl_event_slp=event_slp,
        to_myhdl_event_dbg=event_dbg,
        from_myhdl_event_en=event_en,
        from_myhdl_event_cmd=event_cmd,
        from_myhdl_event_vec=event_vec,
        from_myhdl_event_msk=event_msk,
        from_myhdl_event_lvl_i=event_lvl_i)

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

j2_rst = Signal(False)
j2_db_en = Signal(False)
j2_db_a = Signal(intbv(0)[32:])
j2_db_rd = Signal(False)
j2_db_wr = Signal(False)
j2_db_we = Signal(intbv(0)[4:])
j2_db_do = Signal(intbv(0)[32:])
j2_db_lock = Signal(False)
j2_db_di = Signal(intbv(0)[32:])
j2_db_ack = Signal(False)
j2_inst_en = Signal(False)
j2_inst_a = Signal(intbv(0)[32:1])
j2_inst_jp = Signal(False)
j2_inst_d = Signal(intbv(0)[16:])
j2_inst_ack = Signal(False)
j2_debug_ack = Signal(False)
j2_debug_do = Signal(intbv(0)[32:])
j2_debug_rdy = Signal(False)
j2_debug_en = Signal(False)
j2_debug_cmd = Signal(intbv(0)[2:])
j2_debug_ir = Signal(intbv(0)[16:])
j2_debug_di = Signal(intbv(0)[32:])
j2_debug_d_en = Signal(False)
j2_event_ack = Signal(False)
j2_event_lvl_o = Signal(intbv(0)[4:])
j2_event_slp = Signal(False)
j2_event_dbg = Signal(False)
j2_event_en = Signal(False)
j2_event_cmd = Signal(intbv(0)[2:])
j2_event_vec = Signal(intbv(0)[8:])
j2_event_msk = Signal(False)
j2_event_lvl_i = Signal(intbv(0)[4:])

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
    avr_irq_ack,
    j2_rst,
    j2_db_en,
    j2_db_a,
    j2_db_rd,
    j2_db_wr,
    j2_db_we,
    j2_db_do,
    j2_db_lock,
    j2_db_di,
    j2_db_ack,
    j2_inst_en,
    j2_inst_a,
    j2_inst_jp,
    j2_inst_d,
    j2_inst_ack,
    j2_debug_ack,
    j2_debug_do,
    j2_debug_rdy,
    j2_debug_en,
    j2_debug_cmd,
    j2_debug_ir,
    j2_debug_di,
    j2_debug_d_en,
    j2_event_ack,
    j2_event_lvl_o,
    j2_event_slp,
    j2_event_dbg,
    j2_event_en,
    j2_event_cmd,
    j2_event_vec,
    j2_event_msk,
    j2_event_lvl_i)
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
j2_inst = jcore(
    clk,
    j2_rst,
    j2_db_en,
    j2_db_a,
    j2_db_rd,
    j2_db_wr,
    j2_db_we,
    j2_db_do,
    j2_db_lock,
    j2_db_di,
    j2_db_ack,
    j2_inst_en,
    j2_inst_a,
    j2_inst_jp,
    j2_inst_d,
    j2_inst_ack,
    j2_debug_ack,
    j2_debug_do,
    j2_debug_rdy,
    j2_debug_en,
    j2_debug_cmd,
    j2_debug_ir,
    j2_debug_di,
    j2_debug_d_en,
    j2_event_ack,
    j2_event_lvl_o,
    j2_event_slp,
    j2_event_dbg,
    j2_event_en,
    j2_event_cmd,
    j2_event_vec,
    j2_event_msk,
    j2_event_lvl_i)
toplevel_inst.config_sim(trace=True)
sim = Simulation(toplevel_inst, navre_inst, j2_inst)
sim.run(1000)
