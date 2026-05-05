#define VGA_ADDRESS 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

#define GET_INDEX(x, y) ((y) * VGA_WIDTH + (x)) //получаем индекс курсора
#define VGA_COLOR(fg, bg) ((bg) << 4 | (fg))                                              

#define VGA_BLACK   0
#define VGA_BLUE    1
#define VGA_GREEN   2
#define VGA_CYAN    3
#define VGA_RED     4
#define VGA_MAGNETA 5
#define VGA_BROWN   6
#define VGA_WHITE   7
#define COLOR_DEFAULT 0xFFFF

void print_char(char c, unsigned short fg_color, unsigned short bg_color);
void clear_screen();
void print_string(const char *str, unsigned short fg_color, unsigned short bg_color);
void scroll_screen();
void print_dec(unsigned int num, unsigned short fg_color, unsigned short bg_color);
void print_hex(unsigned int num, unsigned short fg_color, unsigned short bg_color);
