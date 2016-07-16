.section .text

_start:
    ldi r16, 0x55
    out 0x00, r16
    ldi r16, 0xaa
    out 0x00, r16
    rjmp _start
