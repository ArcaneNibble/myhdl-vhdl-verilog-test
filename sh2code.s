.section .text
.global start

start:
    /* Print first hello */
    bsr print
     /* BUG?! */
     mov.l sh2_boot_msg_addr-8, r1

    /* Print first hello */
    bsr print
     /* BUG?! */
     mov.l sh2_done_msg_addr-4, r1
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


.align 4
debug_addr:
    .long 0xaaaa0000


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
