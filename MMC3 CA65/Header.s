;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Header Settings For Starter NES roms 
; this is boiler plate Setup 

;; This MUST Match with the memory Map if you want it to work 


NES_MAPPER = 04                       ; 0 = NROM
; I have the Code in the HelloNES.asm Blocked off if you enable it you can switch between the 8k CHR chunks
NES_MIRROR = 1                         ; 0 = horizontal mirroring, 1 = vertical mirroring
NES_SRAM   = 0                         ; 1 = battery backed SRAM at $6000-7FFF

.byte 'N', 'E', 'S', $1A                ; ID
.byte $04                               ; 16k PRG ROM count (NOT 8K)
.byte $0F                               ;  x 8k CHR chunk count
.byte NES_MIRROR | (NES_SRAM << 1) | ((NES_MAPPER & $f) << 4)
.byte (NES_MAPPER & %11110000)
.byte $0, $0, $0, $0, $0, $0, $0, $0    ; padding