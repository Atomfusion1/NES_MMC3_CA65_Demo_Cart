# NES_MMC3_CA65_Demo_Cart
Complete Build Environment CA65
Basic MMC3 Cartridge with Test Code
1. PRG Rom Bank switching 
2. IRQ Scan Line Trigger
3. CHR Sprite Changes 2x2k and 4x1k 

Special NOTE: 
1) The PPU address you set with $2006 is the same address the PPU uses to fetch tiles for rendering, so it holds the address of the next tile to draw... which is why changing $2006 during rendering will muck up the screen, even if you don't write anything to $2007. This also means that the address is constantly changing during rendering
2) Same with $2001 disable and enable, This will crash the screen graphics of anything more complex 

IE Dont use 2006 in IRQ with real graphics 

This is just an Entry level MMC3 Assembly code/setup to show you how to setup MMC3 triggers, this is used to create depth of field (Parallax)


I have Just Started my Rabbit Hole of Assembly and NES programming, The point of this code is not that its perfect and Fast for a production game but Cleaned up enough that another noob trying their hand can take it and just Start trying it out
