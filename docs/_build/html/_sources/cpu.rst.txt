Central Processing Unit
=======================

The CPU of the NES was developed by Ricoh and it is called **RP2A03**. This chip
is almost an identical copy of the CPU **6502** made by MOS Technology.

Binary Coded Decimal mode is not supported on 2A03 because 5 transistors were
removed from the original 6502. One can still set and clear the decimal flag,
but it will not have an effect electrically. This was almost certainly done
because of copyright rules, since MOS Technology filed a patent for their
parallel decimal number adder. :cite:p:`adder:patent` :cite:p:`2A03:chipimages`

I do not have to worry about copyright laws (hopefully), so the goal of the
project initially is just to implement a working 6502 on an FPGA board.

An important addition of Ricoh to the 6502 chip is the Audio Processing Unit
(APU). The 2A03 has 4 internal sound channels which are able to generate
semi-analog sound, and it has a sound channel capable of playing samples based
on the memory map or using the 7-bit unsigned Pulse Code Modulator (PCM)
directly.

Sound channels:

- 2 rectangle wave internal channels
- 1 triangle wave internal channel
- 1 random wavelength internal channel
- 1 external channel :cite:p:`2A03:ref`

.. toctree:: 
    :caption: 2A03 CPU
    :maxdepth: 1

    6502 CPU <core_6502>
    APU <apu>
