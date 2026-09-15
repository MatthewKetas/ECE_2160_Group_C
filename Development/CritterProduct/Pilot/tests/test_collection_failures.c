#define _POSIX_C_SOURCE 200809L
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdio.h>
#include <time.h>
#include "IO/critter_io.h"
#include "Memory/critter_memory.h"
#include "Computation/critter_computation.h"

static int calls;
static time_t ticks;
static int frozen;
static int metrics_failure;
static int metrics_called;
static int sample_failure;
static time_t clock_step = 1;
static int simulated_clock(clockid_t clock_id, struct timespec *timestamp)
{
    (void)clock_id;
    timestamp->tv_sec = (time_t)(100 + ticks);
    timestamp->tv_nsec = 0;
    if (!frozen)
        ticks += clock_step;
    return 0;
}
static int simulated_sleep(const struct timespec *delay, struct timespec *remaining)
{
    (void)delay;
    (void)remaining;
    return 0;
}
static int simulated_read_sample(critter_sample_t *sample)
{
    calls += 1;
    if (calls == 1)
        return -1;
    *sample = (critter_sample_t){.timestamp_s = (double)calls, .temperature_c = 20.0, .source = TEMPERATURE_SOURCE_DATA};
    return 0;
}
static int simulated_save_sample(const critter_sample_t *sample)
{
    assert(sample != NULL);
    return sample_failure ? -1 : 0;
}
static int simulated_save_metrics(const critter_window_summary_t *summary,
    const critter_analysis_result_t *analysis, size_t attempts, size_t valid,
    size_t rejected, size_t outliers, double rate)
{
    assert(summary != NULL && analysis != NULL && rate > 0.0);
    assert(attempts == valid + rejected && rejected == 1U && outliers == 0U);
    metrics_called = 1;
    return metrics_failure ? -1 : 0;
}
static int simulated_io_close(void)
{
    return 0;
}
#define clock_gettime simulated_clock
#define nanosleep simulated_sleep
#define critter_io_read_sample simulated_read_sample
#define critter_io_save_sample simulated_save_sample
#define critter_io_save_metrics simulated_save_metrics
#define critter_io_close simulated_io_close
#define main pilot_main_under_test
#include "../main.c"
#undef main

int main(void)
{
    assert(pilot_main_under_test() == 0);
    assert(calls > 1 && metrics_called);
    calls = 0;
    metrics_failure = 1;
    assert(pilot_main_under_test() == 1);
    calls = 0;
    sample_failure = 1;
    assert(pilot_main_under_test() == 1);
    calls = 0;
    sample_failure = 0;
    frozen = 1;
    assert(pilot_main_under_test() == 1);
    assert(calls == 600); /* Fixed limit even when the clock never advances. */
    frozen = 0;
    clock_step = 1000000000;
    calls = 0;
    assert(pilot_main_under_test() == 1); /* Large clock jump never narrows to int. */
    puts("collection recovery, limits and failure propagation passed");
    return 0;
}
