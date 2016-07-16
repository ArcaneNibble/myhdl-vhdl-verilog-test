from myhdl import *

@block
def Toplevel():
    # Clock generator
    clk = Signal(False)
    clkhalfperiod = delay(10)
    @always(clkhalfperiod)
    def clkGen():
        clk.next = not clk

    return (clkGen,)

toplevel_inst = Toplevel()
toplevel_inst.config_sim(trace=True)
toplevel_inst.run_sim(1000)
