This project is a demonstration of an SoC containing a [J-core CPU](http://j-core.org/) combined with a [Navré AVR CPU](https://github.com/m-labs/milkymist/blob/master/cores/softusb/rtl/softusb_navre.v) as a co-processor. The glue logic between these processors is written in [MyHDL](http://www.myhdl.org/).

The purpose of this demonstration was two-fold. The first objective was to test driving multiple external simulators, each running a design of moderate complexity, from a single MyHDL simulation. The second objective was to run what is possibly the first mixed VHDL and Verilog simulation using only open-source tools (feel free to correct me if this has been done before).

All of the glue logic for this SoC lives in `top.py`. It is a giant pile of not-very-elegant MyHDL implementing program ROMs for both CPUs, a debug port for each CPU, and a block of shared RAM for the CPUs to communicate with each other. The J-core CPU also has control over the AVR's reset line. In theory, this SoC could actually be made to work in an FPGA or ASIC, but, in this demonstration, no attempt was made to ensure the glue logic is synthesizable.

This demonstration unfortunately requires a large number of dependencies to actually run:
* MyHDL with [my patches](https://github.com/rqou/myhdl/tree/rqou_all_patches). Patches were required to remove MyHDL's existing limitation of only one external simulator at a time.
* [GHDL](http://ghdl.free.fr/). This demonstration was only tested with revision 6cfcd2e1b and the GCC backend.
* [Icarus Verilog](http://iverilog.icarus.com/). This demonstration was only tested with version 0.9.7 from the Debian Sid repository.
* avr-gcc cross-compiler. Any version should work. This is needed to assemble the ROM for Navré.
* [Rob Landley's sh2elf cross-compiler](http://landley.net/aboriginal/bin/cross-compiler-sh2elf.tar.gz). This is needed to assemble the ROM for J-core.
* You will need an x86_64 Linux machine to run the demonstration as-is. This is because of the binary .vpi files checked in to the repository. Alternatively, you can try to recompile these .vpi files (will require a native C compiler and possibly other stuff):
    * myhdl-icarus.vpi is compiled from the `cosimulation/icarus` directory that is part of MyHDL.
    * myhdl-ghdl.vpi is compiled from [this code I wrote](https://github.com/rqou/myhdl-ghdl-duct-tape). This code will eventually be submitted to MyHDL after it is cleaned up.
* You will probably need a Linux machine even if it isn't x86_64. Windows and Mac were not tested.
* Perl is required because of the `v2p` script that is part of J-core.

If the simulation is running correctly, it should eventually print out
```
SH2 is booting!
TO AVR: 0000007B
AVR is booting!
AVR is done!
FROM AVR: 000000F6
TO AVR: 000001C8
AVR is booting!
AVR is done!
FROM AVR: 00000243
TO AVR: 12345678
AVR is booting!
AVR is done!
FROM AVR: 123456F3
TO AVR: ABCDEF00
AVR is booting!
AVR is done!
FROM AVR: ABCDEF7B
TO AVR: DEADBEEF
AVR is booting!
AVR is done!
FROM AVR: DEADBF6A
SH2 is done!
```
Green output comes from the J-core debug port, and red output comes from the Navré debug port. The Navré coprocessor reads an input from shared RAM and adds 123 to it. The J-core then reads the output and prints it.
