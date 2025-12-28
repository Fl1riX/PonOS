#define VGA_ADRESS 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

#define GET_INDEX(x, y) ((y) * VGA_WIDTH + (x)) //получаем индекс курсора
#define VGA_COLOR(fg, bg) ((fg) << 4 | (bg))                                              

#define VGA_BLACK   0
#define VGA_BLUE    1
#define VGA_GREEN   2
#define VGA_CYAN    3
#define VGA_RED     4
#define VGA_MAGNETA 5
#define VGA_BROWN   6
#define VGA_WHITE   7

void print_char(char c);
void clear_screen();
void print_string(const char *str);
void scroll_screen();
void print_dec(int num);
void print_hex(int num);
