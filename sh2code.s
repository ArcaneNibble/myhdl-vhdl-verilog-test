.section .text
.global start

vectors:
    .long start
    .long 0

start:
    bsr dummysub
     mov.l testval1, r8

    bra jumphere1
     mov.l testval2, r9
jumpback1:

    bra jumphere2
     mova testval1, r0
jumpback2:


    bsr print_word
     mov r0, r1
    bsr print_word
     mov r8, r1
    bsr print_word
     mov r9, r1

loop:
    bra loop
     nop

dummysub:
    rts
     nop
jumphere1:
    bra jumpback1
     nop
jumphere2:
    bra jumpback2
     nop

testval1:
    .long 0xaabbccdd
testval2:
    .long 0xeeff9988


/* r0 = input */
test_avr:
    /* ugly */
    sts pr, r8
    mov r0, r9
    mov.l sharedmem_addr, r10
    mov.l avr_rst_addr, r11

    /* Print before */
    bsr print
     mova sh2_input_msg, r0

    bsr print_word
     mov r9, r1

    bsr print
     mova newline, r0

    /* Write shared word (flip endian) */
    swap.b r9, r9
    swap.w r9, r9
    swap.b r9, r9
    mov.l r9, @r10

    /* Turn AVR on */
    mov #0, r0
    mov.l r0, @r11

    /* Wait for AVR */
    mov.b @(8, r10), r0
waitavr:
    cmp/eq #0, r0
    bt/s waitavr
     mov.b @(8, r10), r0
    mov #0, r0
    mov.b r0, @(8, r10)

    /* Read shared word (flip endian) */
    mov.l @(4, r10), r9
    swap.b r9, r9
    swap.w r9, r9
    swap.b r9, r9

    /* Turn AVR off */
    mov #1, r0
    mov.l r0, @r11

    /* Print after */
    bsr print
     mova sh2_output_msg, r0

    bsr print_word
     mov r9, r1

    bsr print
     mova newline, r0

    lds r8, pr
    rts
     nop

/* r0 = str */
print:
    mov r0, r1
    mov.l debug_addr, r2
    mov.b @r1, r0
    cmp/eq #0, r0
    bt print_exit
    mov.b r0, @r2
    bra print
     add #1, r1
print_exit:
    rts
     nop

/* r1 = val */
print_word:
    mova hexlut, r0
    mov r0, r2
    mov.l debug_addr, r3

    swap.w r1, r0
    swap.b r0, r0
    shlr2 r0
    shlr2 r0
    and #0x0f, r0
    mov.b @(r0, r2), r4
    mov.b r4, @r3

    swap.w r1, r0
    swap.b r0, r0
    and #0x0f, r0
    mov.b @(r0, r2), r4
    mov.b r4, @r3

    swap.w r1, r0
    shlr2 r0
    shlr2 r0
    and #0x0f, r0
    mov.b @(r0, r2), r4
    mov.b r4, @r3

    swap.w r1, r0
    and #0x0f, r0
    mov.b @(r0, r2), r4
    mov.b r4, @r3

    swap.b r1, r0
    shlr2 r0
    shlr2 r0
    and #0x0f, r0
    mov.b @(r0, r2), r4
    mov.b r4, @r3

    swap.b r1, r0
    and #0x0f, r0
    mov.b @(r0, r2), r4
    mov.b r4, @r3

    mov r1, r0
    shlr2 r0
    shlr2 r0
    and #0x0f, r0
    mov.b @(r0, r2), r4
    mov.b r4, @r3

    mov r1, r0
    and #0x0f, r0
    mov.b @(r0, r2), r4
    rts
     mov.b r4, @r3

.align 4
debug_addr:
    .long 0xaaaa0000
avr_rst_addr:
    .long 0xaaaa0004
sharedmem_addr:
    .long 0xbbbb0000

.align 4
testvalues:
    .long 123
    .long 456
    .long 0x12345678
    .long 0xABCDEF00
    .long 0xDEADBEEF

.align 4
hexlut:
    .ascii "0123456789ABCDEF"

.align 4
sh2_boot_msg:
    .asciz "SH2 is booting!\n"

.align 4
sh2_done_msg:
    .asciz "SH2 is done!\n"

.align 4
sh2_input_msg:
    .asciz "TO AVR: "

.align 4
sh2_output_msg:
    .asciz "FROM AVR: "

.align 4
newline:
    .asciz "\n"
