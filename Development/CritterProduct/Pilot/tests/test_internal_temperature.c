#include <math.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

#ifndef CPU_TEMP_PATH
#define CPU_TEMP_PATH "/sys/class/thermal/thermal_zone0/temp"
#endif

int main(void)
{
    FILE *file = fopen(CPU_TEMP_PATH, "r");
    int millicelsius = 0;
    double celsius = 0.0;

    if (file == NULL)
    {
        /* A25: Missing Pi hardware is not a passed hardware check. */
        if (errno == ENOENT)
            return 77;
        fprintf(stderr, "failed to open internal temperature file: %s\n", CPU_TEMP_PATH);
        return 1;
    }

    if (fscanf(file, "%d", &millicelsius) != 1)
    {
        fprintf(stderr, "failed to parse internal temperature from %s\n", CPU_TEMP_PATH);
        fclose(file);
        return 1;
    }

    fclose(file);

    celsius = (double)millicelsius / 1000.0;
    if (!isfinite(celsius) || celsius <= 0.0)
    {
        fprintf(stderr, "internal temperature is invalid: %.3f C\n", celsius);
        return 1;
    }

    printf("internal temperature ok: %.3f C\n", celsius);
    return 0;
}
