#!/bin/bash
mkdir -p build
nasm -f bin boot.asm -o build/boot.bin
echo "Bootloader assembled!"
nasm -f bin kernel.asm -o build/kernel.bin
echo "Kernel assembled!"
cat build/boot.bin build/kernel.bin > build/ponos.img
echo "Disk image collected!"
echo "Launching OS..."
qemu-system-i386 -fda build/ponos.img

