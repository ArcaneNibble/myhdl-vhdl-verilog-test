.section .text
.global start

vectors:
    .long start
    .long 0
    .long 0
    .long 0
    .long illegal_normal
    .long 0
    .long illegal_slot
    .long illegal_ifetch
    .long illegal_jump
    .long illegal_dfetch_notslot
    .long illegal_dfetch_slot

start:
    mova nak_addr, r0
    mov.l @r0, r0

    nop
    nop
    nop
    nop
    nop

    /* bad data */
    mov.l @r0, r0
    mov #1, r1
    mov #2, r2
    mov #3, r3
    mov #4, r4

loop:
    bra loop
     nop

illegal_normal:
    bsr print
     mova sh2_illegal_normal_msg, r0
loop2:
    bra loop2
     nop

illegal_slot:
    bsr print
     mova sh2_illegal_slot_msg, r0
loop3:
    bra loop3
     nop

illegal_jump:
    bsr print
     mova sh2_illegal_jump_msg, r0
loop4:
    bra loop4
     nop

illegal_ifetch:
    bsr print
     mova sh2_illegal_ifetch_msg, r0
loop5:
    bra loop5
     nop

illegal_dfetch_notslot:
    bsr print
     mova sh2_illegal_dfetch_notslot_msg, r0
loop6:
    bra loop6
     nop

illegal_dfetch_slot:
    bsr print
     mova sh2_illegal_dfetch_slot_msg, r0
loop7:
    bra loop7
     nop

/* r0 = str */
print:
    mov r0, r1
    mov.l debug_addr, r2
print_loop:
    mov.b @r1, r0
    cmp/eq #0, r0
    bt print_exit
    mov.b r0, @r2
    bra print_loop
     add #1, r1
print_exit:
    rts
     nop

.align 4
debug_addr:
    .long 0xaaaa0000
nak_addr:
    .long 0xcafe0000

.align 4
sh2_illegal_normal_msg:
    .asciz "SH2 ILLEGAL INSTRUCTION HAPPENED!"

.align 4
sh2_illegal_slot_msg:
    .asciz "SH2 ILLEGAL SLOT HAPPENED!"

.align 4
sh2_illegal_jump_msg:
    .asciz "SH2 ILLEGAL JUMP TARGET HAPPENED!"

.align 4
sh2_illegal_ifetch_msg:
    .asciz "SH2 ILLEGAL IFETCH HAPPENED!"

.align 4
sh2_illegal_dfetch_notslot_msg:
    .asciz "SH2 ILLEGAL DFETCH (NOT SLOT) HAPPENED!"

.align 4
sh2_illegal_dfetch_slot_msg:
    .asciz "SH2 ILLEGAL DFETCH (SLOT) HAPPENED!"
