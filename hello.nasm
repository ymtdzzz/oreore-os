; hello
; TAB=4

; For FAT-12
    DB      0xeb, 0x4e, 0x90
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
    DB      0xb8, 0x00, 0x00, 0x8e, 0xd0, 0xbc, 0x00, 0x7c
    DB      0x8e, 0xd8, 0x8e, 0xc0, 0xbe, 0x74, 0x7c, 0x8a
    DB      0x04, 0x83, 0xc6, 0x01, 0x3c, 0x00, 0x74, 0x09
    DB      0xb4, 0x0e, 0xbb, 0x0f, 0x00, 0xcd, 0x10, 0xeb
    DB      0xee, 0xf4, 0xeb, 0xfd

; Message
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
