#include "drivers/vga.h"

void main() {
    clear_screen();
    print_string("ooooooooo.                           .oooooo.    .oooooo..o \n`888   `Y88.                        d8P'  `Y8b  d8P'    `Y8  \n 888   .d88   .ooooo.  ooo. .oo.   888      888 Y88bo.      \n 888ooo88P'  d88' `88b `888P'Y88b  888      888  'Y8888o.   \n 888         888   888  888   888  888      888      'Y88b  \n 888         888   888  888   888  `88b    d88' oo     .d8P \no888o        `Y8bod8P' o888o o888o  `Y8bood8P' `8``88888P' \n\0");
    print_string("Type 'help' to get command list\n\0");
    
    // Бесконечный цикл
    for(;;);
}
