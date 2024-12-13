
start:
    li 		a0, 0x0
    addi    a0, zero, 0x0
    addi    a0, zero, 0x0
    jal 	ra, subroutine
    li      a0, 0x0
    j       start
    ret

subroutine:
    addi 	a0, a0, 0x1
    addi 	a0, a0, 0x2
    addi 	a0, a0, 0x4
    addi 	a0, a0, 0x8
    addi 	a0, a0, 0x10
    addi 	a0, a0, 0x20
    addi 	a0, a0, 0x40
    addi 	a0, a0, 0x80
    addi    a0, zero, 0x0
    ret
