# 8088monitor

This is a simple monitor app for the 8088 processor on V20-MBC board. 

The app is uploaded using the iLoad (Intel-Hex Loader S200220) into the memory. 

Memory map for that app:
0x0000-0x03ff = interrupt vectors
0x0400-0x04ff = stack (256 bytes)
0x0500-0x0600 = variables for monitor app

Upon calling int 0x03, it displays the list of registers that are used. As for now the SS and the IP is not inside yet.

```
ax=1920 bx=1080 cx=1010 dx=FFFF
ds=0000 es=1002 di=5A5A si=A5A5
bp=0004 cs=0000
```

For more info on assembling and starting up the board, please visit: https://j4f.info/v20-mbc
