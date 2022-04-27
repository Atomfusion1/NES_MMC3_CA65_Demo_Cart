;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Header Settings For Starter NES roms this is boiler plate 
; Compile with ca65
; .\cc65\bin\ca65 helloNES.asm -o helloNES.o --debug-info
; .\cc65\bin\ld65 helloNES.o -o helloNES.nes -t nes --dbgfile helloNES.dbg
; Basic NMOS 6502 http://www.6502.org/tutorials/6502opcodes.html
; Start Tutorial Warning they are in NESASM https://nerdy-nights.nes.science/
; https://github.com/ddribin/nerdy-nights
; https://github.com/JamesSheppardd/Nerdy-Nights-ca65-Translation

; Graphics Swapping to Come 

; Start NES Header
.segment "HEADER"
.include "Header.s"

; Setup ZeroPage Variables 
.segment "ZEROPAGE"
world:          .res 2  ; 16 Bit Value (High/Low Bits need to be inserted ) used to load sprites (pointer)

; Setup Interrupts (CPU Hardware Timers Essentially)
.segment "VECTORS"
    ; Non-maskable interrupt NMI (NTSC = 60 Times per Second)
    ; Connected to the PPU and detects vertical blanking 
    .addr NMI
    ; When the processor first turns on or is reset, it will jump to the label reset: Located at $FFFD
    ; If your nes.cfg file is off this is what breaks (Check Hex editor and Last line you should see 6 bytes )
    .addr RESET
    ; External interrupt IRQ (unused)
    .addr IRQ; MMC3 use etc. 

; Internal NES RAM
.segment "RAM"

; CAUTION !!  the Game does not know what bank is what, if you get this wrong your code will jump to another bank but may still work 
; I am actually using that for the color swap to work without changing the JSR routine 
; The compiler looks at all banks at the same time for Code (ie no naming the function the same)
; but the NES only sees the Banks that are assigned for Addressing
; Want more Banks Add them in nes.cfg in *2 and Header PRGROM 
; Swapable Bank 64k
.segment "BANK0"
COLOR1:         ; BankSelect = $00 ; Starting banks change this from 0 2 4 6 etc. to change starting color  
    BIT $2002   ; Clear address latch used for $2006
    LDA #$3F    ; Setup Background Color 1/2
    STA $2006   ; PPU Reg
    LDA #$00    ; Setup Background Color 2/2
    STA $2006   ; PPU Reg
    LDA #$25    ; Set Color Light Pink 
    STA $2007   ; PPU Reg 
RTS

; Swapable Bank 
.segment "BANK1"
COLOR1I:        ; BankSelect = $00 ; Starting banks change this from 0 2 4 6 etc. to change starting color  
    BIT $2002   ; Clear address latch used for $2006
    LDA #$3F    ; Setup Background Color 1/2
    STA $2006   ; PPU Reg
    LDA #$00    ; Setup Background Color 2/2
    STA $2006   ; PPU Reg
    LDA #$10    ; Set Color Grey
    STA $2007   ; PPU Reg 
RTS

; Swapable Bank 
.segment "BANK2"
COLOR2:         ; BankSelect = $00 ; Starting banks change this from 0 2 4 6 etc. to change starting color 
    BIT $2002   ; Clear address latch used for $2006
    LDA #$3F    ; Setup Background Color 1/2
    STA $2006   ; PPU Reg
    LDA #$00    ; Setup Background Color 2/2
    STA $2006   ; PPU Reg
    LDA #$21    ; Set Color Light Blue
    STA $2007   ; PPU Reg 
RTS

; Swapable Bank 
.segment "BANK3"
COLOR2I:        ; BankSelect = $00 ; Starting banks change this from 0 2 4 6 etc. to change starting color 
    BIT $2002   ; Clear address latch used for $2006
    LDA #$3F    ; Setup Background Color 1/2
    STA $2006   ; PPU Reg
    LDA #$00    ; Setup Background Color 2/2
    STA $2006   ; PPU Reg
    LDA #$1A    ; Set Color Green
    STA $2007   ; PPU Reg 
RTS

; Swapable Bank 
.segment "BANK4"
COLOR3:         ; BankSelect = $00 ; Starting banks change this from 0 2 4 6 etc. to change starting color 
    BIT $2002   ; Clear address latch used for $2006
    LDA #$3F    ; Setup Background Color 1/2
    STA $2006   ; PPU Reg
    LDA #$00    ; Setup Background Color 2/2
    STA $2006   ; PPU Reg
    LDA #$04    ; Set Color Purple
    STA $2007   ; PPU Reg 
RTS

; Swapable Bank 
.segment "BANK5"
COLOR3I:        ; BankSelect = $00 ; Starting banks change this from 0 2 4 6 etc. to change starting color 
    BIT $2002   ; Clear address latch used for $2006
    LDA #$3F    ; Setup Background Color 1/2
    STA $2006   ; PPU Reg
    LDA #$00    ; Setup Background Color 2/2
    STA $2006   ; PPU Reg
    LDA #$38    ; Set Color Light Green 
    STA $2007   ; PPU Reg 
RTS

; IMPORTANT NOTE MMC3 Must Start Reset and Setup PRG ROM at $E000, Its the only known fixed memory area 
; Start Memory at $E000
.segment "PAGE_FIXED"
    .include "Reset.s"  ; Basic Reset Call and Memory Setup

; This protects from entering into NMI before 
; Also you can do CPU Related things while the Screen is being Drawn as long as you end in a loop 
; before NMI triggers 
Loop:
    JMP Loop    


; This is where you do everything to control the game (PPU should go here)
; You can use a second loop to do CPU calulations while the screen is drawing IE collisions 
; But make sure its finished before the next VBlank Trigger 
;NMI Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NMI:  
    LDA #$02            ; Upload 256 bytes of data from CPU page XX00-XXFF to OAM 
    STA $4014           ; set the high byte (02) of the RAM address, start the transfer

; Just use Background in First 4k and Sprites in second 4k with 8x8 tiles 
    JSR LOADBANKS
    JSR LOADSPRITES

; On The Fly Bank Selection Code :
    LDX #$04
    LDY #$02
    JSR SELECTBANK      ; Must LDX and LDY with Bank # 
    JSR COLOR1          ; Jump to Color in Bank 

    LDA #%00011000      ; Show Background, Show Sprites 
    STA $2001           ; PPU Address Register

;; Keep this at NMI To keep the count Correct. (Counter is always running and some PPU writing can trigger it )
    LDA #$01            ; disable IRQ Cycle
    STA $E000
    LDA #$80            ; Set Value for Scanline Counter  
    STA $C000
    STA $C001           ; Resets Counter for new Line Count 
    LDA #$01            ; Enable IRQ 
    STA $E001
RTI ; Interrupt Return.. RTS for normal Returns 
; NMI FINISH ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; IRQ START ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
IRQ:
    ; IRQ Trigger location is dependent on Mirroring, Background to Sprite location in PPU
    ; This IRQ should Save DATA as it will Jump From your Code and you may need A,X,Y values 
    PHA             ; Push Variables to Stack from A,X,Y 
    TXA
    PHA
    TYA
    PHA

; Alignment Code (You can move the Start of the Scanline Code by adding and subtracting delay)
    LDX #$00 
:
    NOP                 ; Align when the follow code is applied (this stops mid line color change (flickering line))
    INX                 ; Use Mesen Event Viewer to see where the Resister Writes are and IRQ Trigger 
    CPX #$07            ; Count of NOP commands / Delay()
    BNE :-              ; Bind not Equal 

    LDA #$00            ; Disable PPU/ this lets you change colors of BG (IN IRQ
    STA $2001           ; PPU Address Register

; On The Fly Bank Selection Code :
;    LDX #$02
;    LDY #$01
;    JSR SELECTBANK      ; Must LDX and LDY with Bank # 

    JSR COLOR1I         ; Jump to A000 Color in Bank 

    LDA #%00011000      ; Show Background, Show Sprites 
    STA $2001           ; PPU Address Register

    LDA #$01            ; disable IRQ
    STA $E000

    PLA                 ; Pull Variables to Stack from Y,X, A
    TAY 
    PLA 
    TAX 
    PLA 
RTI ; 
; IRQ FINISH ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

; Area For Subroutines 
; Bank Changing Subroutine Both $8000 and $A000
; Load Bank Number X for $8000 and Y for $A000 
SELECTBANK:
    LDA #6              ; $8000 Selection Bank = 6 (NOTE: Not HEX) 
    STA $8000
    STX $8001           ; Select Bank LOW
    LDA #7              ; $A000 Selection Bank = 6 (NOTE: Not HEX) 
    STA $8000
    STY $8001           ; Select Bank HIGH
RTS    

PaletteData:
     .byte $22,$29,$1A,$0F,$22,$36,$17,$0f,$22,$30,$21,$0f,$22,$27,$17,$0F  ;background palette data
     .byte $22,$16,$27,$18,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17  ;sprite palette data


; Sprite Location Data In Binary 
    SpriteData:
;Man    Y pos, Tile, Sprite (1-4), X pos
    .byte $60, $00, $00, $78
    .byte $60, $01, $00, $80
    .byte $66, $02, $00, $78
    .byte $66, $03, $00, $80
    .byte $6E, $04, $00, $78
    .byte $6E, $05, $00, $80
    .byte $76, $06, $00, $78
    .byte $76, $07, $00, $80

; Background Data in binary file 32 x 30 grid of data 
; https://hexed.it/ Settings: Bytes per row 32, Show 0x00 bytes as space .. Welcome Background 
; ; NES Screen Tool https://forums.nesdev.org/viewtopic.php?t=15648
; Sprite Data Edit in yy-chr
; Swap in Bank 2 into graphics include
.include "MMC3Graphics.s"

.segment "CHR"
    .incbin "1kTestA.chr"      ; Im just using this for filler to show bank switching 
    .incbin "1kTestB.chr"      ; Im just using this for filler to show bank switching 
    .incbin "1kTestB.chr"      ; Im just using this for filler to show bank switching 
    .incbin "1kTestA.chr"      ; Im just using this for filler to show bank switching 
    .incbin "2kTestA.chr"      ; Im just using this for filler to show bank switching 
    .incbin "2kTestB.chr"      ; Im just using this for filler to show bank switching 
    .incbin "4kBack.chr"        ; background first 
    .incbin "4kSprites.chr"     ; sprites second





