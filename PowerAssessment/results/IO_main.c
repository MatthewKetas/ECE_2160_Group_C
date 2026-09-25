#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "Computation/critter_computation.h"
#include "IO/critter_io.h"
#include "Memory/critter_memory.h"

int main(void)
{
    critter_memory_t memory;
    critter_window_summary_t summary;
    critter_analysis_result_t analysis;

    const double collection_window_s = 60.0;
    const double sample_interval_s = 0.1;
    const double report_interval_s = 5.0;
    const double prediction_horizon_s = 30.0;

    struct timespec start_ts;
    struct timespec now_ts;

    double elapsed_s = 0.0;
    double last_report_s = 0.0;
    size_t total_read_attempts = 0U;
    size_t total_valid_samples = 0U;
    size_t total_rejected_samples = 0U;
    size_t total_outliers = 0U;
    double sampling_rate_hz = 0.0;

    if (critter_memory_init(&memory, 100U) != 0)
    {
        fprintf(stderr, "failed to initialize memory\n");
        return 1;
    }

    if (clock_gettime(CLOCK_MONOTONIC, &start_ts) != 0)
    {
        fprintf(stderr, "failed to start one-minute collection window\n");
        critter_memory_free(&memory);
        return 1;
    }

    while (elapsed_s < collection_window_s)
    {
        critter_sample_t sample;
        int add_result;

        total_read_attempts += 1U;

        if (critter_io_read_sample(&sample) != 0)
        {
            fprintf(stderr, "failed to read sample during one-minute collection\n");
            critter_memory_free(&memory);
            return 1;
        }
    }
}