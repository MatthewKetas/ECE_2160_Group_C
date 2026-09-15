#define _POSIX_C_SOURCE 200809L
/* Host regression checks; run with assertions enabled in every build type. */
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include "Memory/critter_memory.h"
#include "Computation/critter_computation.h"
#include "IO/critter_io.h"
#include "sense_hat_environment.h"

static void check_memory_and_analysis(void)
{
    critter_memory_t memory = {0};
    critter_window_summary_t summary = {0};
    critter_analysis_result_t result = {0};
    critter_sample_t sample = {.timestamp_s = 1.0, .temperature_c = 20.0, .source = TEMPERATURE_SOURCE_DATA};
    assert(critter_memory_add_sample(&memory, &sample) == -1);
    assert(critter_memory_build_summary(&memory, &summary) == -1);
    assert(critter_memory_init(&memory, 0U) == -1);
    assert(critter_memory_init(&memory, SIZE_MAX) == -1);
    assert(critter_memory_init(&memory, 5U) == 0);
    for (size_t i = 0U; i < 8U; ++i)
    {
        sample.timestamp_s = (double)i + 1.0;
        sample.temperature_c = 20.0 + 0.5 * (double)i;
        assert(critter_memory_add_sample(&memory, &sample) == 0);
    }
    assert(critter_memory_build_summary(&memory, &summary) == 0);
    assert(summary.sample_count == 5U && summary.first_timestamp_s == 4.0);
    assert(critter_compute_analysis(&summary, 10.0, &result) == 0);
    assert(fabs(result.trend_c_per_s - 0.5) < 1.0e-12);
    assert(fabs(result.predicted_temperature_c - 28.5) < 1.0e-12);
    assert(critter_memory_add_sample(&memory, &sample) == -1); /* Duplicate time. */
    sample.timestamp_s = 9.0;
    sample.temperature_c = INFINITY;
    assert(critter_memory_add_sample(&memory, &sample) == -1);
    sample.temperature_c = 1.0e200;
    assert(critter_memory_add_sample(&memory, &sample) == -1);
    assert(critter_compute_analysis(&summary, -1.0, &result) == -1);
    summary.mean_temperature_c = NAN;
    assert(critter_compute_analysis(&summary, 10.0, &result) == -1);
    assert(critter_memory_build_summary(&memory, &summary) == 0);
    summary.first_timestamp_s = summary.last_timestamp_s;
    assert(critter_compute_analysis(&summary, 10.0, &result) == -1);
    memory.head = memory.capacity;
    assert(critter_memory_build_summary(&memory, &summary) == -1);
    critter_memory_free(&memory);
    assert(critter_memory_add_sample(&memory, &sample) == -1);
    assert(critter_memory_init(&memory, 5U) == 0);
    sample.temperature_c = 20.0;
    for (size_t i = 0U; i < 3U; ++i)
    {
        sample.timestamp_s = (double)i + 1.0;
        sample.source = i == 1U ? TEMPERATURE_SOURCE_CPU : TEMPERATURE_SOURCE_DATA;
        assert(critter_memory_add_sample(&memory, &sample) == 0);
    }
    assert(critter_memory_build_summary(&memory, &summary) == 0);
    assert(summary.source == TEMPERATURE_SOURCE_UNKNOWN);
    assert(summary.sample_count_by_source[TEMPERATURE_SOURCE_DATA] == 2U);
    assert(summary.sample_count_by_source[TEMPERATURE_SOURCE_CPU] == 1U);
    assert(critter_compute_analysis(&summary, 10.0, &result) == 0);
    assert(!result.likely_hvac_active && !result.likely_heating && !result.likely_cooling);
    summary.source = TEMPERATURE_SOURCE_DATA;
    summary.latest_temperature_c = 20.08;
    summary.max_temperature_c = 20.08;
    summary.mean_temperature_c = 20.04;
    summary.stddev_temperature_c = 0.03266;
    assert(critter_compute_analysis(&summary, 10.0, &result) == 0);
    assert(result.likely_heating && result.likely_hvac_active);
    memory.total_received_samples = CRITTER_MAX_SAMPLE_TOTAL;
    assert(critter_memory_add_sample(&memory, &sample) == -1);
    assert(memory.total_received_samples == CRITTER_MAX_SAMPLE_TOTAL);
    critter_memory_free(&memory);
    critter_memory_free(&memory);
}

static void write_input(const char *path, const char *contents)
{
    FILE *file = fopen(path, "w");
    assert(file != NULL);
    assert(fputs(contents, file) >= 0);
    assert(fclose(file) == 0);
}

static void check_io(const char *directory)
{
    char input[256];
    char output[256];
    char special[256];
    assert(snprintf(input, sizeof(input), "%s/input.csv", directory) > 0);
    assert(snprintf(output, sizeof(output), "%s/output.csv", directory) > 0);
    assert(snprintf(special, sizeof(special), "%s/special", directory) > 0);
    write_input(input, "timestamp_s,temperature_c\n1,nan\n2,1e9999\n3,21oops\n4,21\n5,22\n");
    assert(setenv("CRITTER_DATA_FILE", input, 1) == 0);
    assert(setenv("CRITTER_OUTPUT_FILE", output, 1) == 0);
    double value = -1.0;
    assert(critter_io_get_temperature_from_source(&value, TEMPERATURE_SOURCE_DATA) == 0 && value == 21.0);
    assert(critter_io_get_temperature_from_source(&value, TEMPERATURE_SOURCE_DATA) == 0 && value == 22.0);
    assert(critter_io_get_temperature_from_source(&value, TEMPERATURE_SOURCE_DATA) == -1); /* EOF. */
    assert(unlink(input) == 0);
    assert(critter_io_get_temperature_from_source(&value, TEMPERATURE_SOURCE_DATA) == -1); /* No stale success. */
    critter_sample_t sample = {.timestamp_s = 1.0, .temperature_c = 21.0, .source = TEMPERATURE_SOURCE_DATA};
    assert(critter_io_save_sample(&sample) == 0);
    sample.temperature_c = NAN;
    assert(critter_io_save_sample(&sample) == -1);
    sample.temperature_c = 21.0;
    assert(symlink(output, special) == 0);
    assert(setenv("CRITTER_OUTPUT_FILE", special, 1) == 0);
    assert(critter_io_save_sample(&sample) == -1);
    assert(unlink(special) == 0);
    assert(mkfifo(special, 0600) == 0);
    assert(critter_io_save_sample(&sample) == -1); /* Must not block. */
    assert(setenv("CRITTER_DATA_FILE", special, 1) == 0);
    assert(critter_io_get_temperature_from_source(&value, TEMPERATURE_SOURCE_DATA) == -1);
    assert(unlink(special) == 0);
    char long_path[5000];
    (void)memset(long_path, 'x', sizeof(long_path) - 1U);
    long_path[sizeof(long_path) - 1U] = '\0';
    assert(setenv("CRITTER_OUTPUT_FILE", long_path, 1) == 0);
    assert(critter_io_save_sample(&sample) == -1);
    assert(setenv("CRITTER_DATA_FILE", input, 1) == 0);
    FILE *file = fopen(input, "w");
    assert(file != NULL);
    for (size_t i = 0U; i < 4096U; ++i)
        assert(fputs("header\n", file) >= 0);
    assert(fputs("1,25\n", file) >= 0);
    assert(fclose(file) == 0);
    assert(critter_io_get_temperature_from_source(&value, TEMPERATURE_SOURCE_DATA) == -1);
    assert(unlink(input) == 0);
    assert(unlink(output) == 0);
    assert(critter_io_close() == 0);
}

int main(void)
{
    check_memory_and_analysis();
    char directory[] = "/tmp/critter-safety-XXXXXX";
    assert(mkdtemp(directory) != NULL);
    check_io(directory);
    assert(rmdir(directory) == 0);
    sense_hat_environment_t sensor = {.hts_fd = -1, .pressure_fd = -1, .initialized = true};
    double value = 0.0;
    assert(sense_hat_environment_read_temperature(&sensor, &value) == -1);
    assert(sense_hat_environment_read_humidity(&sensor, &value) == -1);
    assert(sense_hat_environment_close(&sensor) == 0);
    assert(sense_hat_environment_close(&sensor) == 0);
    assert(sense_hat_environment_close(NULL) == -1);
    puts("safety regressions passed");
    return 0;
}
