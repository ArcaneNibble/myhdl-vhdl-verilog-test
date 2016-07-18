.section .text

_start:
    ldi r16, 0xff
    out 0x3D, r16
    ldi r16, 0x00
    out 0x3E, r16

    ldi zl, lo8(avr_boot_msg)
    ldi zh, hi8(avr_boot_msg)
    rcall print

    ldi zl, lo8(avr_done_msg)
    ldi zh, hi8(avr_done_msg)
    rcall print
loop:
    rjmp loop

print:
    lpm
    or r0, r0
    breq print_exit
    out 0x00, r0
    adiw z, 1
    rjmp print
print_exit:
    ret

avr_boot_msg:
    .asciz "AVR is booting!\n"

avr_done_msg:
    .asciz "AVR is done!\n"
