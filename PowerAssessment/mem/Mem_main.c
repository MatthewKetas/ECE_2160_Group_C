#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <time.h>

#include "Memory/critter_memory.h"
#include "memory_dataset.h"

int main(void)
{
    critter_memory_t memory;
    critter_window_summary_t summary;
    const double sample_interval_s = 0.1;
    const double report_interval_s = 5.0;
    struct timespec start_ts;
    struct timespec now_ts;
    double elapsed_s = 0.0;
    double last_report_s = 0.0;

    if (critter_memory_init(&memory, 100U) != 0)
    {
        fprintf(stderr, "failed to initialize memory\n");
        return 1;
    }
    if (clock_gettime(CLOCK_MONOTONIC, &start_ts) != 0)
        goto timing_error;

    /* Fixed work per run: every dataset sample, once, in the same order. */
    for (size_t i = 0; i < MEMORY_SAMPLE_COUNT; ++i)
    {
        critter_sample_t sample = {
            .timestamp_s = MEMORY_FIRST_TIMESTAMP_S + i * sample_interval_s,
            .temperature_c = memory_temperatures_c[i],
            .source = TEMPERATURE_SOURCE_DATA
        };
        struct timespec sleep_ts = {.tv_sec = 0, .tv_nsec = 100000000L};

        if (critter_memory_add_sample(&memory, &sample) != 0)
        {
            fprintf(stderr, "failed to add dataset sample %zu\n", i);
            critter_memory_free(&memory);
            return 1;
        }
        if (clock_gettime(CLOCK_MONOTONIC, &now_ts) != 0)
            goto timing_error;
        elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
                  + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
        if (elapsed_s >= last_report_s + report_interval_s)
        {
            printf("\rProcessing: %zu / %zu samples", i + 1U, MEMORY_SAMPLE_COUNT);
            fflush(stdout);
            last_report_s = elapsed_s;
        }
        /* Same post-processing pause as Pilot; total runtime can exceed 60s. */
        if (nanosleep(&sleep_ts, NULL) != 0)
            goto timing_error;
    }

    if (critter_memory_build_summary(&memory, &summary) != 0)
    {
        fprintf(stderr, "failed to build summary\n");
        critter_memory_free(&memory);
        return 1;
    }
    if (clock_gettime(CLOCK_MONOTONIC, &now_ts) != 0)
        goto timing_error;
    elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
              + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
    printf("\nmemory: received=%zu valid=%zu rejected=%zu outliers=%zu elapsed=%.3fs\n",
           memory.total_received_samples, memory.total_valid_samples,
           memory.total_rejected_samples, memory.total_outliers, elapsed_s);
    printf("summary: count=%zu min=%.3f max=%.3f mean=%.6f median=%.6f stddev=%.9f retained=%.6f\n",
           summary.sample_count, summary.min_temperature_c, summary.max_temperature_c,
           summary.mean_temperature_c, summary.median_temperature_c,
           summary.stddev_temperature_c, summary.retained_ratio);
    critter_memory_free(&memory);
    return 0;

timing_error:
    fprintf(stderr, "memory run interrupted or clock read failed\n");
    critter_memory_free(&memory);
    return 1;
}
