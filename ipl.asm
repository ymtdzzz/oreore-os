; hello
; TAB=4
    CYLS equ 10
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
; Load disk
    MOV     AX,0x0820
    MOV     ES,AX           ; Buffer address
    MOV     CH,0            ; Cylinder zero
    MOV     DH,0            ; Head zero
    MOV     CL,2            ; Sector two
readloop:
    MOV     SI,0            ; Failure count
retry:
    MOV     AH,0x02         ; load disk
    MOV     AL,1            ; sector one
    MOV     BX,0
    MOV     DL,0x00         ; A drive
    INT     0x13            ; call disk BIOS
    JNC     next
    ADD     SI,1            ; If error orrured, add 1 to failure count
    CMP     SI,5
    JAE     error
    MOV     AH,0x00
    MOV     DL,0x00
    INT     0x13            ; reset drive
    JMP     retry
next:
    MOV     AX,ES           ; move forward address by 0x200
    ADD     AX,0x0020
    MOV     ES,AX
    ADD     CL,1
    CMP     CL,18
    JBE     readloop
    MOV     CL,1
    ADD     DH,1
    CMP     DH,2
    JB      readloop        ; IF DH < 2
    MOV     DH,0
    ADD     CH,1
    CMP     CH,CYLS
    JB      readloop        ; IF CH < CYLS

    MOV     [0x0ff0],CH
    JMP     0xc200
error:
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
    HLT
    JMP		fin
msg:
    DB      0x0a, 0x0a      ; Break lines
    DB      "load error"
    DB      0x0a
    DB      0

    RESB    0x1fe-($-$$)    ; Fill 0x00 to 0x001fe

    DB      0x55, 0xaa