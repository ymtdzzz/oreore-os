; TAB=4

    BOTPAK	equ		0x00280000  ; bootpack load address
    DSKCAC	equ		0x00100000  ; disk cache address
    DSKCAC0	equ		0x00008000  ; disk cache address (real mode)

; BOOT_INFO
    CYLS    equ     0x0ff0
    LEDS    equ     0x0ff1
    VMODE   equ     0x0ff2
    SCRNX   equ     0x0ff4
    SCRNY   equ     0x0ff6
    VRAM    equ     0x0ff8

    ORG     0xc200

; Set video mode
    MOV     AL,0x13             ; VGA graphics, 320x200x8bit color
    MOV     AH,0x00
    INT     0x10
    MOV     BYTE [VMODE],8      ; save video mode
    MOV     WORD [SCRNX],320
    MOV     WORD [SCRNY],200
    MOV     DWORD [VRAM],0x000a0000

; keyboard LED status
    MOV     AH,0x02
    INT     0x16            ; call keyboard BIOS
    MOV     [LEDS],AL

; make PIC not to accept any interrupts
    MOV     AL,0xff
    OUT     0x21,AL
    NOP
    OUT     0xa1

    CLI

; set A20GATE to CPU access memory larger than 1MB
    CALL    waitkbdout
    MOV     AL,0xd1
    OUT     0x64,AL
    CALL    waitkbdout
    MOV     AL,0xdf         ; enable A20
    OUT     0x60,AL
    CALL    waitkbdout

; enable protect mode

[INSTRSET "i486p"]

    LGDT    [GDTR0]
    MOV     EAX,CR0
    AND     EAX,0x7fffffff  ; set bit31 0 to prohibit paging
    OR      EAX,0x00000001  ; set bit0 1 to enable protect mode
    MOV     CR0,EAX
    JMP     pipelineflush

pipelineflush:
    MOV     AX,1*8
    MOV     DS,AX
    MOV     ES,AX
    MOV     FS,AX
    MOV     GS,AX
    MOV     SS,AX

; transfer bootpack
    MOV     ESI,bootpack    ; from
    MOV     EDI,BOTPAK      ; to
    MOV     ECX,512*1024/4
    CALL    memcpy

; and transfer disk data to original address
; boot sector
    MOV     ESI,0x7c00      ; from
    MOV     EDI,DSKCAC      ; to
    MOV     ECX,512/4
    CALL    memcpy

; other part
    MOV     ESI,DSKCAC0+512 ; from
    MOV     EDI,DSKCAC+512  ; to
    MOV     ECX,0
    MOV     CL,BYTE [CYLS]
    IMUL    ECX,512*18*2/4
    SUB     ECX,512/4
    CALL    memcpy

; use bootpack
; launch bootpack
    MOV		EBX,BOTPAK
    MOV		ECX,[EBX+16]
    ADD		ECX,3			; ECX += 3;
    SHR		ECX,2			; ECX /= 4;
    JZ		skip			; no data to transfer
    MOV		ESI,[EBX+20]	; from
    ADD		ESI,EBX
    MOV		EDI,[EBX+12]	; to
    CALL	memcpy
skip:
    MOV		ESP,[EBX+12]	; default value of stack
    JMP		DWORD 2*8:0x0000001b

waitkbdout:
    IN		 AL,0x64
    AND		 AL,0x02
    JNZ		waitkbdout
    RET

memcpy:
    MOV		EAX,[ESI]
    ADD		ESI,4
    MOV		[EDI],EAX
    ADD		EDI,4
    SUB		ECX,1
    JNZ		memcpy
    RET

    ALIGNB	16
GDT0:
    RESB	8
    DW		0xffff,0x0000,0x9200,0x00cf
    DW		0xffff,0x0000,0x9a28,0x0047

    DW		0
GDTR0:
    DW		8*3-1
    DD		GDT0

    ALIGNB	16
bootpack: