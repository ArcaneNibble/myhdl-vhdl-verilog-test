.section .text

_start:
    /* Set up stack */
    ldi r16, 0xff
    out 0x3D, r16
    ldi r16, 0x00
    out 0x3E, r16

    /* Print first hello */
    ldi zl, lo8(avr_boot_msg)
    ldi zh, hi8(avr_boot_msg)
    rcall print

    /* Read the 4 bytes at data address 0 */
    ldi xl, 0x00
    ldi xh, 0x00
    ld r0, x+
    ld r1, x+
    ld r2, x+
    ld r3, x+

    /* Add 123 to the value */
    ldi r16, 123
    ldi r17, 0
    add r0, r16
    adc r1, r17
    adc r2, r17
    adc r3, r17

    /* Store it at address 4 */
    st x+, r0
    st x+, r1
    st x+, r2
    st x+, r3

    /* Store a done flag at address 5 */
    ldi r16, 1
    st x+, r16

    /* Print last hello */
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
