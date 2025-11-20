void main() {
    unsigned char *video = (unsigned char *)0xB8000;
    video[0] = 'H';
    video[1] = 0x0F;
    
    // Бесконечный цикл
    for(;;);
}