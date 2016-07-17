.section .text
.global start

start:
    mov.l debug_addr, r1
    mov #0x55, r0
    mov.b r0, @r1
    mov #0xaa, r0
    bra start
    mov.b r0, @r1
debug_addr:
    .long 0xaaaa0000
