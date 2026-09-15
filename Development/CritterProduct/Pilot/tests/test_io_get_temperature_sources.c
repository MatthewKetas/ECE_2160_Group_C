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
        return 77;
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
    int available = 0;

    for (int source = TEMPERATURE_SOURCE_SENSE_HAT; source <= TEMPERATURE_SOURCE_CPU; ++source)
    {
        int result = check_source((critter_temperature_source_t)source, "source");
        if (result == 0)
            available += 1;
        else if (result != 77)
            status = 1;
    }
    if (critter_io_close() != 0)
        status = 1;
    if (status == 0 && available == 0)
        return 77;

    if (status == 0)
        puts("all available source-specific temperature reads passed");

    return status;
}
