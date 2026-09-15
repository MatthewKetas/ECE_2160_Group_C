#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <stdio.h>
#include <time.h>

#include "Computation/critter_computation.h"
#include "IO/critter_io.h"
#include "Memory/critter_memory.h"

#define CRITTER_MAX_READ_ATTEMPTS 600U

typedef struct
{
    size_t attempts;
    double elapsed_s;
    double last_report_s;
    struct timespec start;
} collection_t;

static int critter_update_elapsed(collection_t *collection)
{
    if (collection == NULL)
        return -1;
    struct timespec now;
    if (clock_gettime(CLOCK_MONOTONIC, &now) != 0)
        return -1;
    /* H10: Convert operands before subtraction; reject backwards clock observations. */
    double elapsed = ((double)now.tv_sec - (double)collection->start.tv_sec) +
        ((double)now.tv_nsec - (double)collection->start.tv_nsec) / 1.0e9;
    if (!isfinite(elapsed) || elapsed < collection->elapsed_s)
        return -1;
    collection->elapsed_s = elapsed;
    return 0;
}

static int critter_sample_delay(void)
{
    /* H11: Exact integer duration avoids unnecessary floating-to-integer conversions. */
    struct timespec delay = {.tv_sec = 0, .tv_nsec = 100000000L};
    for (size_t retry = 0U; retry < 3U; ++retry)
    {
        struct timespec remaining;
        if (nanosleep(&delay, &remaining) == 0)
            return 0;
        if (errno != EINTR)
            return -1;
        delay = remaining;
    }
    return -1;
}

static int critter_collect(critter_memory_t *memory, collection_t *collection)
{
    if (memory == NULL || collection == NULL || clock_gettime(CLOCK_MONOTONIC, &collection->start) != 0)
        return -1;
    /* H12: A stalled clock cannot extend the loop past 600 attempts. */
    for (size_t attempt = 0U; attempt < CRITTER_MAX_READ_ATTEMPTS; ++attempt)
    {
        if (critter_update_elapsed(collection) != 0)
            return -1;
        if (collection->elapsed_s >= 60.0)
            break;
        collection->attempts += 1U;
        critter_sample_t sample;
        /* A20: A transient acquisition failure counts as rejected and collection continues. */
        if (critter_io_read_sample(&sample) == 0)
        {
            int added = critter_memory_add_sample(memory, &sample);
            if (added == 0 && critter_io_save_sample(&sample) != 0)
                return -1;
        }
        if (critter_update_elapsed(collection) != 0)
            return -1;
        if (collection->elapsed_s >= collection->last_report_s + 5.0)
        {
            /* H11/A21: Bound the conversion and handle console flush failures. */
            int seconds = collection->elapsed_s < 60.0 ? (int)collection->elapsed_s : 60;
            if (printf("\rCollecting: %02d:%02d / 01:00", seconds / 60, seconds % 60) < 0 || fflush(stdout) != 0)
                return -1;
            collection->last_report_s = collection->elapsed_s;
        }
        if (collection->elapsed_s < 60.0 && critter_sample_delay() != 0)
            return -1;
    }
    return critter_update_elapsed(collection);
}

static int critter_report(const critter_memory_t *memory, const collection_t *collection)
{
    if (memory == NULL || collection == NULL || collection->elapsed_s <= 0.0)
        return -1;
    critter_window_summary_t summary;
    critter_analysis_result_t analysis;
    if (critter_memory_build_summary(memory, &summary) != 0 ||
        critter_compute_analysis(&summary, 30.0, &analysis) != 0)
        return -1;
    double rate = (double)collection->attempts / collection->elapsed_s;
    size_t valid = memory->total_valid_samples;
    if (valid > collection->attempts)
        return -1;
    size_t rejected = collection->attempts - valid;
    /* A22: Persist first and propagate failure to the process exit status. */
    if (critter_io_save_metrics(&summary, &analysis, collection->attempts, valid,
                               rejected, memory->total_outliers, rate) != 0)
        return -1;
    if (printf("\nmetrics: reads=%zu valid=%zu rejected=%zu outliers=%zu rate=%.2fHz retained=%.2f\n",
               collection->attempts, valid, rejected, memory->total_outliers, rate, summary.retained_ratio) < 0 ||
        printf("summary: count=%zu min=%.2f max=%.2f mean=%.2f median=%.2f stddev=%.3f source=%d\n",
               summary.sample_count, summary.min_temperature_c, summary.max_temperature_c,
               summary.mean_temperature_c, summary.median_temperature_c, summary.stddev_temperature_c, (int)summary.source) < 0 ||
        printf("analysis: current=%.2f predicted=%.2f trend=%.4f rate=%.4f hvac=%s heating=%s cooling=%s stable=%s\n",
               analysis.current_temperature_c, analysis.predicted_temperature_c,
               analysis.trend_c_per_s, analysis.rate_of_change_c_per_s,
               analysis.likely_hvac_active ? "true" : "false", analysis.likely_heating ? "true" : "false",
               analysis.likely_cooling ? "true" : "false", analysis.stable ? "true" : "false") < 0 || fflush(stdout) != 0)
        return -1;
    return 0;
}

/* A23: Separate collection, reporting and cleanup into reviewable functions. */
int main(void)
{
    critter_memory_t memory;
    collection_t collection = {0};
    int status = 1;
    if (critter_memory_init(&memory, CRITTER_MEMORY_MAX_CAPACITY) == 0)
    {
        if (critter_collect(&memory, &collection) == 0 && critter_report(&memory, &collection) == 0)
            status = 0;
        critter_memory_free(&memory);
    }
    if (critter_io_close() != 0)
        status = 1;
    if (status != 0)
        (void)fprintf(stderr, "collection, reporting or cleanup failed\n"); /* A21: Best-effort error diagnostic. */
    return status;
}
