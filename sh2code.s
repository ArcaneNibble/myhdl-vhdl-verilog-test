.section .text
.global start

start:
    /* Print first hello */
    mov.l sh2_boot_msg_addr, r1
    bsr print
     nop

    /* Test AVR */
    mov.l testvalues_addr, r12
    bsr test_avr
     mov.l @(0, r12), r0
    bsr test_avr
     mov.l @(4, r12), r0
    bsr test_avr
     mov.l @(8, r12), r0
    bsr test_avr
     mov.l @(12, r12), r0
    bsr test_avr
     mov.l @(16, r12), r0

    /* Print last hello */
    mov.l sh2_done_msg_addr, r1
    bsr print
     nop
loop:
    bra loop
     nop

/* r0 = input */
test_avr:
    /* ugly */
    sts pr, r8
    mov r0, r9
    mov.l sharedmem_addr, r10
    mov.l avr_rst_addr, r11

    /* Print before */
    mov.l sh2_input_msg_addr, r1
    bsr print
     nop

    bsr print_word
     mov r9, r1

    mov.l newline_addr, r1
    bsr print
     nop

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
    mov.l sh2_output_msg_addr, r1
    bsr print
     nop

    bsr print_word
     mov r9, r1

    mov.l newline_addr, r1
    bsr print
     nop

    lds r8, pr
    rts
     nop

/* r1 = str */
print:
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
    mov.l hexlut_addr, r2
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
testvalues_addr:
    .long testvalues
testvalues:
    .long 123
    .long 456
    .long 0x12345678
    .long 0xABCDEF00
    .long 0xDEADBEEF

.align 4
hexlut_addr:
    .long hexlut
hexlut:
    .ascii "0123456789ABCDEF"

.align 4
sh2_boot_msg_addr:
    .long sh2_boot_msg
sh2_boot_msg:
    .asciz "SH2 is booting!\n"

.align 4
sh2_done_msg_addr:
    .long sh2_done_msg
sh2_done_msg:
    .asciz "SH2 is done!\n"

.align 4
sh2_input_msg_addr:
    .long sh2_input_msg
sh2_input_msg:
    .asciz "TO AVR: "

.align 4
sh2_output_msg_addr:
    .long sh2_output_msg
sh2_output_msg:
    .asciz "FROM AVR: "

.align 4
newline_addr:
    .long newline
newline:
    .asciz "\n"
