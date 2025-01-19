#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"
#include "unistd.h"
#include <stdio.h>

// Table de codes pour l'affichage 7 segments
unsigned int seven_seg_code[] = {
    0x3F, // 0
    0x06, // 1
    0x5B, // 2
    0x4F, // 3
    0x66, // 4
    0x6D, // 5
    0x7D, // 6
    0x07, // 7
    0x7F, // 8
    0x6F  // 9
};

// Table des puissances de 10 pour extraire les chiffres
unsigned int decimal_multiplier[] = {1, 10, 100, 1000, 10000, 100000};

// Mettre ¨¤ jour l'affichage 7 segments
void update_seven_segment_display(unsigned int* display_buffer) {
    // Mettre ¨¤ jour HEX3_HEX0 et HEX5_HEX4
    IOWR_ALTERA_AVALON_PIO_DATA(HEX3_HEX0_BASE,
        (display_buffer[2] << 24) | (display_buffer[3] << 16) |
        (display_buffer[4] << 8) | display_buffer[5]);
    IOWR_ALTERA_AVALON_PIO_DATA(HEX5_HEX4_BASE,
        (display_buffer[0] << 8) | display_buffer[1]);
}

int main() {
    unsigned int measured_distance = 0;              // Distance mesur¨¦e
    unsigned int seven_seg_buffer[6] = {0};          // Buffer pour l'affichage

    while (1) {
        // Lire la distance du t¨¦l¨¦m¨¨tre
        measured_distance = IORD_ALTERA_AVALON_PIO_DATA(TELEMETRE_0_BASE);

        // Convertir la distance en donn¨¦es pour l'affichage 7 segments
        for (int i = 0; i < 6; i++) {
            seven_seg_buffer[5 - i] = seven_seg_code[(measured_distance / decimal_multiplier[i]) % 10];
        }

        // Mettre ¨¤ jour l'affichage
        update_seven_segment_display(seven_seg_buffer);

        printf("Distance mesur¨¦e : %d cm\n", measured_distance);

        // Attendre 300 ms
        usleep(300000);
    }

    return 0;
}
