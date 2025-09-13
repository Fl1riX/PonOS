#!/bin/bash
set -e

# === Параметры ===
BUILD_DIR="build"
IMG="$BUILD_DIR/ponos.img"
IMG_SIZE_MB=20

mkdir -p "$BUILD_DIR"

echo "=== Сборка бинарников ==="
nasm -f bin mbr_bootloader.asm -o "$BUILD_DIR/mbr.bin"
nasm -f bin boot.asm         -o "$BUILD_DIR/boot.bin"
nasm -f bin kernel.asm       -o "$BUILD_DIR/kernel.bin"

echo "=== Создание пустого HDD-образа ($IMG_SIZE_MB MB) ==="
dd if=/dev/zero of="$IMG" bs=1M count=$IMG_SIZE_MB

echo "=== Запись MBR, boot и kernel в образ ==="
dd if="$BUILD_DIR/mbr.bin"    of="$IMG" conv=notrunc
dd if="$BUILD_DIR/boot.bin"   of="$IMG" bs=512 seek=1 conv=notrunc
dd if="$BUILD_DIR/kernel.bin" of="$IMG" bs=512 seek=3 conv=notrunc

# === Определяем режим запуска ===
RUN_MODE="$1"   # передаем "debug" для отладки

if [ "$RUN_MODE" = "debug" ]; then
    echo "=== Запуск QEMU с GDB-сервером ==="
    qemu-system-i386 \
        -drive file="$IMG",format=raw,if=ide \
        -boot c \
        -s -S     
else
    echo "=== Обычный запуск QEMU ==="
    qemu-system-i386 \
        -drive file="$IMG",format=raw,if=ide \
        -boot c
fi

echo "=== Готово ==="
