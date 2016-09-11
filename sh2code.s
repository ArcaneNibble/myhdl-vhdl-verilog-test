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
    .long illegal_fetch
    .long illegal_jump

start:
    mova nak_addr, r0
    mov.l @r0, r0

    nop
    nop
    nop
    nop
    nop

    /* bad inst */
    /*jmp @r0
     nop*/
    bra the_end
     nop

    /* bad data */
    /*mov.l @r0, r0
    mov #1, r1
    mov #2, r2*/

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

illegal_fetch:
    bsr print
     mova sh2_illegal_fetch_msg, r0
loop5:
    bra loop5
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
sh2_illegal_fetch_msg:
    .asciz "SH2 ILLEGAL IFETCH HAPPENED!"

.align 4
the_end:
    bra the_really_end
     nop 
the_really_end:
