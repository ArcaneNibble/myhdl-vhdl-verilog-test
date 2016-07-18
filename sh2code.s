.section .text
.global start

start:
    /* Print first hello */
    mov.l sh2_boot_msg_addr, r1
    bsr print
     nop

    /* Turn AVR on */
    mov.l avr_rst_addr, r1
    mov #0, r0
    mov.l r0, @r1

    bsr print_word
     nop

    /* Print first hello */
    mov.l sh2_done_msg_addr, r1
    bsr print
     nop
loop:
    bra loop
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
