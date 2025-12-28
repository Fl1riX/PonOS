#include "vga.h"

static int cursor_x = 0;
static int cursor_y = 0;
static unsigned short *video = (unsigned short *)VGA_ADRESS;

// TODO: дописать print_hex и print_dec

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

// вывод целочисленных значений
void print_dec(int num) {
    if (num > 0)
        if (num != 0) {
            unsigned short nums[100]; // массив для чисел 
            short real_nums = 0;      // количество чисел, запианных в массив 

            // записываем числа в массив
            for (int i=0; num > 0; i++) {
                nums[i] = num % 10; // отделяем по 1 цифре от числа и записываем в массив 
                num = num / 10;     // уменьшаем число 
                real_nums++;        // увеличиваем уоличество записанных в массив цифр 
            }
            // выводим числа начиная с конца
            for (int i=1; i < real_nums + 1; i++) {
                print_char(48 + nums[real_nums - i]);
            }
        }
        else {
            print_char('0');
        }
    else {
            print_string("print_dec: Нельзя вывести число меньше 0");
        }
}

// выводит числа в hex формате 
// т.к любое передаваемое число будет ввиде обычного числа, то обрабатываем его в таком виде
void print_hex(int num) {
    // проверка на ввод отрицательного числа 
    if (num > 0) {
        if (num != 0) {
            unsigned short nums[100]; // массив для записи цифр 
            short real_nums = 0; // количество цифр записанных в массив 

            // разбиваем число на цифры 
            for (int i=0; num > 0; i++) {
                nums[i] = num % 16;
                num = num / 16;
                real_nums++;
            }

            print_string("0x");
            
            // выводим число в 16ричном формате с проверкой на вывод букв 
            for (int i=1; i < real_nums + 1; i++) {
                if (nums[real_nums - i] < 10) {
                    print_char(48 + nums[real_nums - i]);
                }
                else if (nums[real_nums - i] > 10) {
                    print_char(55 + nums[real_nums - i]);
                }
            }
        }
        else {
            print_string("0x00000");
        }
    }
    else {
        print_string("print_hex: нельзя вывести чило меньше 0");
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
void clear_screen() {
    for (int y=0; y < VGA_HEIGHT; y++) {
        for (int x=0; x < VGA_WIDTH; x++) {
            video[GET_INDEX(x, y)] = (VGA_COLOR(VGA_BLACK, VGA_WHITE) << 8) | ' ';
        } 
    }
    // После очистки устанавливаем курсор в левый верхний угол экрана
    cursor_x = 0;
    cursor_y = 0;
}

// проматывает экран на строку вниз при переполнении его символами 
void scroll_screen() {
    // посимвольно переносим текст на строчку вверх 
    for (int y = 0; y < VGA_HEIGHT; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            video[GET_INDEX(x, y - 1)] = video[GET_INDEX(x, y)];
        }
    }
    // очистка последней строки 
    for (int i = 0; i < VGA_WIDTH; i++) {
        video[GET_INDEX(i, 24)] = (VGA_COLOR(VGA_BLACK, VGA_WHITE) << 8) | ' ';
    }

}
