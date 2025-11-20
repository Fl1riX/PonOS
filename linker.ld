/* linker.ld - скрипт линковки для ядра PonOS */

ENTRY(_start)

SECTIONS
{
    /* Ядро загружается по адресу 0x1000 */
    . = 0x1000;

    /* Точка входа должна быть первой */
    .text : ALIGN(16)
    {
        *(.text)          /* Весь код */
        *(.text.*)
    }

    /* Секция read-only данных */
    .rodata : ALIGN(16)
    {
        *(.rodata)
        *(.rodata.*)
    }

    /* Секция инициализированных данных */
    .data : ALIGN(16)
    {
        *(.data)
        *(.data.*)
    }

    /* Секция неинициализированных данных (BSS) */
    .bss : ALIGN(16)
    {
        *(COMMON)
        *(.bss)
        *(.bss.*)
    }

    /* Отбрасываем ненужные секции */
    /DISCARD/ :
    {
        *(.comment)
        *(.eh_frame)
        *(.note.*)
    }
}
