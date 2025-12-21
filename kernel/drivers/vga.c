#include "vga.h"

static int cursor_x = 0;
static int cursor_y = 0;
static unsigned short *video = (unsigned short *)VGA_ADRESS;

// TODO: переписать clear screen через for
// дописать print_hex и print_dec

// Выводит один символ на экран в текущей позиции курсора
void print_char(char symbol) {    
    // Если курсор дошёл до конца строки (правая граница экрана)
    if (cursor_x >= VGA_WIDTH) {
        cursor_x = 0;      // Возвращаемся в начало строки
        cursor_y++;        // Переходим на следующую строку
    }
    else if (cursor_y >= VGA_HEIGHT) {
        scroll_screen();
        cursor_x = 0;
    }
    else {
        // Проверяем специальные символы
        
        // Если это символ новой строки
        if (symbol == '\n') {
            // Проверяем, не выходим ли за нижнюю границу экрана
            cursor_y++;  // Переходим на следующую строку
            cursor_x = 0; // Возвращаемся в начало строки
            
        }
        // Если это символ табуляции (отступ)
        else if (symbol == '\t') {
            // Проверяем, поместится ли табуляция в текущей строке
            if (cursor_x <= VGA_WIDTH - 4) {
                cursor_x += 4;  // Сдвигаем курсор на 4 позиции вправо
            }
            else {
                // Если не помещается - переходим на новую строку
                cursor_x = 0;
                cursor_y++;

            }
        }
        // Если это обычный символ (буква, цифра, знак)
        else {
            // Записываем символ в видеопамять по текущим координатам
            video[GET_INDEX(cursor_x, cursor_y)] = (VGA_COLOR(VGA_BLACK, VGA_WHITE) << 8) | symbol;
            cursor_x++;  // Сдвигаем курсор вправо для следующего символа
        }
    }
}

// Выводит целую строку на экран
void print_string(const char *str) {
    // Проходим по каждому символу строки, пока не дойдём до конца строки (символ '\0')
    for (int i = 0; str[i] != '\0'; i++) {
        // Выводим текущий символ
        print_char(str[i]);
    }
}

// Очищает весь экран, заполняя его пробелами
void clear_screen(){
    // Пока не прошли все строки и столбцы экрана
    while (cursor_y < VGA_HEIGHT && cursor_x <= VGA_WIDTH) {
        // Если не дошли до конца текущей строки
        if (cursor_x < VGA_WIDTH){
            // Записываем пробел в текущую позицию
            video[GET_INDEX(cursor_x, cursor_y)] = (VGA_COLOR(VGA_BLACK, VGA_WHITE) << 8) | ' ';
            cursor_x++;  // Переходим к следующей колонке
        }
        // Если дошли до конца строки
        else if (cursor_x >= VGA_WIDTH && cursor_y < VGA_HEIGHT){
            cursor_x = 0;      // Возвращаемся в начало строки
            cursor_y += 1;     // Переходим на следующую строку

            // Записываем пробел в начало новой строки
            video[GET_INDEX(cursor_x, cursor_y)] = (VGA_COLOR(VGA_BLACK, VGA_WHITE) << 8) | ' ';
            cursor_x++;  // Готовимся к следующей колонке
        }
    }
    // После очистки устанавливаем курсор в левый верхний угол экрана
    cursor_x = 0;
    cursor_y = 0;
}

void scroll_screen() {
    for (int y = 0; y < VGA_HEIGHT; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            video[GET_INDEX(x, y - 1)] = video[GET_INDEX(x, y)];
        }
    }
    for (int i = 0; i < VGA_WIDTH; i++) {
        video[GET_INDEX(i, 24)] = (VGA_COLOR(VGA_BLACK, VGA_WHITE) << 8) | ' ';
    }

}
