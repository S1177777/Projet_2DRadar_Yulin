#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"
#include <stdio.h>
#include <unistd.h>

// D¨¦finitions pour VGA
#define FPGA_CHAR_BASE 0xff203030 // Adresse r¨¦elle ¨¤ modifier
#define PIXEL_BUF_CTRL_BASE 0xff203020 // Adresse r¨¦elle ¨¤ modifier
#define RGB_RESAMPLER_BASE 0x4000000 // Adresse r¨¦elle ¨¤ modifier

#define STANDARD_X 320
#define STANDARD_Y 240
#define INTEL_BLUE 0x0071C5
#define INTEL_RED  0xFF0000

// D¨¦finitions pour le servomoteur et le t¨¦l¨¦m¨¨tre
#define PWM_MIN 50000   // 1ms -> 0¡ã
#define PWM_MAX 100000  // 2ms -> 90¡ã
#define MAX_ANGLE 90    // Angle max
#define STEP_ANGLE 10   // Pas d'angle
#define RADAR_RADIUS 100

/* D¨¦clarations de fonctions */
void video_text(int, int, char *);
void video_box(int, int, int, int, short);
void video_plot(int, int, short);
int resample_rgb(int, int);
int get_data_bits(int);

int screen_x;
int screen_y;
int res_offset;
int col_offset;

/*******************************************************************************
 * Fonction principale
 ******************************************************************************/
int main() {
    volatile int *video_resolution = (int *)(PIXEL_BUF_CTRL_BASE + 0x8);
    screen_x = *video_resolution & 0xFFFF;
    screen_y = (*video_resolution >> 16) & 0xFFFF;

    volatile int *rgb_status = (int *)(RGB_RESAMPLER_BASE);
    int db = get_data_bits(*rgb_status & 0x3F);

    // V¨¦rifier la r¨¦solution
    res_offset = (screen_x == 160) ? 1 : 0;
    col_offset = (db == 8) ? 1 : 0;

    // Effacer l'¨¦cran
    video_box(0, 0, STANDARD_X, STANDARD_Y, 0);

    unsigned int angle = 0;             // Angle actuel
    unsigned int measured_distance = 0; // Distance mesur¨¦e
    unsigned int position;              // Position du servomoteur

    printf("Programme de servomoteur et affichage radar VGA d¨¦marr¨¦...\n");

    while (1) {
        // Convertir l'angle en position
        position = (angle * 255) / MAX_ANGLE;

        // Envoyer la position au servomoteur
        IOWR_ALTERA_AVALON_PIO_DATA(SERVOMOTEUR_AVALON_0_BASE, position);

        // Lire la distance du t¨¦l¨¦m¨¨tre
        measured_distance = IORD_ALTERA_AVALON_PIO_DATA(TELEMETRE_0_BASE);

        // Afficher le r¨¦sultat du radar
        int x = STANDARD_X / 2 + measured_distance * RADAR_RADIUS * cos(angle * 3.14159 / 180) / 100;
        int y = STANDARD_Y - measured_distance * RADAR_RADIUS * sin(angle * 3.14159 / 180) / 100;

        short color = (measured_distance < 50) ? resample_rgb(db, INTEL_RED) : resample_rgb(db, INTEL_BLUE);
        video_plot(x, y, color);

        // Afficher angle et distance
        printf("%d¡ã -> %d cm\n", angle, measured_distance);

        // Augmenter l'angle
        angle += STEP_ANGLE;
        if (angle > MAX_ANGLE) {
            angle = 0; // R¨¦initialiser
            video_box(0, 0, STANDARD_X, STANDARD_Y, 0);
        }

        // Attendre 300 ms
        usleep(300000);
    }

    return 0;
}

/* Afficher du texte */
void video_text(int x, int y, char *text_ptr) {
    int offset;
    volatile char *character_buffer = (char *)FPGA_CHAR_BASE;
    offset = (y << 7) + x;

    while (*(text_ptr)) {
        *(character_buffer + offset) = *(text_ptr);
        ++text_ptr;
        ++offset;
    }
}

/* Dessiner un rectangle */
void video_box(int x1, int y1, int x2, int y2, short pixel_color) {
    int pixel_buf_ptr = *(int *)PIXEL_BUF_CTRL_BASE;
    int pixel_ptr, row, col;
    int x_factor = 0x1 << (res_offset + col_offset);
    int y_factor = 0x1 << (res_offset);

    x1 = x1 / x_factor;
    x2 = x2 / x_factor;
    y1 = y1 / y_factor;
    y2 = y2 / y_factor;

    for (row = y1; row <= y2; row++) {
        for (col = x1; col <= x2; ++col) {
            pixel_ptr = pixel_buf_ptr + (row << (10 - res_offset - col_offset)) + (col << 1);
            *(short *)pixel_ptr = pixel_color;
        }
    }
}

/* Dessiner un point */
void video_plot(int x, int y, short pixel_color) {
    int pixel_buf_ptr = *(int *)PIXEL_BUF_CTRL_BASE;
    int pixel_ptr;

    x = x / (0x1 << (res_offset + col_offset));
    y = y / (0x1 << res_offset);

    pixel_ptr = pixel_buf_ptr + (y << (10 - res_offset - col_offset)) + (x << 1);
    *(short *)pixel_ptr = pixel_color;
}

/* Convertir la couleur */
int resample_rgb(int num_bits, int color) {
    if (num_bits == 8) {
        color = (((color >> 16) & 0x000000E0) | ((color >> 11) & 0x0000001C) |
                 ((color >> 6) & 0x00000003));
        color = (color << 8) | color;
    } else if (num_bits == 16) {
        color = (((color >> 8) & 0x0000F800) | ((color >> 5) & 0x000007E0) |
                 ((color >> 3) & 0x0000001F));
    }
    return color;
}

/* Obtenir le nombre de bits */
int get_data_bits(int mode) {
    switch (mode) {
        case 0x0:
            return 1;
        case 0x7:
        case 0x11:
            return 8;
        case 0x12:
            return 9;
        case 0x14:
            return 16;
        case 0x17:
            return 24;
        case 0x19:
            return 30;
        case 0x31:
            return 8;
        case 0x32:
            return 12;
        case 0x33:
            return 16;
        case 0x37:
            return 32;
        case 0x39:
            return 40;
        default:
            return 0;
    }
}
