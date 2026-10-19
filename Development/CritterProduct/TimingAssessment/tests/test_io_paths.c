#define _POSIX_C_SOURCE 200809L
#define _DARWIN_C_SOURCE
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "IO/critter_io.h"

static void put(const char *path, const char *text)
{
    FILE *f = fopen(path, "w");
    assert(f != NULL);
    assert(fputs(text, f) >= 0);
    assert(fclose(f) == 0);
}

int main(void)
{
    char directory[] = "/tmp/critter-io-test-XXXXXX";
    assert(mkdtemp(directory) != NULL);
    char legacy[512], input[512], output[512];
    snprintf(legacy, sizeof(legacy), "%s/legacy.csv", directory);
    snprintf(input, sizeof(input), "%s/input.csv", directory);
    snprintf(output, sizeof(output), "%s/output.csv", directory);
    put(legacy, "timestamp_s,temperature_c\n1,33\n");
    put(input, "timestamp_s,temperature_c\n1,22.5\n");
    unsetenv("CRITTER_INPUT_FILE");
    unsetenv("CRITTER_OUTPUT_FILE");
    setenv("CRITTER_DATA_FILE", legacy, 1);
    double temperature;
    assert(critter_io_get_temperature_from_source(&temperature, TEMPERATURE_SOURCE_DATA) == 0);
    assert(temperature == 33);
    setenv("CRITTER_INPUT_FILE", input, 1);
    assert(critter_io_get_temperature_from_source(&temperature, TEMPERATURE_SOURCE_DATA) == 0);
    assert(temperature == 22.5);
    critter_sample_t sample = {.timestamp_s = 2, .temperature_c = temperature, .source = TEMPERATURE_SOURCE_DATA};
    setenv("CRITTER_OUTPUT_FILE", output, 1);
    assert(critter_io_save_sample(&sample) == 0);
    FILE *f = fopen(input, "r");
    char contents[128] = {0};
    assert(f && fread(contents, 1, sizeof(contents) - 1, f) > 0);
    fclose(f);
    assert(!strcmp(contents, "timestamp_s,temperature_c\n1,22.5\n"));
    unsetenv("CRITTER_OUTPUT_FILE");
    assert(critter_io_save_sample(&sample) == 0);
    f = fopen(legacy, "r");
    int lines = 0;
    while (fgets(contents, sizeof(contents), f)) ++lines;
    fclose(f);
    assert(lines == 3);
    setenv("CRITTER_OUTPUT_FILE", directory, 1);
    assert(critter_io_save_sample(&sample) != 0);
#ifdef __linux__
    setenv("CRITTER_OUTPUT_FILE", "/dev/full", 1);
    assert(critter_io_save_sample(&sample) != 0);
#endif
    unlink(input);
    unlink(output);
    unlink(legacy);
    rmdir(directory);
    puts("input/output overrides, legacy fallback, and write errors passed");
    return 0;
}
