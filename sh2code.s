.section .text
.global start

start:
    mov #0xF0, r1
    mov #0x55, r0
    mov.b r0, @r1
    mov #0xaa, r0
    bra start
    mov.b r0, @r1
