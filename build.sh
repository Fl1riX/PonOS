#!/bin/bash
set -e

# === Параметры ===
BUILD_DIR="build"
BOOT_DIR="boot"
KERNEL_DIR="kernel"
APPS_DIR="apps"

IMG="$BUILD_DIR/ponos.img"
IMG_SIZE_MB=20

# === Цвета для вывода ===
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# === Создание структуры директорий ===
echo -e "${BLUE}=== Создание директорий ===${NC}"
mkdir -p "$BUILD_DIR"
mkdir -p "$BUILD_DIR/boot"
mkdir -p "$BUILD_DIR/kernel"
mkdir -p "$BUILD_DIR/apps"

# === Проверка наличия исходных файлов ===
echo -e "${BLUE}=== Проверка исходных файлов ===${NC}"

if [ ! -f "$BOOT_DIR/mbr.asm" ]; then
    echo -e "${YELLOW}Предупреждение: $BOOT_DIR/mbr.asm не найден${NC}"
fi

if [ ! -f "$BOOT_DIR/bootloader.asm" ]; then
    echo -e "${YELLOW}Предупреждение: $BOOT_DIR/bootloader.asm не найден${NC}"
fi

if [ ! -f "$KERNEL_DIR/kernel.asm" ]; then
    echo -e "${YELLOW}Предупреждение: $KERNEL_DIR/kernel.asm не найден${NC}"
fi

# === Сборка загрузчиков ===
echo -e "${BLUE}=== Сборка загрузчиков ===${NC}"

if [ -f "$BOOT_DIR/mbr.asm" ]; then
    echo "Компиляция MBR..."
    nasm -f bin "$BOOT_DIR/mbr.asm" -o "$BUILD_DIR/boot/mbr.bin"
    echo -e "${GREEN}✓ MBR скомпилирован${NC}"
else
    echo "Используется mbr_bootloader.asm (старое имя)..."
    nasm -f bin mbr_bootloader.asm -o "$BUILD_DIR/boot/mbr.bin"
fi

if [ -f "$BOOT_DIR/bootloader.asm" ]; then
    echo "Компиляция Stage 2 загрузчика..."
    nasm -f bin "$BOOT_DIR/bootloader.asm" -o "$BUILD_DIR/boot/boot.bin"
    echo -e "${GREEN}✓ Stage 2 загрузчик скомпилирован${NC}"
else
    echo "Используется boot.asm (старое имя)..."
    nasm -f bin boot.asm -o "$BUILD_DIR/boot/boot.bin"
fi

# === Сборка ядра ===
echo -e "${BLUE}=== Сборка ядра ===${NC}"

if [ -f "$KERNEL_DIR/kernel.asm" ]; then
    echo "Компиляция ядра..."
    nasm -f bin -i kernel/ -i apps/ "$KERNEL_DIR/kernel.asm" -o "$BUILD_DIR/kernel/kernel.bin"
    echo -e "${GREEN}✓ Ядро скомпилировано${NC}"
else
    echo "Используется kernel.asm (старое расположение)..."
    nasm -f bin kernel.asm -o "$BUILD_DIR/kernel/kernel.bin"
fi

# === Проверка размеров ===
echo -e "${BLUE}=== Проверка размеров бинарников ===${NC}"

MBR_SIZE=$(stat -f%z "$BUILD_DIR/boot/mbr.bin" 2>/dev/null || stat -c%s "$BUILD_DIR/boot/mbr.bin" 2>/dev/null)
BOOT_SIZE=$(stat -f%z "$BUILD_DIR/boot/boot.bin" 2>/dev/null || stat -c%s "$BUILD_DIR/boot/boot.bin" 2>/dev/null)
KERNEL_SIZE=$(stat -f%z "$BUILD_DIR/kernel/kernel.bin" 2>/dev/null || stat -c%s "$BUILD_DIR/kernel/kernel.bin" 2>/dev/null)

echo "MBR:        $MBR_SIZE байт (должен быть 512)"
echo "Boot:       $BOOT_SIZE байт (должен быть 1024)"
echo "Kernel:     $KERNEL_SIZE байт"

if [ "$MBR_SIZE" -ne 512 ]; then
    echo -e "${YELLOW}⚠ Предупреждение: размер MBR не равен 512 байт!${NC}"
fi

# === Создание образа диска ===
echo -e "${BLUE}=== Создание образа диска ($IMG_SIZE_MB MB) ===${NC}"
dd if=/dev/zero of="$IMG" bs=1M count=$IMG_SIZE_MB status=progress 2>/dev/null || \
dd if=/dev/zero of="$IMG" bs=1M count=$IMG_SIZE_MB

echo -e "${GREEN}✓ Образ диска создан${NC}"

# === Запись компонентов в образ ===
echo -e "${BLUE}=== Запись компонентов в образ ===${NC}"

echo "Запись MBR (сектор 0)..."
dd if="$BUILD_DIR/boot/mbr.bin" of="$IMG" conv=notrunc status=none
echo -e "${GREEN}✓ MBR записан${NC}"

echo "Запись Stage 2 загрузчика (сектора 1-2)..."
dd if="$BUILD_DIR/boot/boot.bin" of="$IMG" bs=512 seek=1 conv=notrunc status=none
echo -e "${GREEN}✓ Загрузчик записан${NC}"

echo "Запись ядра (сектор 3+)..."
dd if="$BUILD_DIR/kernel/kernel.bin" of="$IMG" bs=512 seek=3 conv=notrunc status=none
echo -e "${GREEN}✓ Ядро записано${NC}"

# === Информация о сборке ===
echo -e "${BLUE}=== Информация о сборке ===${NC}"
echo "Образ:      $IMG"
echo "Размер:     $IMG_SIZE_MB MB"
echo "Дата:       $(date)"
echo ""

# === Определяем режим запуска ===
RUN_MODE="$1"

if [ "$RUN_MODE" = "debug" ]; then
    echo -e "${BLUE}=== Запуск QEMU в режиме отладки ===${NC}"
    echo "GDB-сервер будет запущен на :1234"
    echo "Подключение: gdb -ex 'target remote localhost:1234' -ex 'set architecture i8086'"
    echo ""
    qemu-system-i386 \
        -drive file="$IMG",format=raw,if=ide \
        -boot c \
        -s -S
elif [ "$RUN_MODE" = "nographic" ]; then
    echo -e "${BLUE}=== Запуск QEMU без графики ===${NC}"
    qemu-system-i386 \
        -drive file="$IMG",format=raw,if=ide \
        -boot c \
        -nographic
elif [ "$RUN_MODE" = "test" ]; then
    echo -e "${BLUE}=== Только сборка (без запуска) ===${NC}"
    echo -e "${GREEN}✓ Сборка завершена успешно${NC}"
elif [ "$RUN_MODE" = "bochs" ]; then
    echo -e "${BLUE}=== Запуск Bochs ===${NC}"
    if command -v bochs &> /dev/null; then
        bochs -f bochsrc.txt -q
    else
        echo -e "${YELLOW}⚠ Bochs не найден${NC}"
    fi
else
    echo -e "${BLUE}=== Запуск QEMU ===${NC}"
    echo "Используйте Ctrl+Alt+G для выхода из захвата мыши"
    echo "Используйте Ctrl+Alt+2 для монитора QEMU"
    echo ""
    qemu-system-i386 \
        -drive file="$IMG",format=raw,if=ide \
        -boot c
fi

echo -e "${GREEN}=== Готово ===${NC}"