; TAB=4

; BOOT_INFO
    CYLS    equ     0x0ff0
    LEDS    equ     0x0ff1
    VMODE   equ     0x0ff2
    SCRNX   equ     0x0ff4
    SCRNY   equ     0x0ff6
    VRAM    equ     0x0ff8

    ORG     0xc200

    MOV     AL,0x13         ; VGA graphics, 320x200x8bit color
    MOV     AH,0x00
    INT     0x10
    MOV     BYTE [VMODE],8  ; save video mode
    MOV     WORD [SCRNX],320
    MOV     WORD [SCRNY],200
    MOV     DWORD [VRAM],0x000a0000

; keyboard LED status
    MOV     AH,0x02
    INT     0x16            ; call keyboard BIOS
    MOV     [LEDS],AL

fin:
    HLT
    JMP     fin