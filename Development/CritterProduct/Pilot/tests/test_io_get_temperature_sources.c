#include <math.h>
#include <stdio.h>

#include "IO/critter_io.h"

static int check_source(critter_temperature_source_t source, const char *label)
{
    double temperature_c = 0.0;
    int rc = critter_io_get_temperature_from_source(&temperature_c, source);

    if (rc != 0)
    {
        printf("%s unavailable\n", label);
        return 0;
    }

    if (!isfinite(temperature_c) || temperature_c <= 0.0)
    {
        fprintf(stderr, "%s produced invalid temperature: %.6f C\n", label, temperature_c);
        return 1;
    }

    printf("%s ok: %.6f C\n", label, temperature_c);
    return 0;
}

int main(void)
{
    int status = 0;

    if (check_source(TEMPERATURE_SOURCE_SENSE_HAT, "sense_hat") != 0)
        status = 1;

    if (check_source(TEMPERATURE_SOURCE_DATA, "data") != 0)
        status = 1;

    if (check_source(TEMPERATURE_SOURCE_CPU, "cpu") != 0)
        status = 1;

    if (status == 0)
        puts("all available source-specific temperature reads passed");

    return status;
}
