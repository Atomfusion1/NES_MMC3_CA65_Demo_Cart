; This code is for loading Graphics into 2x2kb and 4x1kb section 

;CHR map mode →	$8000.D7 = 0	$8000.D7 = 1
;PPU Bank	    Value of MMC3 register
;$0000-$03FF	    R0	        R2    R0 and R1 are 2K Banks 
;$0400-$07FF	    ^           R3          
;$0800-$0BFF	    R1	        R4
;$0C00-$0FFF	    ^           R5          
;$1000-$13FF	    R2	        R0   
;$1400-$17FF	    R3          ^ 
;$1800-$1BFF	    R4	        R1
;$1C00-$1FFF	    R5          ^

;;;;;;;;;;;;;;;;;;;;;;;;;;;   
;;;; BankSwitching Code MMC3
; Working  This Way Protects from Bus Conflicts
; All this code to load in CHR Bank 2 
LOADBANKS:
    LDX #$08            ; Start of Page to load Add 8 Hex per CHR .. CHR 3 = $10 or 16 
    LDA #$80            ; Starting Address for $8000 0,1,2,3,4,5,6 
    LDY #$00            ; Loop Counter 
    LoadPPU2k:          ; load two sets 2x2k to make first 4k (BACKGROUND)
        STA $8000       ; Bank Selection with Inversion 
        STX $8001       ; Selection of Bank 
        INY
        INX             ; Increase X x 2 as 2k 
        INX
        CLC
        ADC #$01
        CPY #$02        ; For loop 
        BNE LoadPPU2k
    LoadPPU1k:              ; load 4 * 1k sets to make FORGROUND 4k
        STA $8000           ; Bank Selection with Inversion 
        STX $8001           ; Selection of Bank 
        INY
        INX                 ; Increase X * x as 1k 
        CLC
        ADC #$01
        CPY #$06        ; For loop
        BNE LoadPPU1k
RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;  

;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOADSPRITES:
    BIT $2002       ; Clear address latch used for $2006
    LDA #$3F        ; Setup Background Color 1/2
    STA $2006       ; PPU Reg
    LDA #$00        ; Setup Background Color 2/2
    STA $2006       ; PPU Reg

    LDX #$00    
LoadPalettes:
    LDA PaletteData, X  ; Load Array of Palette Data 
    STA $2007           ; Save Pallet of X 
    INX
    CPX #$20            ; Load Array
    BNE LoadPalettes 

    LDX #$00
LoadSprites:
    LDA SpriteData, X   ; Load Sprite Array
    STA $0200, X
    INX
    CPX #$20            ; Load Array 
    BNE LoadSprites    


RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;