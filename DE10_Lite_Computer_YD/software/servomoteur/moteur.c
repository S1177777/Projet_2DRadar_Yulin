#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"
#include <stdio.h>
#include <unistd.h>

// D¨¦finir les temps min et max du signal PWM (en cycles d'horloge)
#define PWM_MIN 50000   // 1ms -> 0¡ã
#define PWM_MAX 100000  // 2ms -> 90¡ã
#define MAX_ANGLE 90    // Angle max
#define MAX_SWITCH_VALUE 1023 // Valeur max des switches (10 bits)

int main() {
    unsigned int switch_value;  // Valeur des switches
    unsigned int position;      // Valeur r¨¦duite ¨¤ 8 bits
    unsigned int angle;         // Angle correspondant

    printf("Programme de controle du servomoteur d¨¦marr¨¦...\n");

    while (1) {
        // Lire la valeur des switches (10 bits, de 0 ¨¤ 1023)
        switch_value = IORD_ALTERA_AVALON_PIO_DATA(SLIDER_SWITCHES_BASE);

        // R¨¦duire la valeur ¨¤ 8 bits
        position = switch_value >> 2;

        // Calculer l'angle correspondant
        angle = (position * MAX_ANGLE) / 255; // 255 = valeur max sur 8 bits

        // Envoyer la valeur 8 bits au servomoteur
        IOWR_ALTERA_AVALON_PIO_DATA(SERVOMOTEUR_AVALON_0_BASE, position);

        // Afficher la valeur des switches, la position et l'angle
        printf("Valeur des switches : %d, Position : %d, Angle : %d¡ã\n", switch_value, position, angle);

        // Attendre 500 ms
        usleep(500000);
    }

    return 0;
}
