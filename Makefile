ipl.bin: ipl.asm
	nasm -o ipl.bin ipl.asm

os.img: ipl.bin
	mformat -f 1440 -C -B ipl.bin -i os.img

run: os.img
	qemu-system-i386 -fda os.img

clean:
	rm -f *.bin
	rm -f *.o
	rm -f *.sys
	rm -f *.img