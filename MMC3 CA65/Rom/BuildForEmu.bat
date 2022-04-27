timeout 1
del ".\Rom\hellones.nes"
del ".\Rom\hellones.o"
del ".\Rom\hellones.dbg"
timeout 1
.\cc65\bin\ca65 hellones.asm -o .\Rom\hellones.o --debug-info
.\cc65\bin\ld65 .\Rom\hellones.o -o .\Rom\hellones.nes -t nes --dbgfile .\Rom\hellones.dbg
timeout 3
.\Mesen\mesen.exe .\Rom\HelloNES.nes
timeout 1