#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef DATA_FILE_PATH
#define DATA_FILE_PATH "Data/temperature_samples.csv"
#endif

int main(void)
{
    FILE *file = fopen(DATA_FILE_PATH, "r");
    char line[512];
    double first_temperature = 0.0;
    double last_temperature = 0.0;
    int sample_count = 0;

    if (file == NULL)
    {
        fprintf(stderr, "failed to open fallback data file: %s\n", DATA_FILE_PATH);
        return 1;
    }

    if (fgets(line, sizeof(line), file) == NULL)
    {
        fprintf(stderr, "fallback data file is empty\n");
        fclose(file);
        return 1;
    }

    if (strstr(line, "timestamp_s") == NULL || strstr(line, "temperature_c") == NULL)
    {
        fprintf(stderr, "fallback data file missing expected CSV header\n");
        fclose(file);
        return 1;
    }

    while (fgets(line, sizeof(line), file) != NULL)
    {
        char *temperature_field;
        char *value_end = NULL;
        double temperature;

        if (strchr(line, ',') == NULL)
            continue;

        temperature_field = strchr(line, ',');
        if (temperature_field == NULL)
            continue;

        temperature_field += 1;
        temperature = strtod(temperature_field, &value_end);
        if (value_end == temperature_field)
            continue;

        if (sample_count == 0)
            first_temperature = temperature;

        last_temperature = temperature;
        sample_count += 1;
    }

    fclose(file);

    if (sample_count < 5)
    {
        fprintf(stderr, "expected at least 5 fallback samples, got %d\n", sample_count);
        return 1;
    }

    if (!isfinite(first_temperature) || !isfinite(last_temperature) || first_temperature <= 0.0 || last_temperature <= 0.0)
    {
        fprintf(stderr, "fallback sample values are invalid: first=%.6f last=%.6f\n", first_temperature, last_temperature);
        return 1;
    }

    printf("fallback data file parsed successfully: %d samples, first=%.6f, last=%.6f\n",
           sample_count,
           first_temperature,
           last_temperature);
    return 0;
}
