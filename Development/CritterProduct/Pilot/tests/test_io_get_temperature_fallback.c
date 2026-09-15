#include <math.h>
#include <stdio.h>

#include "IO/critter_io.h"

int main(void)
{
    double temperature_c = 0.0;
    critter_temperature_source_t source = TEMPERATURE_SOURCE_UNKNOWN;
    int rc;

    rc = critter_io_get_temperature(&temperature_c, &source);
    if (rc != 0)
    {
        fprintf(stderr, "critter_io_get_temperature failed to read any available source\n");
        return 1;
    }

    if (!isfinite(temperature_c) || temperature_c <= 0.0)
    {
        fprintf(stderr, "temperature is invalid: %.6f C\n", temperature_c);
        return 1;
    }

    if (source != TEMPERATURE_SOURCE_SENSE_HAT &&
        source != TEMPERATURE_SOURCE_DATA &&
        source != TEMPERATURE_SOURCE_CPU)
    {
        fprintf(stderr, "unexpected source: %d\n", (int)source);
        return 1;
    }

    if (critter_io_close() != 0)
        return 1;
    printf("temperature source=%d value=%.6f C\n", (int)source, temperature_c);
    return 0;
}
