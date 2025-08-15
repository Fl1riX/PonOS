#!/bin/bash
set -e

# === Параметры образа ===
echo "Setting image parameters..."
IMG=ponos.img
IMG_SIZE_MB=20

# === Сборка ===
echo "Building..."
mkdir -p build

nasm -f bin mbr_bootloader.asm -o build/mbr.bin
nasm -f bin boot.asm         -o build/boot.bin
nasm -f bin kernel.asm       -o build/kernel.bin

# === Создаём пустой HDD-образ ===
echo "Creating an empty HDD image..."
dd if=/dev/zero of=build/$IMG bs=1M count=$IMG_SIZE_MB

# === Записываем загрузчик и прочее ===
echo "Writing the bootloader and other things..."
dd if=build/mbr.bin    of=build/$IMG conv=notrunc
dd if=build/boot.bin   of=build/$IMG bs=512 seek=1 conv=notrunc
dd if=build/kernel.bin of=build/$IMG bs=512 seek=3 conv=notrunc

# === Запуск QEMU в режиме HDD с LBA ===
echo "Running QEMU..."
qemu-system-i386 \
    -drive file=build/$IMG,format=raw,if=ide \
    -boot c \
    -monitor stdio\
    -bios bios-256k.bin
