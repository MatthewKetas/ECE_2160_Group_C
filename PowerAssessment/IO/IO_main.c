#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "IO/critter_io.h"

int main(void)
{

    const double collection_window_s = 60.0;
    const double sample_interval_s = 0.1;
    const double report_interval_s = 5.0;

    struct timespec start_ts;
    struct timespec now_ts;

    double elapsed_s = 0.0;
    double last_report_s = 0.0;
    size_t total_read_attempts = 0U;
    size_t source_counts[4] = {0};

    if (clock_gettime(CLOCK_MONOTONIC, &start_ts) != 0)
    {
        fprintf(stderr, "failed to start one-minute collection window\n");
        return 1;
    }

    while (elapsed_s < collection_window_s)
    {
        critter_sample_t sample;

        total_read_attempts += 1U;

        if (critter_io_read_sample(&sample) != 0)
        {
            fprintf(stderr, "failed to read sample during one-minute collection\n");
            return 1;
        }

        source_counts[sample.source] += 1U;

        if (critter_io_save_sample(&sample) != 0)
        {
            fprintf(stderr, "failed to save sample during one-minute collection\n");
            return 1;
        }

        if (clock_gettime(CLOCK_MONOTONIC, &now_ts) != 0)
        {
            fprintf(stderr, "failed to read time during one-minute collection\n");
            return 1;
        }

        elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
                  + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;

        if (elapsed_s >= last_report_s + report_interval_s)
        {
            int elapsed_seconds = (int)elapsed_s;
            int minutes = elapsed_seconds / 60;
            int seconds = elapsed_seconds % 60;

            printf("\rCollecting: %02d:%02d / 01:00", minutes, seconds);
            fflush(stdout);

            last_report_s = elapsed_s;
        }

        if (elapsed_s < collection_window_s)
        {
            struct timespec sleep_ts;

            sleep_ts.tv_sec = (time_t)sample_interval_s;
            sleep_ts.tv_nsec =
                (long)((sample_interval_s - (double)sleep_ts.tv_sec) * 1000000000.0);

            if (nanosleep(&sleep_ts, NULL) != 0)
            {
                fprintf(stderr, "\nsample delay interrupted\n");
                return 1;
            }
        }

        if (clock_gettime(CLOCK_MONOTONIC, &now_ts) != 0)
        {
            fprintf(stderr, "failed to read time during one-minute collection\n");
            return 1;
        }

        elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
                  + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
    }

    printf("\rCollecting: 01:00 / 01:00\n");

    printf("io: reads=%zu rate=%.2fHz sense_hat=%zu data=%zu cpu=%zu\n",
           total_read_attempts, total_read_attempts / elapsed_s,
           source_counts[TEMPERATURE_SOURCE_SENSE_HAT],
           source_counts[TEMPERATURE_SOURCE_DATA],
           source_counts[TEMPERATURE_SOURCE_CPU]);
    return 0;
}
