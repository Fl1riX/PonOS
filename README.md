# PonOS - Простая операционная система

[![Status](https://img.shields.io/badge/status-in_development-yellow)](https://github.com/Fl1riX/PonOS)
[![License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Fl1riX/PonOS/blob/main/LICENSE)
[![Architecture](https://img.shields.io/badge/architecture-x86-lightgrey)](https://github.com/Fl1riX/PonOS)
[![Language](https://img.shields.io/badge/language-Assembly-red)](https://github.com/Fl1riX/PonOS)
[![Views](https://komarev.com/ghpvc/?username=Fl1riX&repo=PonOS&color=brightgreen)](https://github.com/Fl1riX/PonOS)

PonOS - это экспериментальная операционная система, разрабатываемая в образовательных целях. В настоящее время проект находится на ранней стадии разработки с загрузчиком на ассемблере и базовым ядром.

---

## 🛠️ Сборка
- Сборка загрузчика

```bash
nasm -f bin boot.asm -o boot.bin
```

- Сборка ядра

```bash
nasm -f bin kernel.asm -o kernel.bin
```

- Монтирование диска

```bash
cat boot.bin kernel.bin > ponos.img
```

## 🚀 Запуск

```bash
qemu-system-i386 -fda ponos.img
```

## 📜 Лицензия

MIT License. Подробнее см. в файле [LICENSE](LICENSE).
