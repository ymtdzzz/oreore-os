nasmhead.bin: nasmhead.asm
	nasm -o nasmhead.bin nasmhead.asm

os.sys: nasmhead.bin
	cat nasmhead.bin > os.sys

ipl.bin: ipl.asm
	nasm -o ipl.bin ipl.asm

os.img: ipl.bin os.sys
	mformat -f 1440 -C -B ipl.bin -i os.img ::
	mcopy -i os.img os.sys ::

run: os.img
	qemu-system-i386 -fda os.img

clean:
	rm -f *.bin
	rm -f *.o
	rm -f *.sys
	rm -f *.img