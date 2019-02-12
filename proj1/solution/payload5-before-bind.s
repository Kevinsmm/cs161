// get current addr
call foo
foo:
pop %eax

// 40 + 4+4+4+4+4+4+4 - 5
add $63, %eax
jmp *%eax

_next_section:
nop
nop
nop
nop
nop

