; Basic Memory Reset
RESET:              
    SEI             ; disable IRQs
    CLD		        ; disable decimal mode NES does not have 6052 Decimal 
    LDX #$40
    STX $4017	    ; disable APU frame IRQ IMPORTANT ON MMC3
    LDX #$ff 	    ; Set up Stack Pointer Value
    TXS		        ;  Transfer X to Stack Pointer
    LDX #%00001000	; X = 0
    STX $2000	    ; disable NMI
    LDX #$00		; X = 0
    STX $2001 	    ; disable rendering
    STX $4010 	    ; disable DMC IRQs
    STX $E000       ; disable MMC3 IRQ 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MMC3 Setup Must be done in RESET at $E000  
;Setup MMC3 Registers 
    mmc3_register_init:
    .byte $00 ,$02 ,$04 ,$05 , $06,$07 ,$00 ,$01

; Initialize All Registers of MMC3
initMMC3:
    LDX #$00
	LDA #$00
	STA $E000       ; IRQ disable
	STA $A000       ; mirroring 0 Vertical; 1 Horizontal  
:
	STX $8000       ; select register
	LDA mmc3_register_init, X
	STA $8001       ; initialize register
	INX
	CPX #8          ; Compare 8 to X 
	BCC :-          ; Branch not Equal 

;PRG ROM Selections

    LDY #00             ; Starting Banks Change This from 0 2 4 6 ETC to change Starting Color Startup $00
    LDA #6              ; $8000 Selection Bank = 6 (NOTE: Not HEX) 
    STA $8000
    STY $8001           ; Select Bank LOW
    LDA #7              ; $A000 Selection Bank = 6 (NOTE: Not HEX) 
    STA $8000
    INY
    STY $8001           ; Select Bank HIGH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MMC3 Setup Done 


vblankwait1:
    BIT $2002           ; Who knows were Screen is so lets wait for VBlank
    BPL vblankwait1

    LDX #$00                ; Load Registry X with $00 Hex 
clear_memory:
    LDA #$00                ; Load Registry A with $00 Hex  
    STA $0000, X            ; Store Registry Values
    STA $0100, X
    STA $0300, X
    STA $0400, X
    STA $0500, X
    STA $0600, X
    STA $0700, X
    LDA #$FC                ; Set Sprites to FC 
    STA $0200, X            ; $0200 => $02FF
    INX                     ; Add 1 to X 
    CPX #$00
    BNE clear_memory

; Second Wait for Vblank, PPU is ready after this
vblankwait2:
    BIT $2002
    BPL vblankwait2

    LDA #$00
    STA $2003       ; Set the low byte (00) of the OAM address


; Important Notes 
; When using 8x8 sprites, if the BG uses $0000, and the sprites use $1000, 
; the IRQ counter should decrement on PPU cycle 260, right after the visible part of the target scanline has ended.
; See IRQ Specifics section https://www.nesdev.org/wiki/MMC3

; Just use Background in First 4k and Sprites in second 4k with 8x8 tiles 

    ; Enable interrupts 
;   VPHB SINN = 
;   *  | |       Generate NMI at start of VBI = 1
;      * |       Background 0 = $0000 .. 1rst 4K chunk 
;        *       Sprites 1 = $1000 .. 2nd 4K chunk 
    JSR LOADBANKS
    
    LDA #%10001000      ; enable NMI change background to use second chr set of tiles ($1000)
    STA $2000
    ; Enabling sprites and background for left-most 8 pixels
    LDA #%00011000      ; Show Background, Show Sprites 
    STA $2001           ;PPU Address Register
    
    CLI         ; Turn on Interrupts 


