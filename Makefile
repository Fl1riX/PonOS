# === Переменные ===
BUILD_DIR := build
BOOT_DIR := boot
KERNEL_DIR := kernel
IMG := $(BUILD_DIR)/ponos.img
IMG_SIZE_MB := 20

# Цвета для вывода
GREEN := \033[0;32m
BLUE := \033[0;34m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# Компиляторы и инструменты
NASM := nasm
GCC := i686-elf-gcc
LD := i686-elf-ld
OBJCOPY := i686-elf-objcopy
QEMU := qemu-system-i386

# Флаги компиляции
NASM_FLAGS := -f elf32 -g
NASM_BIN_FLAGS := -f bin
GCC_FLAGS := -std=c99 -ffreestanding -fno-pie -m32 -g -Wall -Wextra -O0
LD_FLAGS := -m elf_i386 -T linker.ld

# Исходные файлы
MBR_SRC := $(BOOT_DIR)/mbr.asm
BOOTLOADER_SRC := $(BOOT_DIR)/bootloader.asm
ENTRY_SRC := $(KERNEL_DIR)/entry.asm
MAIN_SRC := $(KERNEL_DIR)/main.c

# Выходные файлы
MBR_BIN := $(BUILD_DIR)/boot/mbr.bin
BOOTLOADER_BIN := $(BUILD_DIR)/boot/boot.bin
ENTRY_OBJ := $(BUILD_DIR)/kernel/entry.o
MAIN_OBJ := $(BUILD_DIR)/kernel/main.o
KERNEL_ELF := $(BUILD_DIR)/kernel/kernel.elf
KERNEL_BIN := $(BUILD_DIR)/kernel/kernel.bin

# === Цели ===
.PHONY: all clean run run-debug run-nographic info dirs

all: dirs $(IMG)
	@echo "$(GREEN)✓ Сборка завершена успешно!$(NC)"
	@echo "$(BLUE)Образ диска: $(IMG)$(NC)"

# Создание директорий
dirs:
	@mkdir -p $(BUILD_DIR)/boot
	@mkdir -p $(BUILD_DIR)/kernel

# === Сборка MBR ===
$(MBR_BIN): $(MBR_SRC)
	@echo "$(BLUE)Сборка MBR...$(NC)"
	$(NASM) $(NASM_BIN_FLAGS) $< -o $@
	@echo "$(GREEN)✓ MBR собран$(NC)"

# === Сборка Bootloader ===
$(BOOTLOADER_BIN): $(BOOTLOADER_SRC) $(KERNEL_DIR)/constants.inc
	@echo "$(BLUE)Сборка загрузчика...$(NC)"
	$(NASM) $(NASM_BIN_FLAGS) -i $(KERNEL_DIR)/ $< -o $@
	@echo "$(GREEN)✓ Загрузчик собран$(NC)"

# === Сборка ядра ===

# Entry point (ассемблер)
$(ENTRY_OBJ): $(ENTRY_SRC) $(KERNEL_DIR)/constants.inc
	@echo "$(BLUE)Компиляция entry.asm...$(NC)"
	$(NASM) $(NASM_FLAGS) -i $(KERNEL_DIR)/ $< -o $@
	@echo "$(GREEN)✓ entry.o создан$(NC)"

# Основной код ядра (C)
$(MAIN_OBJ): $(MAIN_SRC)
	@echo "$(BLUE)Компиляция main.c...$(NC)"
	$(GCC) $(GCC_FLAGS) -c $< -o $@
	@echo "$(GREEN)✓ main.o создан$(NC)"

# Линковка ядра
$(KERNEL_ELF): $(ENTRY_OBJ) $(MAIN_OBJ) linker.ld
	@echo "$(BLUE)Линковка ядра...$(NC)"
	$(LD) $(LD_FLAGS) $(ENTRY_OBJ) $(MAIN_OBJ) -o $@
	@echo "$(GREEN)✓ kernel.elf создан$(NC)"

# Конвертация ELF в бинарный формат
$(KERNEL_BIN): $(KERNEL_ELF)
	@echo "$(BLUE)Создание kernel.bin...$(NC)"
	$(OBJCOPY) -O binary $< $@
	@ls -lh $@
	@echo "$(GREEN)✓ kernel.bin создан$(NC)"

# === Создание образа диска ===
$(IMG): $(MBR_BIN) $(BOOTLOADER_BIN) $(KERNEL_BIN)
	@echo "$(YELLOW)Создание образа диска...$(NC)"
	
	# Создаём пустой образ
	@dd if=/dev/zero of=$(IMG) bs=1M count=$(IMG_SIZE_MB) status=none
	
	# Записываем MBR (сектор 0)
	@dd if=$(MBR_BIN) of=$(IMG) bs=512 count=1 conv=notrunc status=none
	@echo "$(GREEN)  → MBR записан в сектор 0$(NC)"
	
	# Записываем загрузчик (сектора 1-2)
	@dd if=$(BOOTLOADER_BIN) of=$(IMG) bs=512 seek=1 conv=notrunc status=none
	@echo "$(GREEN)  → Загрузчик записан в сектора 1-2$(NC)"
	
	# Записываем ядро (начиная с сектора 3)
	@dd if=$(KERNEL_BIN) of=$(IMG) bs=512 seek=3 conv=notrunc status=none
	@echo "$(GREEN)  → Ядро записано начиная с сектора 3$(NC)"
	
	@echo "$(GREEN)✓ Образ диска создан$(NC)"

# === Запуск ===
run: $(IMG)
	@echo "$(YELLOW)Запуск QEMU...$(NC)"
	$(QEMU) -drive format=raw,file=$(IMG),index=0,if=floppy -m 128M

run-debug: $(IMG)
	@echo "$(YELLOW)Запуск QEMU в режиме отладки (GDB на порту 1234)...$(NC)"
	$(QEMU) -drive format=raw,file=$(IMG),index=0,if=floppy \
		-m 128M \
		-s -S

run-nographic: $(IMG)
	@echo "$(YELLOW)Запуск QEMU (без графики)...$(NC)"
	$(QEMU) -drive format=raw,file=$(IMG),index=0,if=floppy \
		-m 128M \
		-nographic

# === Информация ===
info: $(IMG)
	@echo "$(BLUE)=== Информация о сборке ===$(NC)"
	@echo "Размер MBR: $$(stat -f%z $(MBR_BIN) 2>/dev/null || stat -c%s $(MBR_BIN)) байт"
	@echo "Размер загрузчика: $$(stat -f%z $(BOOTLOADER_BIN) 2>/dev/null || stat -c%s $(BOOTLOADER_BIN)) байт"
	@echo "Размер ядра: $$(stat -f%z $(KERNEL_BIN) 2>/dev/null || stat -c%s $(KERNEL_BIN)) байт"
	@echo ""
	@echo "$(YELLOW)Карта секторов на диске:$(NC)"
	@echo "  Сектор 0:     MBR"
	@echo "  Сектора 1-2:  Загрузчик"
	@echo "  Сектор 3+:    Ядро"

# === Очистка ===
clean:
	@echo "$(RED)Очистка...$(NC)"
	@rm -rf $(BUILD_DIR)
	@echo "$(GREEN)✓ Очистка завершена$(NC)"

# === Помощь ===
help:
	@echo "$(BLUE)Доступные цели:$(NC)"
	@echo "  make           - Собрать всё"
	@echo "  make run       - Запустить в QEMU"
	@echo "  make run-debug - Запустить с GDB (порт 1234)"
	@echo "  make info      - Показать информацию о сборке"
	@echo "  make clean     - Удалить собранные файлы"
