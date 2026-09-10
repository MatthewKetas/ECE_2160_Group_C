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
    const double sample_interval_s = 1.0;
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

    if (critter_memory_init(&memory, 10U) != 0)
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

        if (critter_io_save_sample(&sample) != 0)
        {
            fprintf(stderr, "failed to save sample during one-minute collection\n");
            critter_memory_free(&memory);
            return 1;
        }

        add_result = critter_memory_add_sample(&memory, &sample);
        if (add_result == 0)
        {
            total_valid_samples += 1U;
        }
        else
        {
            total_rejected_samples += 1U;
        }

        total_outliers = memory.total_outliers;

        if (clock_gettime(CLOCK_MONOTONIC, &now_ts) != 0)
        {
            fprintf(stderr, "failed to read time during one-minute collection\n");
            critter_memory_free(&memory);
            return 1;
        }

        elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
                 + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;

        if (elapsed_s < collection_window_s)
        {
            struct timespec sleep_ts;
            double remaining_s = sample_interval_s - (elapsed_s - (double)((long long)elapsed_s));
            sleep_ts.tv_sec = (time_t)remaining_s;
            sleep_ts.tv_nsec = (long)((remaining_s - (double)sleep_ts.tv_sec) * 1000000000.0);
            nanosleep(&sleep_ts, NULL);
        }

        if (elapsed_s >= last_report_s + report_interval_s)
        {
            int elapsed_seconds = (int)elapsed_s;
            int minutes = elapsed_seconds / 60;
            int seconds = elapsed_seconds % 60;
            printf("\rCollecting: %02d:%02d / 01:00", minutes, seconds);
            fflush(stdout);
            last_report_s = elapsed_s;
        }
    }

    printf("\rCollecting: 01:00 / 01:00\n");

    if (critter_memory_build_summary(&memory, &summary) != 0)
    {
        fprintf(stderr, "failed to build summary\n");
        critter_memory_free(&memory);
        return 1;
    }

    if (critter_compute_analysis(&summary, prediction_horizon_s, &analysis) != 0)
    {
        fprintf(stderr, "failed to compute analysis\n");
        critter_memory_free(&memory);
        return 1;
    }

    if (collection_window_s > 0.0)
        sampling_rate_hz = (double)total_read_attempts / collection_window_s;

    printf("metrics: reads=%zu valid=%zu rejected=%zu outliers=%zu rate=%.2fHz retained=%.2f\n",
           total_read_attempts,
           total_valid_samples,
           total_rejected_samples,
           total_outliers,
           sampling_rate_hz,
           summary.retained_ratio);

    printf("summary: count=%zu min=%.2f max=%.2f mean=%.2f median=%.2f stddev=%.3f source=%d\n",
           summary.sample_count,
           summary.min_temperature_c,
           summary.max_temperature_c,
           summary.mean_temperature_c,
           summary.median_temperature_c,
           summary.stddev_temperature_c,
           (int)summary.source);

    printf("analysis: current=%.2f predicted=%.2f trend=%.4f rate=%.4f hvac=%s heating=%s cooling=%s stable=%s\n",
           analysis.current_temperature_c,
           analysis.predicted_temperature_c,
           analysis.trend_c_per_s,
           analysis.rate_of_change_c_per_s,
           analysis.likely_hvac_active ? "true" : "false",
           analysis.likely_heating ? "true" : "false",
           analysis.likely_cooling ? "true" : "false",
           analysis.stable ? "true" : "false");

    if (critter_io_save_metrics(&summary,
                                &analysis,
                                total_read_attempts,
                                total_valid_samples,
                                total_rejected_samples,
                                total_outliers,
                                sampling_rate_hz) != 0)
    {
        fprintf(stderr, "failed to save metrics during one-minute collection\n");
    }

    critter_memory_free(&memory);
    return 0;
}
