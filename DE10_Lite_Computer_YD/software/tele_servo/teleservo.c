#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"
#include <stdio.h>
#include <unistd.h>

// Temps min et max pour le signal PWM
#define PWM_MIN 50000   // 1ms -> 0¡ã
#define PWM_MAX 100000  // 2ms -> 90¡ã
#define MAX_ANGLE 90    // Angle max
#define STEP_ANGLE 10   // Pas d'angle
#define MAX_DISTANCE_DIGITS 6 // Chiffres max pour l'affichage

// Codes pour l'affichage 7 segments
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

// Mettre ¨¤ jour l'affichage 7 segments
void update_seven_segment_display(unsigned int* display_buffer) {
    IOWR_ALTERA_AVALON_PIO_DATA(HEX3_HEX0_BASE,
        (display_buffer[2] << 24) | (display_buffer[3] << 16) |
        (display_buffer[4] << 8) | display_buffer[5]);
    IOWR_ALTERA_AVALON_PIO_DATA(HEX5_HEX4_BASE,
        (display_buffer[0] << 8) | display_buffer[1]);
}

int main() {
    unsigned int angle = 0;             // Angle actuel
    unsigned int measured_distance = 0; // Distance mesur¨¦e
    unsigned int position;              // Position du servomoteur
    unsigned int seven_seg_buffer[6] = {0}; // Buffer pour l'affichage

    printf("Programme de servomoteur et mesure de distance d¨¦marr¨¦...\n");

    while (1) {
        // Convertir l'angle en position
        position = (angle * 255) / MAX_ANGLE;

        // Envoyer la position au servomoteur
        IOWR_ALTERA_AVALON_PIO_DATA(SERVOMOTEUR_AVALON_0_BASE, position);

        // Lire la distance du t¨¦l¨¦m¨¨tre
        measured_distance = IORD_ALTERA_AVALON_PIO_DATA(TELEMETRE_0_BASE);

        // Afficher l'angle sur les 3 premiers segments
        for (int i = 0; i < 3; i++) {
            seven_seg_buffer[2 - i] = seven_seg_code[(angle / (1 << (4 * i))) % 10];
        }

        // Afficher la distance sur les 3 derniers segments
        for (int i = 0; i < 3; i++) {
            seven_seg_buffer[5 - i] = seven_seg_code[(measured_distance / (1 << (4 * i))) % 10];
        }

        // Mettre ¨¤ jour l'affichage
        update_seven_segment_display(seven_seg_buffer);

        // Afficher angle et distance
        printf("%d¡ã -> %d cm\n", angle, measured_distance);

        // Augmenter l'angle
        angle += STEP_ANGLE;
        if (angle > MAX_ANGLE) {
            angle = 0; // R¨¦initialiser
        }

        // Attendre 1 seconde
        usleep(1000000);
    }

    return 0;
}
