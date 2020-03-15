; hello
; TAB=4

    ORG     0x7c00

; For FAT-12
    JMP     entry
    DB      0x90

    DB      "HELLOIPL"      ; Boot sector name
    DW      512             ; Size of each sector
    DB      1               ; Cluster size
    DW      1               ; Start sector of FAT
    DB      2               ; Number of FAT
    DW      224             ; Root dir size
    DW      2880            ; Drive size
    DB      0xf0            ; Media type
    DW      9               ; FAT area lentgh
    DW      18              ; Number of sector in single track
    DW      2               ; Number of head
    DD      0               ; Partition (no use)
    DD      2880            ; Drive size (again)
    DB      0,0,0x29
    DD      0xffffffff      ; Volume serial number
    DB      "HELLO-OS   "   ; Disk name (11 bytes)
    DB      "FAT12   "      ; Format name (8 bytes)
    RESB    18

; Main
entry:
    MOV     AX,0            ; Initialize register
    MOV     SS,AX
    MOV     SP,0x7c00
    MOV     DS,AX
    MOV     ES,AX

    MOV     SI,msg
putloop:
    MOV     AL,[SI]
    ADD     SI,1
    CMP     AL,0
    JE      fin
    MOV     AH,0x0e         ; Show 1 charactor
    MOV     BX,15           ; Color code
    INT     0x10            ; Call video BIOS
    JMP     putloop
fin:
    HLT                     ; Halt until something happens
    JMP     fin
msg:
    DB      0x0a, 0x0a      ; Break lines
    DB      "hello, world"
    DB      0x0a
    DB      0

    RESB    0x1fe-($-$$)    ; Fill 0x00 to 0x001fe

    DB      0x55, 0xaa

; Other than boot sector
    DB      0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    RESB    4600
    DB      0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    RESB    1469432
