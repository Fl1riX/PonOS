# 🖥️ PonOS – Минимальная операционная система для x86-32

> Образовательный проект ОС с нуля на ассемблере и C для глубокого понимания архитектуры x86

---
[![Status](https://img.shields.io/badge/status-in_development-yellow?style=for-the-badge)](https://github.com/Fl1riX/PonOS)
[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)
[![Architecture](https://img.shields.io/badge/architecture-x86-lightgrey?style=for-the-badge)](https://github.com/Fl1riX/PonOS)
[![Language](https://img.shields.io/badge/language-Assembly-red?style=for-the-badge)]
[![Language](https://img.shields.io/badge/language-C-blue?style=for-the-badge)](https://github.com/Fl1riX/PonOS)
[![Version](https://img.shields.io/badge/version-0.0.5.2-green?style=for-the-badge)](https://github.com/Fl1riX/PonOS)
---

## 📖 Описание проекта

**PonOS** (Proof of Concept OS) – это минималистичная операционная система, разработанная полностью с нуля для архитектуры i386 (32-bit x86). Проект демонстрирует фундаментальные концепции разработки ОС: загрузку системы, переход из реального режима в защищённый режим, управление памятью через сегментацию и инициализацию ядра.

### 🎯 Образовательные цели

Проект охватывает изучение:

- **🔧 Процесс загрузки** – MBR, bootloader, загрузка ядра с диска
- **🔄 Переход режимов** – из Real Mode (16-bit) в Protected Mode (32-bit)
- **💾 Управление памятью** – GDT, сегментация, подготовка к пейджингу
- **⚙️ Низкоуровневое программирование** – прямое взаимодействие с оборудованием
- **🛠️ Инструменты разработки** – кроссплатформенная компиляция (NASM, i686-elf-gcc, linker scripts)

---

## 🏗️ Архитектура загрузки

Система использует классическую трёхстадийную схему загрузки:

```
╔═════════════════════════════════════════════════════╗
║ ЭТАП 1️⃣  – MBR (Master Boot Record)                 ║
║ • Адрес: Сектор 0 (0x0000:0x7C00) – 512 байт        ║
║ • Функция: Чтение bootloader'а в память (0x8000)    ║
║ • Проверка сигнатуры диска (0xAA55)                 ║
║ • Передача управления bootloader'у                  ║
╚═════════════════════╤═══════════════════════════════╝
                      ↓
╔═════════════════════════════════════════════════════╗
║ ЭТАП 2️⃣  – Bootloader (вторая стадия загрузки       ║
║ • Адрес: Сектора 1–2 (0x8000) – 1024 байта          ║
║ • Инициализация дискового контроллера (LBA/CHS)     ║
║ • Загрузка ядра с диска (сектора 3+)                ║
║ • Активация A20 gate (доступ выше 1 МБ)             ║
║ • Загрузка таблицы дескрипторов (GDT)               ║
║ • Включение защищённого режима (Protected Mode)     ║
║ • Прыжок на ядро (0x1000)                           ║
╚═════════════════════╤═══════════════════════════════╝
                      ↓
╔═════════════════════════════════════════════════════╗
║ ЭТАП 3️⃣  – Ядро ОС (Kernel)                         ║
║ • Адрес: Сектор 3+ (0x1000 в Protected Mode)        ║
║ • Точка входа (32-bit ассемблер)                    ║
║ • Инициализация сегментов памяти и стека            ║
║ • Вызов main() – основной код ядра                  ║
║ • Начало работы операционной системы                ║
╚═════════════════════════════════════════════════════╝
```

---

## 📁 Структура проекта

```
PonOS/
│
├── 📂 boot/                      # Этапы загрузки (MBR + Bootloader)
│   ├── mbr.asm                   # ▶ Первая стадия загрузки (512 байт)
│   ├── bootloader.asm            # ▶ Вторая стадия загрузки (1024 байта)
│
├── 📂 kernel/                    # Ядро операционной системы
│   ├── entry.asm                 # ▶ Точка входа ядра (32-bit)
│   └── main.c                    # ▶ Основной код ядра на C
│
├── 📂 apps/                      # Примеры приложений (будущее расширение)
│   └── calculator.asm            # Заготовка приложения
│
├── 📂 build/                     # 🔨 Артефакты сборки (авто-генерируется)
│   ├── boot/
│   ├── kernel/
│   └── ponos.img                 # 💿 Финальный образ диска
│
├── 📂 screenshots/               # 📸 Скриншоты документации
│   ├── help.png
│   └── menu.png
│
├── Makefile                      # ⚙️ Скрипт сборки и запуска
├── linker.ld                     # 🔗 Linker script для ядра
├── CHANGELOG.md                  # 📝 История версий
├── LICENSE                       # 📜 MIT License
└── README.md                     # 📖 Этот файл
```

---

## 🛠️ Требования и установка

### 📋 Необходимые инструменты

| Инструмент | Назначение | Установка |
|:---:|:---|:---|
| **NASM** | Ассемблер x86 | `pacman -S nasm` |
| **GCC (i686-elf)** | C компилятор | `pacman -S i686-elf-gcc` |
| **Binutils** | Линкер и утилиты | `pacman -S i686-elf-binutils` |
| **Make** | Автоматизация сборки | `pacman -S make` |
| **QEMU** | Эмулятор системы | `pacman -S qemu-system-x86` |

### ⚡ Быстрая установка

**🐧 Arch Linux:**
```bash
sudo pacman -S nasm i686-elf-{gcc,binutils} make qemu-system-x86
```

**🐧 Ubuntu / Debian:**
```bash
sudo apt-get install nasm gcc-i686-linux-gnu binutils-i686-linux-gnu make qemu-system-x86
```

**🍎 macOS (Homebrew):**
```bash
brew install nasm i686-elf-gcc make qemu
```

---

## 🔨 Сборка проекта

### ✅ Полная сборка

```bash
make clean      # Очистить предыдущую сборку
make            # Собрать весь проект
```

**Генерируемые файлы:**
- `build/boot/mbr.bin` – MBR (512 байт)
- `build/boot/boot.bin` – Bootloader (1024 байта)
- `build/kernel/kernel.bin` – Ядро ОС
- `build/ponos.img` – **Готовый образ диска** (20 МБ)


## 🔨 Быстрая справка команд

```bash
make              # 🔨 Собрать проект
make run          # ▶️ Запустить в QEMU
make run-debug    # 🔍 Запустить с GDB на порту 1234
make run-nographic # 🖥️ Запустить без графики
make info         # 📊 Показать информацию о сборке
make clean        # 🗑️ Очистить артефакты
make help         # ❓ Справка по доступным командам
```

### 🔍 Отладка через GDB

**Терминал 1** – запуск эмулятора:
```bash
make run-debug
```

**Терминал 2** – подключение отладчика:
```bash
i686-elf-gdb
(gdb) target remote localhost:1234
(gdb) symbol-file build/kernel/kernel.elf
(gdb) break *0x1000
(gdb) continue
```

### 🖥️ Запуск без графики

```bash
make run-nographic
```
Полезно для удалённых серверов без X11.

### ❓ Справка

```bash
make help
```

---

## 🐛 Отладка и анализ

### 🔎 Просмотр Bootloader'а

```bash
hexdump -C build/boot/boot.bin | head -20
```

### 📖 Дизассемблирование ядра

```bash
i686-elf-objdump -d build/kernel/kernel.elf | head -50
```

### 📊 Карта символов

```bash
i686-elf-nm build/kernel/kernel.elf | sort
```

### 📝 Листинг ассемблера NASM

```bash
nasm -f bin boot/bootloader.asm -l build/boot/bootloader.lst
```

---

## 📚 Документация и ссылки

| Тема | Ресурс |
|:---|:---|
| 🌐 Разработка ОС | [OSDev.org Wiki](https://wiki.osdev.org/) |
| 🔧 x86 Архитектура | [Intel 80386 Manual](https://www.intel.com) |
| 🏗️ NASM Ассемблер | [NASM Manual](https://www.nasm.us/doc/) |
| 🔗 GNU Linker | [GNU LD Docs](https://sourceware.org/binutils/docs/ld/) |
| 📖 GDB Отладчик | [GDB Manual](https://sourceware.org/gdb/current/onlinedocs/gdb/) |

---

## 📜 Лицензия и информация

| Параметр | Значение |
|:---|:---|
| **Лицензия** | MIT – свободно использовать в образовательных целях |
| **Версия** | 0.0.5.2 |
| **Статус** | 🚀 Активная разработка |
| **Обновлено** | Ноябрь 2025 |
| **Язык** | Ассемблер x86 + C (i686-elf) |
| **Целевая архитектура** | Intel i386 (32-bit x86) |

---

**Made with ❤️ and Assembly**

**Happy OS hacking!** 🔧⚙️🖥️
